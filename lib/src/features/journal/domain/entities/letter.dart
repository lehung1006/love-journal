import 'journal_enums.dart';

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

  Letter copyWith({
    String? id,
    String? title,
    String? occasion,
    String? preview,
    String? body,
    DateTime? unlockAt,
    LetterStatus? status,
    DateTime? openedAt,
    bool? pinToHome,
    LetterCoverStyle? coverStyle,
  }) {
    return Letter(
      id: id ?? this.id,
      title: title ?? this.title,
      occasion: occasion ?? this.occasion,
      preview: preview ?? this.preview,
      body: body ?? this.body,
      unlockAt: unlockAt ?? this.unlockAt,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      pinToHome: pinToHome ?? this.pinToHome,
      coverStyle: coverStyle ?? this.coverStyle,
    );
  }
}
