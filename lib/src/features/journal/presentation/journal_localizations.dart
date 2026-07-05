import 'package:flutter_love_journal/l10n/app_localizations.dart';

import '../domain/entities/journal_entities.dart';
import 'journal_formatters.dart';

String memoryCategoryLabel(AppLocalizations l10n, MemoryCategory category) {
  return switch (category) {
    MemoryCategory.trip => l10n.categoryTrip,
    MemoryCategory.birthday => l10n.categoryBirthday,
    MemoryCategory.daily => l10n.categoryDaily,
    MemoryCategory.milestone => l10n.categoryMilestone,
    MemoryCategory.anniversary => l10n.categoryAnniversary,
  };
}

String relationshipPhaseLabel(AppLocalizations l10n, RelationshipPhase phase) {
  return switch (phase) {
    RelationshipPhase.year1 => l10n.phaseYear1,
    RelationshipPhase.year2 => l10n.phaseYear2,
    RelationshipPhase.year3 => l10n.phaseYear3,
  };
}

String memoryTagLabel(AppLocalizations l10n, MemoryTag tag) {
  for (final category in MemoryCategory.values) {
    if (tag.id == MemoryTag.systemIdForCategory(category)) {
      return memoryCategoryLabel(l10n, category);
    }
  }
  return tag.name;
}

String memoryTagLabelById(
  AppLocalizations l10n,
  List<MemoryTag> tags,
  Memory memory,
) {
  for (final tag in tags) {
    if (tag.id == memory.effectiveTagId) {
      return memoryTagLabel(l10n, tag);
    }
  }
  return memoryCategoryLabel(l10n, memory.category);
}

String memoryMediaSummary(AppLocalizations l10n, Memory memory) {
  final images = memory.media
      .where((item) => item.type == MemoryMediaType.image)
      .length;
  final videos = memory.media
      .where((item) => item.type == MemoryMediaType.video)
      .length;
  final messages = memory.voiceMessages.length;
  final parts = <String>[];
  if (images > 0) {
    parts.add(l10n.mediaSummaryImages(images));
  }
  if (videos > 0) {
    parts.add(l10n.mediaSummaryVideos(videos));
  }
  if (messages > 0) {
    parts.add(l10n.mediaSummaryVoiceMessages(messages));
  }
  return parts.isEmpty ? l10n.mediaSummaryEmpty : parts.join(' · ');
}

String localizedLetterStateLabel(
  AppLocalizations l10n,
  Letter letter,
  DateTime now,
  bool opened,
) {
  if (opened || letter.status == LetterStatus.opened) {
    return l10n.letterOpened;
  }
  if (letter.isLocked(now)) {
    final remaining = daysUntil(letter.unlockAt ?? now, now);
    if (remaining <= 0) {
      return l10n.letterReady;
    }
    return l10n.letterDaysRemaining(remaining);
  }
  return l10n.letterReady;
}
