class MapServiceConfig {
  const MapServiceConfig({
    this.googleMapsApiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
  });

  final String googleMapsApiKey;

  bool get hasGoogleMapsApiKey => googleMapsApiKey.trim().isNotEmpty;
}
