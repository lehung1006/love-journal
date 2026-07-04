import '../entities/journal_data.dart';

abstract interface class JournalRepository {
  Future<JournalData> fetchJournal();
}
