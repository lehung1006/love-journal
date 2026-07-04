class JournalPreferences {
  const JournalPreferences({
    required this.hasSeenOpening,
    required this.openedLetterIds,
    required this.favoriteMemoryIds,
    this.lastViewedMemoryId,
  });

  const JournalPreferences.empty()
    : hasSeenOpening = false,
      openedLetterIds = const {},
      favoriteMemoryIds = const {},
      lastViewedMemoryId = null;

  final bool hasSeenOpening;
  final Set<String> openedLetterIds;
  final Set<String> favoriteMemoryIds;
  final String? lastViewedMemoryId;

  JournalPreferences copyWith({
    bool? hasSeenOpening,
    Set<String>? openedLetterIds,
    Set<String>? favoriteMemoryIds,
    String? lastViewedMemoryId,
  }) {
    return JournalPreferences(
      hasSeenOpening: hasSeenOpening ?? this.hasSeenOpening,
      openedLetterIds: openedLetterIds ?? this.openedLetterIds,
      favoriteMemoryIds: favoriteMemoryIds ?? this.favoriteMemoryIds,
      lastViewedMemoryId: lastViewedMemoryId ?? this.lastViewedMemoryId,
    );
  }
}
