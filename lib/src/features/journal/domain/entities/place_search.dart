class GeoCoordinate {
  const GeoCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class PlaceSearchSuggestion {
  const PlaceSearchSuggestion({
    required this.googlePlaceId,
    required this.primaryText,
    required this.fullText,
    this.secondaryText,
  });

  final String googlePlaceId;
  final String primaryText;
  final String? secondaryText;
  final String fullText;
}

class PlaceSearchResult {
  const PlaceSearchResult({
    required this.googlePlaceId,
    required this.name,
    required this.coordinate,
    this.formattedAddress,
  });

  final String googlePlaceId;
  final String name;
  final String? formattedAddress;
  final GeoCoordinate coordinate;
}
