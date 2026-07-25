import '../../domain/entities/place_search.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../data_sources/place_search_data_source.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl(this._dataSource);

  final PlaceSearchDataSource _dataSource;

  @override
  Future<void> clearSession(String sessionToken) {
    return _dataSource.clearSession(sessionToken);
  }

  @override
  Future<List<PlaceSearchSuggestion>> autocompletePlaces({
    required String input,
    required String sessionToken,
    GeoCoordinate? locationBias,
  }) async {
    final suggestions = await _dataSource.autocompletePlaces(
      input: input,
      sessionToken: sessionToken,
      biasLatitude: locationBias?.latitude,
      biasLongitude: locationBias?.longitude,
    );

    return suggestions
        .map(_suggestionFromJson)
        .whereType<PlaceSearchSuggestion>()
        .toList(growable: false);
  }

  @override
  Future<List<NearbyPlaceCandidate>> searchNearby({
    required GeoCoordinate center,
    double radiusMeters = 150,
    int maxResults = 8,
  }) async {
    final places = await _dataSource.searchNearby(
      latitude: center.latitude,
      longitude: center.longitude,
      radiusMeters: radiusMeters,
      maxResults: maxResults,
    );

    return places
        .map(_nearbyCandidateFromJson)
        .whereType<NearbyPlaceCandidate>()
        .toList(growable: false);
  }

  @override
  Future<PlaceSearchResult> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  }) async {
    final json = await _dataSource.fetchPlaceDetails(
      googlePlaceId: googlePlaceId,
      sessionToken: sessionToken,
    );
    final location = json['location'];
    if (location is! Map<String, dynamic>) {
      throw const FormatException('Place Details response has no location.');
    }

    return PlaceSearchResult(
      googlePlaceId: json['id'] as String? ?? googlePlaceId,
      name: _displayNameFromJson(json) ?? googlePlaceId,
      formattedAddress: json['formattedAddress'] as String?,
      coordinate: GeoCoordinate(
        latitude: (location['latitude'] as num).toDouble(),
        longitude: (location['longitude'] as num).toDouble(),
      ),
      primaryTypeDisplayName: _nestedText(json['primaryTypeDisplayName']),
      businessStatus: _businessStatusFromJson(json['businessStatus']),
      googleMapsUri: json['googleMapsUri'] as String?,
      photos: _photosFromJson(json['photos']),
    );
  }

  @override
  Future<PlacePhotoData> fetchPlacePhoto({
    required PlacePhotoReference photo,
    int maxWidthPx = 640,
  }) async {
    final bytes = await _dataSource.fetchPlacePhoto(
      photoName: photo.name,
      maxWidthPx: maxWidthPx,
    );
    return PlacePhotoData(bytes: bytes);
  }

  NearbyPlaceCandidate? _nearbyCandidateFromJson(Map<String, dynamic> json) {
    final placeId = json['id'] as String?;
    final name = _displayNameFromJson(json);
    final location = json['location'];
    if (placeId == null ||
        name == null ||
        location is! Map<String, dynamic> ||
        location['latitude'] is! num ||
        location['longitude'] is! num) {
      return null;
    }

    return NearbyPlaceCandidate(
      googlePlaceId: placeId,
      name: name,
      formattedAddress: json['formattedAddress'] as String?,
      coordinate: GeoCoordinate(
        latitude: (location['latitude'] as num).toDouble(),
        longitude: (location['longitude'] as num).toDouble(),
      ),
      primaryTypeDisplayName: _nestedText(json['primaryTypeDisplayName']),
      businessStatus: _businessStatusFromJson(json['businessStatus']),
    );
  }

  PlaceSearchSuggestion? _suggestionFromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'];
    if (prediction is! Map<String, dynamic>) {
      return null;
    }
    final placeId = prediction['placeId'] as String?;
    final fullText = _nestedText(prediction['text']);
    if (placeId == null || fullText == null) {
      return null;
    }

    final structuredFormat = prediction['structuredFormat'];
    final primaryText = structuredFormat is Map<String, dynamic>
        ? _nestedText(structuredFormat['mainText']) ?? fullText
        : fullText;
    final secondaryText = structuredFormat is Map<String, dynamic>
        ? _nestedText(structuredFormat['secondaryText'])
        : null;

    return PlaceSearchSuggestion(
      googlePlaceId: placeId,
      primaryText: primaryText,
      secondaryText: secondaryText,
      fullText: fullText,
    );
  }

  String? _displayNameFromJson(Map<String, dynamic> json) {
    return _nestedText(json['displayName']);
  }

  List<PlacePhotoReference> _photosFromJson(Object? value) {
    if (value is! List<dynamic>) {
      return const [];
    }
    return value
        .whereType<Map<String, dynamic>>()
        .map((json) {
          final name = json['name'] as String?;
          if (name == null || name.isEmpty) {
            return null;
          }
          return PlacePhotoReference(
            name: name,
            widthPx: json['widthPx'] as int?,
            heightPx: json['heightPx'] as int?,
            authorAttributions: _attributionsFromJson(
              json['authorAttributions'],
            ),
          );
        })
        .whereType<PlacePhotoReference>()
        .toList(growable: false);
  }

  List<PlaceAuthorAttribution> _attributionsFromJson(Object? value) {
    if (value is! List<dynamic>) {
      return const [];
    }
    return value
        .whereType<Map<String, dynamic>>()
        .map((json) {
          final displayName = json['displayName'] as String?;
          if (displayName == null || displayName.isEmpty) {
            return null;
          }
          return PlaceAuthorAttribution(
            displayName: displayName,
            uri: json['uri'] as String?,
            photoUri: json['photoUri'] as String?,
          );
        })
        .whereType<PlaceAuthorAttribution>()
        .toList(growable: false);
  }

  PlaceBusinessStatus _businessStatusFromJson(Object? value) {
    return switch (value) {
      'OPERATIONAL' => PlaceBusinessStatus.operational,
      'CLOSED_TEMPORARILY' => PlaceBusinessStatus.closedTemporarily,
      'CLOSED_PERMANENTLY' => PlaceBusinessStatus.closedPermanently,
      _ => PlaceBusinessStatus.unknown,
    };
  }

  String? _nestedText(Object? value) {
    if (value is Map<String, dynamic>) {
      return value['text'] as String?;
    }
    return null;
  }
}
