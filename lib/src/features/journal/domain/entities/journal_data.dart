import 'letter.dart';
import 'memory.dart';
import 'place.dart';

class JournalData {
  const JournalData({
    required this.memories,
    required this.letters,
    required this.places,
    this.tags = const [],
  });

  final List<Memory> memories;
  final List<Letter> letters;
  final List<Place> places;
  final List<MemoryTag> tags;

  List<Memory> get visibleMemories {
    return memories
        .where((memory) => !memory.isDeleted)
        .toList(growable: false);
  }

  Memory memoryById(String id) {
    return visibleMemories.firstWhere((memory) => memory.id == id);
  }

  Letter letterById(String id) {
    return letters.firstWhere((letter) => letter.id == id);
  }

  List<Memory> memoriesForPlace(Place place) {
    return visibleMemories
        .where((memory) => place.memoryIds.contains(memory.id))
        .toList(growable: false);
  }

  Memory? get featuredMemoryOrNull {
    final available = visibleMemories;
    if (available.isEmpty) {
      return null;
    }
    return available.firstWhere(
      (memory) => memory.isFeatured,
      orElse: () => available.first,
    );
  }

  Memory get featuredMemory {
    final featured = featuredMemoryOrNull;
    if (featured == null) {
      throw StateError('No visible memories are available.');
    }
    return featured;
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

  MemoryTag tagById(String id) {
    return tags.firstWhere((tag) => tag.id == id);
  }

  MemoryTag? tagByIdOrNull(String id) {
    for (final tag in tags) {
      if (tag.id == id) {
        return tag;
      }
    }
    return null;
  }

  JournalData copyWith({
    List<Memory>? memories,
    List<Letter>? letters,
    List<Place>? places,
    List<MemoryTag>? tags,
  }) {
    return JournalData(
      memories: memories ?? this.memories,
      letters: letters ?? this.letters,
      places: places ?? this.places,
      tags: tags ?? this.tags,
    );
  }
}
