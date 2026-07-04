import '../../domain/entities/journal_enums.dart';

MemoryCategory memoryCategoryFromDto(String? value) {
  return MemoryCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => MemoryCategory.daily,
  );
}

RelationshipPhase relationshipPhaseFromDto(String? value) {
  return switch (value) {
    'year_1' => RelationshipPhase.year1,
    'year_2' => RelationshipPhase.year2,
    'year_3' => RelationshipPhase.year3,
    _ => RelationshipPhase.year1,
  };
}

MemoryMediaType memoryMediaTypeFromDto(String? value) {
  return value == 'video' ? MemoryMediaType.video : MemoryMediaType.image;
}

LetterStatus letterStatusFromDto(String? value) {
  return LetterStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => LetterStatus.open,
  );
}

LetterCoverStyle letterCoverStyleFromDto(String? value) {
  return LetterCoverStyle.values.firstWhere(
    (style) => style.name == value,
    orElse: () => LetterCoverStyle.paper,
  );
}
