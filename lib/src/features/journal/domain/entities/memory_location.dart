import 'memory.dart';

enum MemoryLocationSource { googlePlaces, manual }

class MemoryLocation {
  const MemoryLocation({
    required this.id,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.formattedAddress,
    this.googlePlaceId,
  });

  final String id;
  final String displayName;
  final String? formattedAddress;
  final double latitude;
  final double longitude;
  final String? googlePlaceId;
  final MemoryLocationSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasValidCoordinate {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  MemoryLocation copyWith({
    String? id,
    String? displayName,
    String? formattedAddress,
    double? latitude,
    double? longitude,
    String? googlePlaceId,
    MemoryLocationSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoryLocation(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MemoryLocationDraft {
  const MemoryLocationDraft({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.formattedAddress,
    this.googlePlaceId,
  });

  final String displayName;
  final String? formattedAddress;
  final double latitude;
  final double longitude;
  final String? googlePlaceId;
  final MemoryLocationSource source;

  bool get hasValidCoordinate {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  MemoryLocationDraft copyWith({
    String? displayName,
    String? formattedAddress,
    bool clearFormattedAddress = false,
    double? latitude,
    double? longitude,
    String? googlePlaceId,
    bool clearGooglePlaceId = false,
    MemoryLocationSource? source,
  }) {
    return MemoryLocationDraft(
      displayName: displayName ?? this.displayName,
      formattedAddress: clearFormattedAddress
          ? null
          : formattedAddress ?? this.formattedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googlePlaceId: clearGooglePlaceId
          ? null
          : googlePlaceId ?? this.googlePlaceId,
      source: source ?? this.source,
    );
  }
}

class MemoryLocationSelection {
  const MemoryLocationSelection.existing(String locationId)
    : existingLocationId = locationId,
      draftLocation = null;

  const MemoryLocationSelection.draft(MemoryLocationDraft draft)
    : existingLocationId = null,
      draftLocation = draft;

  final String? existingLocationId;
  final MemoryLocationDraft? draftLocation;
}

class MemoryLocationGroup {
  const MemoryLocationGroup({required this.location, required this.memories});

  final MemoryLocation location;
  final List<Memory> memories;
}
