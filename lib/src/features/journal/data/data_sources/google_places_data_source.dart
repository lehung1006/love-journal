import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/map_service_config.dart';

abstract interface class GooglePlacesDataSource {
  Future<List<Map<String, dynamic>>> autocompletePlaces({
    required String input,
    required String sessionToken,
    double? biasLatitude,
    double? biasLongitude,
  });

  Future<Map<String, dynamic>> fetchPlaceDetails({
    required String googlePlaceId,
    required String sessionToken,
  });
}

class GooglePlacesApiDataSource implements GooglePlacesDataSource {
  const GooglePlacesApiDataSource({
    required http.Client client,
    required MapServiceConfig config,
  }) : this._(client, config);

  const GooglePlacesApiDataSource._(this._client, this._config);

  static final Uri _autocompleteUri = Uri.https(
    'places.googleapis.com',
    '/v1/places:autocomplete',
  );

  final http.Client _client;
  final MapServiceConfig _config;

  @override
  Future<List<Map<String, dynamic>>> autocompletePlaces({
    required String input,
    required String sessionToken,
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    _assertConfigured();
    final body = <String, Object?>{
      'input': input,
      'languageCode': 'vi',
      'sessionToken': sessionToken,
      if (biasLatitude != null && biasLongitude != null)
        'locationBias': {
          'circle': {
            'center': {'latitude': biasLatitude, 'longitude': biasLongitude},
            'radius': 80000.0,
          },
        },
    };

    final response = await _client.post(
      _autocompleteUri,
      headers: _headers(
        fieldMask: [
          'suggestions.placePrediction.placeId',
          'suggestions.placePrediction.text.text',
          'suggestions.placePrediction.structuredFormat.mainText.text',
          'suggestions.placePrediction.structuredFormat.secondaryText.text',
        ].join(','),
      ),
      body: jsonEncode(body),
    );
    final decoded = _decodeObject(response);
    final suggestions = decoded['suggestions'];
    if (suggestions is! List<dynamic>) {
      return const [];
    }

    return suggestions.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails({
    required String googlePlaceId,
    required String sessionToken,
  }) async {
    _assertConfigured();
    final uri = Uri.https(
      'places.googleapis.com',
      '/v1/places/$googlePlaceId',
      {'sessionToken': sessionToken, 'languageCode': 'vi'},
    );
    final response = await _client.get(
      uri,
      headers: _headers(
        fieldMask: [
          'id',
          'displayName.text',
          'formattedAddress',
          'location.latitude',
          'location.longitude',
        ].join(','),
      ),
    );
    return _decodeObject(response);
  }

  Map<String, String> _headers({required String fieldMask}) {
    return {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _config.googleMapsApiKey,
      'X-Goog-FieldMask': fieldMask,
      if (_config.androidPackageName.isNotEmpty)
        'X-Android-Package': _config.androidPackageName,
      if (_config.androidCertificateSha1.isNotEmpty)
        'X-Android-Cert': _config.androidCertificateSha1,
      if (_config.iosBundleIdentifier.isNotEmpty)
        'X-Ios-Bundle-Identifier': _config.iosBundleIdentifier,
    };
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GooglePlacesException(
        statusCode: response.statusCode,
        body: decoded,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const GooglePlacesException(
        statusCode: 0,
        body: 'Expected a JSON object response.',
      );
    }
    return decoded;
  }

  void _assertConfigured() {
    if (!_config.hasGoogleMapsApiKey) {
      throw const GooglePlacesException(
        statusCode: 0,
        body: 'A platform Google Maps API key is not configured.',
      );
    }
  }
}

class GooglePlacesException implements Exception {
  const GooglePlacesException({required this.statusCode, required this.body});

  final int statusCode;
  final Object? body;

  @override
  String toString() {
    String? message;
    if (body case final Map<String, dynamic> responseBody) {
      final error = responseBody['error'];
      if (error is Map<String, dynamic>) {
        message = error['message'] as String?;
      }
    }
    return message != null && message.isNotEmpty
        ? message
        : 'Google Places request failed ($statusCode).';
  }
}
