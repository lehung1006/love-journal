import '../../domain/entities/place_search.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../data_sources/google_places_data_source.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl(this._dataSource);

  final GooglePlacesDataSource _dataSource;

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
  Future<PlaceSearchResult> fetchPlaceDetails({
    required String googlePlaceId,
    required String sessionToken,
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

  String? _nestedText(Object? value) {
    if (value is Map<String, dynamic>) {
      return value['text'] as String?;
    }
    return null;
  }
}
