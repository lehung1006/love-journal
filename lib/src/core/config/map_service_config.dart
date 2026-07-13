class MapServiceConfig {
  const MapServiceConfig({
    this.googleMapsApiKey = '',
    this.androidPackageName = '',
    this.androidCertificateSha1 = '',
    this.iosBundleIdentifier = '',
  });

  final String googleMapsApiKey;
  final String androidPackageName;
  final String androidCertificateSha1;
  final String iosBundleIdentifier;

  bool get hasGoogleMapsApiKey => googleMapsApiKey.trim().isNotEmpty;
}
