import '../../domain/entities/journal_entities.dart';
import '../../domain/repositories/journal_repository.dart';
import '../data_sources/journal_api_data_source.dart';
import '../dtos/letter_dto.dart';
import '../dtos/memory_dto.dart';
import '../dtos/place_dto.dart';

class JournalRepositoryImpl implements JournalRepository {
  const JournalRepositoryImpl(this._dataSource);

  final JournalApiDataSource _dataSource;

  @override
  Future<JournalData> fetchJournal() async {
    final memoriesJson = await _dataSource.fetchMemories();
    final lettersJson = await _dataSource.fetchLetters();
    final placesJson = await _dataSource.fetchPlaces();

    final memories =
        memoriesJson
            .map(MemoryDto.fromJson)
            .map((dto) => dto.toDomain())
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final letters = lettersJson
        .map(LetterDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);

    final places = placesJson
        .map(PlaceDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
    final seedTimestamp = DateTime(2026);
    final locations = places
        .map(
          (place) => MemoryLocation(
            id: place.id,
            displayName: place.name,
            latitude: place.latitude,
            longitude: place.longitude,
            source: MemoryLocationSource.manual,
            createdAt: seedTimestamp,
            updatedAt: seedTimestamp,
          ),
        )
        .toList(growable: false);

    return JournalData(
      memories: List.unmodifiable(memories),
      letters: List.unmodifiable(letters),
      places: List.unmodifiable(places),
      tags: _systemTags(),
      locations: List.unmodifiable(locations),
    );
  }

  List<MemoryTag> _systemTags() {
    final now = DateTime(2026);
    final colors = {
      MemoryCategory.trip: 'teal',
      MemoryCategory.birthday: 'rose',
      MemoryCategory.daily: 'moss',
      MemoryCategory.milestone: 'amber',
      MemoryCategory.anniversary: 'lavender',
    };

    return MemoryCategory.values
        .map((category) {
          return MemoryTag(
            id: MemoryTag.systemIdForCategory(category),
            name: category.name,
            colorKey: colors[category] ?? 'rose',
            isSystem: true,
            createdAt: now,
            updatedAt: now,
          );
        })
        .toList(growable: false);
  }
}
