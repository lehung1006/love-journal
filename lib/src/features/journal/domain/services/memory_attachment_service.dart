import '../entities/journal_entities.dart';

typedef MemoryAttachmentImportProgressCallback =
    void Function(MemoryAttachmentImportProgress progress);

class MemoryAttachmentImportProgress {
  const MemoryAttachmentImportProgress({
    required this.completedFiles,
    required this.totalFiles,
  });

  final int completedFiles;
  final int totalFiles;

  int get currentFile {
    if (totalFiles == 0) {
      return 0;
    }
    return (completedFiles + 1).clamp(1, totalFiles);
  }
}

class MemoryMediaImportResult {
  MemoryMediaImportResult({
    required List<MemoryMedia> media,
    required this.selectedCount,
  }) : media = List.unmodifiable(media);

  final List<MemoryMedia> media;
  final int selectedCount;

  int get skippedByLimit =>
      (selectedCount - media.length).clamp(0, selectedCount);
  bool get wasLimited => skippedByLimit > 0;
}

abstract interface class MemoryAttachmentService {
  Future<List<MemoryMedia>> pickImages();

  Future<MemoryMediaImportResult> pickVideos({
    required int maxCount,
    MemoryAttachmentImportProgressCallback? onProgress,
  });

  Future<MemoryMedia?> takePhoto();

  Future<List<MemoryVoiceMessage>> pickAudioFiles();

  Future<bool> startRecording();

  Future<MemoryVoiceMessage?> stopRecording();

  Future<void> cancelRecording();

  Future<void> dispose();
}
