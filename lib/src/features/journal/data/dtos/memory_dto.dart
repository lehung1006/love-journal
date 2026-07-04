import '../../domain/entities/memory.dart';
import 'journal_enum_dto_mapper.dart';

class MemoryMediaDto {
  const MemoryMediaDto({
    required this.id,
    required this.type,
    required this.uri,
    this.width,
    this.height,
    this.alt,
  });

  factory MemoryMediaDto.fromJson(Map<String, dynamic> json) {
    return MemoryMediaDto(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'image',
      uri: json['uri'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      alt: json['alt'] as String?,
    );
  }

  final String id;
  final String type;
  final String uri;
  final int? width;
  final int? height;
  final String? alt;

  MemoryMedia toDomain() {
    return MemoryMedia(
      id: id,
      type: memoryMediaTypeFromDto(type),
      uri: uri,
      width: width,
      height: height,
      alt: alt,
    );
  }
}

class MemoryDto {
  const MemoryDto({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.phase,
    required this.media,
    required this.story,
    required this.createdAt,
    required this.updatedAt,
    this.locationName,
    this.latitude,
    this.longitude,
    this.placeId,
    this.coverMediaId,
    this.favoriteMoment,
    this.messageForHer,
    this.voiceNoteUrl,
    this.isFeatured = false,
  });

  factory MemoryDto.fromJson(Map<String, dynamic> json) {
    return MemoryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      category: json['category'] as String? ?? 'daily',
      phase: json['phase'] as String? ?? 'year_1',
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['placeId'] as String?,
      media: (json['media'] as List<dynamic>? ?? const [])
          .map((item) => MemoryMediaDto.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      coverMediaId: json['coverMediaId'] as String?,
      story: json['story'] as String,
      favoriteMoment: json['favoriteMoment'] as String?,
      messageForHer: json['messageForHer'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  final String id;
  final String title;
  final String date;
  final String category;
  final String phase;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final List<MemoryMediaDto> media;
  final String? coverMediaId;
  final String story;
  final String? favoriteMoment;
  final String? messageForHer;
  final String? voiceNoteUrl;
  final bool isFeatured;
  final String createdAt;
  final String updatedAt;

  Memory toDomain() {
    final domainMedia = media
        .map((item) => item.toDomain())
        .toList(growable: false);

    return Memory(
      id: id,
      title: title,
      date: DateTime.parse(date),
      category: memoryCategoryFromDto(category),
      phase: relationshipPhaseFromDto(phase),
      primaryTagId: MemoryTag.systemIdForCategory(
        memoryCategoryFromDto(category),
      ),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
      media: domainMedia,
      coverMediaId: coverMediaId,
      story: story,
      favoriteMoment: favoriteMoment,
      messageForHer: messageForHer,
      voiceNoteUrl: voiceNoteUrl,
      voiceMessages: voiceNoteUrl == null
          ? const []
          : [
              MemoryVoiceMessage(
                id: '$id-voice-note',
                uri: voiceNoteUrl!,
                source: MemoryVoiceMessageSource.imported,
                title: 'Lời nhắn cũ',
                durationSeconds: 34,
                waveform: const [.22, .58, .4, .76, .34, .62, .28],
                createdAt: DateTime.parse(createdAt),
              ),
            ],
      mediaGroups: domainMedia.isEmpty
          ? const []
          : [
              MemoryMediaGroup(
                id: '$id-media-group-1',
                items: domainMedia,
                sortOrder: 0,
              ),
            ],
      isFeatured: isFeatured,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
