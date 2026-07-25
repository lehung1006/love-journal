import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/config/map_service_config.dart';
import '../../../../core/diagnostics/app_debug_logger.dart';
import 'place_search_data_source.dart';

class GooglePlacesApiDataSource implements PlaceSearchDataSource {
  const GooglePlacesApiDataSource({
    required http.Client client,
    required MapServiceConfig config,
  }) : this._(client, config);

  const GooglePlacesApiDataSource._(this._client, this._config);

  static final Uri _autocompleteUri = Uri.https(
    'places.googleapis.com',
    '/v1/places:autocomplete',
  );
  static final Uri _nearbySearchUri = Uri.https(
    'places.googleapis.com',
    '/v1/places:searchNearby',
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
    AppDebugLogger.info(
      'GooglePlaces',
      'Starting Autocomplete. input="$input", '
          'hasLocationBias=${biasLatitude != null && biasLongitude != null}.',
    );
    final body = <String, Object?>{
      'input': input,
      'languageCode': 'vi',
      'sessionToken': sessionToken,
      if (biasLatitude != null && biasLongitude != null)
        'locationBias': {
          'circle': {
            'center': {'latitude': biasLatitude, 'longitude': biasLongitude},
            'radius': 50000.0,
          },
        },
    };

    final headers = _headers(
      fieldMask: [
        'suggestions.placePrediction.placeId',
        'suggestions.placePrediction.text.text',
        'suggestions.placePrediction.structuredFormat.mainText.text',
        'suggestions.placePrediction.structuredFormat.secondaryText.text',
      ].join(','),
    );
    _logRequest(
      operation: 'Autocomplete',
      method: 'POST',
      uri: _autocompleteUri,
      headers: headers,
      body: body,
    );
    late final http.Response response;
    try {
      response = await _client.post(
        _autocompleteUri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (error, stackTrace) {
      AppDebugLogger.error(
        'GooglePlaces',
        'Autocomplete transport request failed before receiving an HTTP response.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    final decoded = _decodeObject(response, operation: 'Autocomplete');
    final suggestions = decoded['suggestions'];
    if (suggestions is! List<dynamic>) {
      AppDebugLogger.info(
        'GooglePlaces',
        'Autocomplete succeeded with no suggestions list.',
      );
      return const [];
    }

    final result = suggestions.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    AppDebugLogger.info(
      'GooglePlaces',
      'Autocomplete succeeded. suggestionCount=${result.length}.',
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> searchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required int maxResults,
  }) async {
    _assertConfigured();
    AppDebugLogger.info(
      'GooglePlaces',
      'Starting Nearby Search. latitude=$latitude, longitude=$longitude, '
          'radiusMeters=$radiusMeters, maxResults=$maxResults.',
    );
    final body = <String, Object?>{
      'maxResultCount': maxResults,
      'rankPreference': 'DISTANCE',
      'languageCode': 'vi',
      'regionCode': 'VN',
      'locationRestriction': {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': radiusMeters,
        },
      },
    };
    final headers = _headers(
      fieldMask: [
        'places.id',
        'places.displayName.text',
        'places.formattedAddress',
        'places.location.latitude',
        'places.location.longitude',
        'places.primaryTypeDisplayName.text',
        'places.businessStatus',
      ].join(','),
    );
    _logRequest(
      operation: 'Nearby Search',
      method: 'POST',
      uri: _nearbySearchUri,
      headers: headers,
      body: body,
    );

    late final http.Response response;
    try {
      response = await _client.post(
        _nearbySearchUri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (error, stackTrace) {
      AppDebugLogger.error(
        'GooglePlaces',
        'Nearby Search transport request failed before receiving an HTTP response.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    final decoded = _decodeObject(response, operation: 'Nearby Search');
    final places = decoded['places'];
    if (places is! List<dynamic>) {
      AppDebugLogger.info(
        'GooglePlaces',
        'Nearby Search succeeded with no places list.',
      );
      return const [];
    }
    final result = places.whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    AppDebugLogger.info(
      'GooglePlaces',
      'Nearby Search succeeded. placeCount=${result.length}.',
    );
    return result;
  }

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  }) async {
    _assertConfigured();
    AppDebugLogger.info(
      'GooglePlaces',
      'Starting Place Details. placeId=$googlePlaceId.',
    );
    final uri =
        Uri.https('places.googleapis.com', '/v1/places/$googlePlaceId', {
          if (sessionToken != null && sessionToken.isNotEmpty)
            'sessionToken': sessionToken,
          'languageCode': 'vi',
          'regionCode': 'VN',
        });
    final headers = _headers(
      fieldMask: [
        'id',
        'displayName.text',
        'formattedAddress',
        'location.latitude',
        'location.longitude',
        'primaryTypeDisplayName.text',
        'businessStatus',
        'googleMapsUri',
        'photos.name',
        'photos.widthPx',
        'photos.heightPx',
        'photos.authorAttributions',
      ].join(','),
    );
    _logRequest(
      operation: 'Place Details',
      method: 'GET',
      uri: uri,
      headers: headers,
    );
    late final http.Response response;
    try {
      response = await _client.get(uri, headers: headers);
    } catch (error, stackTrace) {
      AppDebugLogger.error(
        'GooglePlaces',
        'Place Details transport request failed before receiving an HTTP response.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
    final result = _decodeObject(response, operation: 'Place Details');
    AppDebugLogger.info('GooglePlaces', 'Place Details succeeded.');
    return result;
  }

  @override
  Future<Uint8List> fetchPlacePhoto({
    required String photoName,
    required int maxWidthPx,
  }) async {
    _assertConfigured();
    final uri = Uri.https('places.googleapis.com', '/v1/$photoName/media', {
      'maxWidthPx': '$maxWidthPx',
    });
    final headers = {'X-Goog-Api-Key': _config.googleMapsApiKey};
    _logRequest(
      operation: 'Place Photo',
      method: 'GET',
      uri: uri,
      headers: headers,
    );

    late final http.Response response;
    try {
      response = await _client.get(uri, headers: headers);
    } catch (error, stackTrace) {
      AppDebugLogger.error(
        'GooglePlaces',
        'Place Photo transport request failed before receiving an HTTP response.',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    AppDebugLogger.json('GooglePlaces', 'Place Photo HTTP response', {
      'statusCode': response.statusCode,
      'reasonPhrase': response.reasonPhrase,
      'headers': response.headers,
      'byteLength': response.bodyBytes.length,
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      Object? body = response.body;
      try {
        body = jsonDecode(response.body);
      } on FormatException {
        // Preserve the raw body when the server did not return JSON.
      }
      throw PlaceSearchException(statusCode: response.statusCode, body: body);
    }
    return response.bodyBytes;
  }

  @override
  Future<void> clearSession(String sessionToken) async {}

  Map<String, String> _headers({required String fieldMask}) {
    return {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _config.googleMapsApiKey,
      'X-Goog-FieldMask': fieldMask,
    };
  }

  void _logRequest({
    required String operation,
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
  }) {
    final sanitizedHeaders = Map<String, String>.from(headers);
    final apiKey = sanitizedHeaders['X-Goog-Api-Key'];
    if (apiKey != null) {
      sanitizedHeaders['X-Goog-Api-Key'] = AppDebugLogger.maskSecret(apiKey);
    }
    AppDebugLogger.json('GooglePlaces', '$operation request', {
      'method': method,
      'url': uri.toString(),
      'headers': sanitizedHeaders,
      'body': body,
    });
  }

  Map<String, dynamic> _decodeObject(
    http.Response response, {
    required String operation,
  }) {
    AppDebugLogger.json('GooglePlaces', '$operation HTTP response', {
      'statusCode': response.statusCode,
      'reasonPhrase': response.reasonPhrase,
      'headers': response.headers,
      'rawBody': response.body,
    });
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error, stackTrace) {
      AppDebugLogger.error(
        'GooglePlaces',
        '$operation returned non-JSON. status=${response.statusCode}; '
            'body=${response.body}',
        error: error,
        stackTrace: stackTrace,
      );
      throw PlaceSearchException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppDebugLogger.error(
        'GooglePlaces',
        '$operation failed. status=${response.statusCode}.',
      );
      AppDebugLogger.json(
        'GooglePlaces',
        '$operation decoded error response',
        decoded,
      );
      throw PlaceSearchException(
        statusCode: response.statusCode,
        body: decoded,
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const PlaceSearchException(
        statusCode: 0,
        body: 'Expected a JSON object response.',
      );
    }
    return decoded;
  }

  void _assertConfigured() {
    if (!_config.hasGoogleMapsApiKey) {
      AppDebugLogger.error(
        'GooglePlaces',
        'Request skipped because no Google Maps API key was configured.',
      );
      throw const PlaceSearchException(
        statusCode: 0,
        body: 'A platform Google Maps API key is not configured.',
      );
    }
    AppDebugLogger.info(
      'GooglePlaces',
      'Request configuration: apiKeyConfigured=true; '
          'apiKeyMasked=${AppDebugLogger.maskSecret(_config.googleMapsApiKey)}; '
          'androidPackage=${_config.androidPackageName.isEmpty ? '<empty>' : _config.androidPackageName}; '
          'androidSha1=${_config.androidCertificateSha1.isEmpty ? '<empty>' : _config.androidCertificateSha1}; '
          'iosBundleConfigured=${_config.iosBundleIdentifier.isNotEmpty}.',
    );
  }
}
