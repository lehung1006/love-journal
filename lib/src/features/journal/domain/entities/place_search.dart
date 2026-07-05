class GeoCoordinate {
  const GeoCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class PlaceSearchSuggestion {
  const PlaceSearchSuggestion({
    required this.placeId,
    required this.primaryText,
    required this.fullText,
    this.secondaryText,
  });

  final String placeId;
  final String primaryText;
  final String? secondaryText;
  final String fullText;
}

class PlaceSearchResult {
  const PlaceSearchResult({
    required this.placeId,
    required this.name,
    required this.coordinate,
    this.formattedAddress,
  });

  final String placeId;
  final String name;
  final String? formattedAddress;
  final GeoCoordinate coordinate;
}
