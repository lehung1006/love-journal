import '../entities/place_search.dart';

abstract interface class PlaceSearchRepository {
  Future<List<PlaceSearchSuggestion>> autocompletePlaces({
    required String input,
    required String sessionToken,
    GeoCoordinate? locationBias,
  });

  Future<PlaceSearchResult> fetchPlaceDetails({
    required String googlePlaceId,
    required String sessionToken,
  });
}
