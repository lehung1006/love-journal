import 'dart:typed_data';

class GeoCoordinate {
  const GeoCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

enum PlaceBusinessStatus {
  operational,
  closedTemporarily,
  closedPermanently,
  unknown,
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

class NearbyPlaceCandidate {
  const NearbyPlaceCandidate({
    required this.googlePlaceId,
    required this.name,
    required this.coordinate,
    this.formattedAddress,
    this.primaryTypeDisplayName,
    this.businessStatus = PlaceBusinessStatus.unknown,
  });

  final String googlePlaceId;
  final String name;
  final String? formattedAddress;
  final GeoCoordinate coordinate;
  final String? primaryTypeDisplayName;
  final PlaceBusinessStatus businessStatus;
}

class PlaceAuthorAttribution {
  const PlaceAuthorAttribution({
    required this.displayName,
    this.uri,
    this.photoUri,
  });

  final String displayName;
  final String? uri;
  final String? photoUri;
}

class PlacePhotoReference {
  const PlacePhotoReference({
    required this.name,
    this.widthPx,
    this.heightPx,
    this.authorAttributions = const [],
  });

  final String name;
  final int? widthPx;
  final int? heightPx;
  final List<PlaceAuthorAttribution> authorAttributions;
}

class PlacePhotoData {
  const PlacePhotoData({required this.bytes, this.contentType});

  final Uint8List bytes;
  final String? contentType;
}

class PlaceSearchResult {
  const PlaceSearchResult({
    required this.googlePlaceId,
    required this.name,
    required this.coordinate,
    this.formattedAddress,
    this.primaryTypeDisplayName,
    this.businessStatus = PlaceBusinessStatus.unknown,
    this.googleMapsUri,
    this.photos = const [],
  });

  final String googlePlaceId;
  final String name;
  final String? formattedAddress;
  final GeoCoordinate coordinate;
  final String? primaryTypeDisplayName;
  final PlaceBusinessStatus businessStatus;
  final String? googleMapsUri;
  final List<PlacePhotoReference> photos;
}
