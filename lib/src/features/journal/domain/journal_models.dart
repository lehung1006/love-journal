enum MemoryCategory {
  trip,
  birthday,
  daily,
  milestone,
  anniversary;

  static MemoryCategory fromJson(String value) {
    return MemoryCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => MemoryCategory.daily,
    );
  }

  String get label => switch (this) {
    MemoryCategory.trip => 'Chuyến đi',
    MemoryCategory.birthday => 'Sinh nhật',
    MemoryCategory.daily => 'Đời thường',
    MemoryCategory.milestone => 'Dấu mốc',
    MemoryCategory.anniversary => 'Kỷ niệm',
  };
}

enum RelationshipPhase {
  year1,
  year2,
  year3;

  static RelationshipPhase fromJson(String value) {
    return switch (value) {
      'year_1' => RelationshipPhase.year1,
      'year_2' => RelationshipPhase.year2,
      'year_3' => RelationshipPhase.year3,
      _ => RelationshipPhase.year1,
    };
  }

  String get label => switch (this) {
    RelationshipPhase.year1 => 'Năm đầu tiên',
    RelationshipPhase.year2 => 'Năm thứ hai',
    RelationshipPhase.year3 => 'Năm thứ ba',
  };
}

enum MemoryMediaType {
  image,
  video;

  static MemoryMediaType fromJson(String value) {
    return value == 'video' ? MemoryMediaType.video : MemoryMediaType.image;
  }
}

enum LetterStatus {
  open,
  locked,
  opened;

  static LetterStatus fromJson(String value) {
    return LetterStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => LetterStatus.open,
    );
  }
}

enum LetterCoverStyle {
  rose,
  paper,
  night;

  static LetterCoverStyle fromJson(String? value) {
    return LetterCoverStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => LetterCoverStyle.paper,
    );
  }
}

class MemoryMedia {
  const MemoryMedia({
    required this.id,
    required this.type,
    required this.uri,
    this.width,
    this.height,
    this.alt,
  });

  factory MemoryMedia.fromJson(Map<String, dynamic> json) {
    return MemoryMedia(
      id: json['id'] as String,
      type: MemoryMediaType.fromJson(json['type'] as String? ?? 'image'),
      uri: json['uri'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      alt: json['alt'] as String?,
    );
  }

  final String id;
  final MemoryMediaType type;
  final String uri;
  final int? width;
  final int? height;
  final String? alt;
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

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      category: MemoryCategory.fromJson(json['category'] as String? ?? 'daily'),
      phase: RelationshipPhase.fromJson(json['phase'] as String? ?? 'year_1'),
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['placeId'] as String?,
      media: (json['media'] as List<dynamic>? ?? const [])
          .map((item) => MemoryMedia.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      coverMediaId: json['coverMediaId'] as String?,
      story: json['story'] as String,
      favoriteMoment: json['favoriteMoment'] as String?,
      messageForHer: json['messageForHer'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final DateTime date;
  final MemoryCategory category;
  final RelationshipPhase phase;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final List<MemoryMedia> media;
  final String? coverMediaId;
  final String story;
  final String? favoriteMoment;
  final String? messageForHer;
  final String? voiceNoteUrl;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryMedia? get coverMedia {
    if (media.isEmpty) {
      return null;
    }
    if (coverMediaId == null) {
      return media.first;
    }
    return media.firstWhere(
      (item) => item.id == coverMediaId,
      orElse: () => media.first,
    );
  }
}

class Letter {
  const Letter({
    required this.id,
    required this.title,
    required this.occasion,
    required this.body,
    required this.status,
    required this.coverStyle,
    this.preview,
    this.unlockAt,
    this.openedAt,
    this.pinToHome = false,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    final unlockAt = json['unlockAt'] as String?;
    final openedAt = json['openedAt'] as String?;

    return Letter(
      id: json['id'] as String,
      title: json['title'] as String,
      occasion: json['occasion'] as String,
      preview: json['preview'] as String?,
      body: json['body'] as String,
      unlockAt: unlockAt == null ? null : DateTime.parse(unlockAt),
      status: LetterStatus.fromJson(json['status'] as String? ?? 'open'),
      openedAt: openedAt == null ? null : DateTime.parse(openedAt),
      pinToHome: json['pinToHome'] as bool? ?? false,
      coverStyle: LetterCoverStyle.fromJson(json['coverStyle'] as String?),
    );
  }

  final String id;
  final String title;
  final String occasion;
  final String? preview;
  final String body;
  final DateTime? unlockAt;
  final LetterStatus status;
  final DateTime? openedAt;
  final bool pinToHome;
  final LetterCoverStyle coverStyle;

  bool isLocked(DateTime now) {
    if (status != LetterStatus.locked) {
      return false;
    }
    final unlockAt = this.unlockAt;
    if (unlockAt == null) {
      return true;
    }
    final unlockDay = DateTime(unlockAt.year, unlockAt.month, unlockAt.day);
    final today = DateTime(now.year, now.month, now.day);
    return unlockDay.isAfter(today);
  }
}

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

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
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
}

class JournalData {
  const JournalData({
    required this.memories,
    required this.letters,
    required this.places,
  });

  final List<Memory> memories;
  final List<Letter> letters;
  final List<Place> places;

  Memory memoryById(String id) {
    return memories.firstWhere((memory) => memory.id == id);
  }

  Letter letterById(String id) {
    return letters.firstWhere((letter) => letter.id == id);
  }

  List<Memory> memoriesForPlace(Place place) {
    return memories
        .where((memory) => place.memoryIds.contains(memory.id))
        .toList(growable: false);
  }

  Memory get featuredMemory {
    return memories.firstWhere(
      (memory) => memory.isFeatured,
      orElse: () => memories.first,
    );
  }

  Letter? nextHomeLetter(DateTime now) {
    final pinned = letters.where((letter) => letter.pinToHome).toList();
    if (pinned.isNotEmpty) {
      return pinned.first;
    }
    if (letters.isEmpty) {
      return null;
    }
    return letters.first;
  }
}
