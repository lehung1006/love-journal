import '../domain/journal_models.dart';

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String formatDateAndPlace(Memory memory) {
  final place = memory.locationName;
  if (place == null || place.isEmpty) {
    return formatDate(memory.date);
  }
  return '${formatDate(memory.date)} · $place';
}

String formatNumber(num value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

int dayDifference(DateTime from, DateTime to) {
  final start = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  return end.difference(start).inDays;
}

int daysUntil(DateTime target, DateTime now) {
  final targetDay = DateTime(target.year, target.month, target.day);
  final today = DateTime(now.year, now.month, now.day);
  return targetDay.difference(today).inDays;
}

String letterStateLabel(Letter letter, DateTime now, bool opened) {
  if (opened || letter.status == LetterStatus.opened) {
    return 'Đã mở';
  }
  if (letter.isLocked(now)) {
    final remaining = daysUntil(letter.unlockAt ?? now, now);
    if (remaining <= 0) {
      return 'Đã sẵn sàng';
    }
    return 'Còn $remaining ngày';
  }
  return 'Đã sẵn sàng';
}
