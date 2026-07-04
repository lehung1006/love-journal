enum MemoryCategory {
  trip,
  birthday,
  daily,
  milestone,
  anniversary;

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

  String get label => switch (this) {
    RelationshipPhase.year1 => 'Năm đầu tiên',
    RelationshipPhase.year2 => 'Năm thứ hai',
    RelationshipPhase.year3 => 'Năm thứ ba',
  };
}

enum MemoryMediaType { image, video }

enum LetterStatus { open, locked, opened }

enum LetterCoverStyle { rose, paper, night }
