import '../entities/place_search.dart';

abstract interface class PlaceSearchRepository {
  Future<void> clearSession(String sessionToken);

  Future<List<PlaceSearchSuggestion>> autocompletePlaces({
    required String input,
    required String sessionToken,
    GeoCoordinate? locationBias,
  });

  Future<List<NearbyPlaceCandidate>> searchNearby({
    required GeoCoordinate center,
    double radiusMeters = 150,
    int maxResults = 8,
  });

  Future<PlaceSearchResult> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  });

  Future<PlacePhotoData> fetchPlacePhoto({
    required PlacePhotoReference photo,
    int maxWidthPx = 640,
  });
}
