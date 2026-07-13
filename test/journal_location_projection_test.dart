import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_love_journal/src/features/journal/domain/entities/journal_entities.dart';

void main() {
  test('Map projection groups only visible located memories', () {
    final now = DateTime(2026, 7, 11);
    final location = MemoryLocation(
      id: 'location-1',
      displayName: 'Nơi của tụi mình',
      latitude: 10.7769,
      longitude: 106.7009,
      source: MemoryLocationSource.manual,
      createdAt: now,
      updatedAt: now,
    );
    final data = JournalData(
      memories: [
        _memory(id: 'one', now: now, locationId: location.id),
        _memory(id: 'two', now: now, locationId: location.id),
        _memory(id: 'without-location', now: now),
        _memory(
          id: 'deleted',
          now: now,
          locationId: location.id,
          deletedAt: now,
        ),
      ],
      letters: const [],
      places: const [],
      locations: [location],
    );

    final groups = data.mapLocationGroups;

    expect(groups, hasLength(1));
    expect(groups.single.location.id, location.id);
    expect(
      groups.single.memories.map((memory) => memory.id),
      orderedEquals(['one', 'two']),
    );
  });
}

Memory _memory({
  required String id,
  required DateTime now,
  String? locationId,
  DateTime? deletedAt,
}) {
  return Memory(
    id: id,
    title: id,
    date: now,
    category: MemoryCategory.daily,
    phase: RelationshipPhase.year3,
    locationId: locationId,
    media: const [],
    story: 'Một kỷ niệm nhỏ.',
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}
