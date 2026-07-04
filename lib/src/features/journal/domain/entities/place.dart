class Place {
  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.memoryIds,
    this.coverMediaId,
    this.shortNote,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> memoryIds;
  final String? coverMediaId;
  final String? shortNote;

  Place copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    List<String>? memoryIds,
    String? coverMediaId,
    String? shortNote,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      memoryIds: memoryIds ?? this.memoryIds,
      coverMediaId: coverMediaId ?? this.coverMediaId,
      shortNote: shortNote ?? this.shortNote,
    );
  }
}
