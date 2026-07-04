import '../../domain/entities/letter.dart';
import 'journal_enum_dto_mapper.dart';

class LetterDto {
  const LetterDto({
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

  factory LetterDto.fromJson(Map<String, dynamic> json) {
    return LetterDto(
      id: json['id'] as String,
      title: json['title'] as String,
      occasion: json['occasion'] as String,
      preview: json['preview'] as String?,
      body: json['body'] as String,
      unlockAt: json['unlockAt'] as String?,
      status: json['status'] as String? ?? 'open',
      openedAt: json['openedAt'] as String?,
      pinToHome: json['pinToHome'] as bool? ?? false,
      coverStyle: json['coverStyle'] as String? ?? 'paper',
    );
  }

  final String id;
  final String title;
  final String occasion;
  final String? preview;
  final String body;
  final String? unlockAt;
  final String status;
  final String? openedAt;
  final bool pinToHome;
  final String coverStyle;

  Letter toDomain() {
    return Letter(
      id: id,
      title: title,
      occasion: occasion,
      preview: preview,
      body: body,
      unlockAt: unlockAt == null ? null : DateTime.parse(unlockAt!),
      status: letterStatusFromDto(status),
      openedAt: openedAt == null ? null : DateTime.parse(openedAt!),
      pinToHome: pinToHome,
      coverStyle: letterCoverStyleFromDto(coverStyle),
    );
  }
}
