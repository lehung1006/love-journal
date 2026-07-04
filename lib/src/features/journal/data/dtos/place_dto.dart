import '../../domain/entities/place.dart';

class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.memoryIds,
    this.coverMediaId,
    this.shortNote,
  });

  factory PlaceDto.fromJson(Map<String, dynamic> json) {
    return PlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      memoryIds: (json['memoryIds'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
      coverMediaId: json['coverMediaId'] as String?,
      shortNote: json['shortNote'] as String?,
    );
  }

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> memoryIds;
  final String? coverMediaId;
  final String? shortNote;

  Place toDomain() {
    return Place(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      memoryIds: memoryIds,
      coverMediaId: coverMediaId,
      shortNote: shortNote,
    );
  }
}
