import 'journal_enums.dart';

class MemoryTag {
  const MemoryTag({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.colorKey = 'rose',
    this.isSystem = false,
  });

  final String id;
  final String name;
  final String colorKey;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String systemIdForCategory(MemoryCategory category) {
    return 'system-${category.name}';
  }

  MemoryTag copyWith({
    String? id,
    String? name,
    String? colorKey,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoryTag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorKey: colorKey ?? this.colorKey,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MemoryMedia {
  const MemoryMedia({
    required this.id,
    required this.type,
    required this.uri,
    this.thumbnailUri,
    this.width,
    this.height,
    this.alt,
  });

  final String id;
  final MemoryMediaType type;
  final String uri;
  final String? thumbnailUri;
  final int? width;
  final int? height;
  final String? alt;

  MemoryMedia copyWith({
    String? id,
    MemoryMediaType? type,
    String? uri,
    String? thumbnailUri,
    bool clearThumbnailUri = false,
    int? width,
    int? height,
    String? alt,
  }) {
    return MemoryMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      uri: uri ?? this.uri,
      thumbnailUri: clearThumbnailUri
          ? null
          : thumbnailUri ?? this.thumbnailUri,
      width: width ?? this.width,
      height: height ?? this.height,
      alt: alt ?? this.alt,
    );
  }
}

enum MemoryVoiceMessageSource { imported, recorded }

class MemoryVoiceMessage {
  const MemoryVoiceMessage({
    required this.id,
    required this.uri,
    required this.source,
    required this.createdAt,
    this.fileName,
    this.title,
    this.durationSeconds,
    this.waveform = const [],
  });

  final String id;
  final String uri;
  final MemoryVoiceMessageSource source;
  final String? fileName;
  final String? title;
  final int? durationSeconds;
  final List<double> waveform;
  final DateTime createdAt;

  MemoryVoiceMessage copyWith({
    String? id,
    String? uri,
    MemoryVoiceMessageSource? source,
    String? fileName,
    String? title,
    int? durationSeconds,
    List<double>? waveform,
    DateTime? createdAt,
  }) {
    return MemoryVoiceMessage(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      source: source ?? this.source,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waveform: waveform ?? this.waveform,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MemoryMediaGroup {
  const MemoryMediaGroup({
    required this.id,
    required this.items,
    required this.sortOrder,
    this.title,
    this.note,
  });

  final String id;
  final String? title;
  final String? note;
  final List<MemoryMedia> items;
  final int sortOrder;

  MemoryMediaGroup copyWith({
    String? id,
    String? title,
    bool clearTitle = false,
    String? note,
    bool clearNote = false,
    List<MemoryMedia>? items,
    int? sortOrder,
  }) {
    return MemoryMediaGroup(
      id: id ?? this.id,
      title: clearTitle ? null : title ?? this.title,
      note: clearNote ? null : note ?? this.note,
      items: items ?? this.items,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class Memory {
  const Memory({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    required this.phase,
    required this.media,
    required this.story,
    required this.createdAt,
    required this.updatedAt,
    this.primaryTagId,
    this.locationId,
    this.locationName,
    this.latitude,
    this.longitude,
    this.placeId,
    this.coverMediaId,
    this.note,
    this.favoriteMoment,
    this.messageForHer,
    this.voiceNoteUrl,
    this.voiceMessages = const [],
    this.mediaGroups = const [],
    this.isFeatured = false,
    this.deletedAt,
  });

  final String id;
  final String title;
  final DateTime date;
  final MemoryCategory category;
  final RelationshipPhase phase;
  final String? primaryTagId;
  final String? locationId;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final List<MemoryMedia> media;
  final String? coverMediaId;
  final String story;
  final String? note;
  final String? favoriteMoment;
  final String? messageForHer;
  final String? voiceNoteUrl;
  final List<MemoryVoiceMessage> voiceMessages;
  final List<MemoryMediaGroup> mediaGroups;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get effectiveTagId {
    return primaryTagId ?? MemoryTag.systemIdForCategory(category);
  }

  bool get isDeleted => deletedAt != null;

  MemoryMedia? get coverMedia {
    if (media.isEmpty) {
      return null;
    }
    final coverId = coverMediaId;
    if (coverId == null) {
      return media.first;
    }
    return media.firstWhere(
      (item) => item.id == coverId,
      orElse: () => media.first,
    );
  }

  Memory copyWith({
    String? id,
    String? title,
    DateTime? date,
    MemoryCategory? category,
    RelationshipPhase? phase,
    String? primaryTagId,
    String? locationId,
    String? locationName,
    double? latitude,
    double? longitude,
    String? placeId,
    List<MemoryMedia>? media,
    String? coverMediaId,
    String? story,
    String? note,
    String? favoriteMoment,
    String? messageForHer,
    String? voiceNoteUrl,
    List<MemoryVoiceMessage>? voiceMessages,
    List<MemoryMediaGroup>? mediaGroups,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      category: category ?? this.category,
      phase: phase ?? this.phase,
      primaryTagId: primaryTagId ?? this.primaryTagId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      media: media ?? this.media,
      coverMediaId: coverMediaId ?? this.coverMediaId,
      story: story ?? this.story,
      note: note ?? this.note,
      favoriteMoment: favoriteMoment ?? this.favoriteMoment,
      messageForHer: messageForHer ?? this.messageForHer,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      voiceMessages: voiceMessages ?? this.voiceMessages,
      mediaGroups: mediaGroups ?? this.mediaGroups,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
