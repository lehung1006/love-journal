import '../../domain/entities/journal_entities.dart';
import '../../domain/services/memory_attachment_service.dart';

class DeviceMemoryAttachmentService implements MemoryAttachmentService {
  @override
  Future<void> cancelRecording() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<MemoryVoiceMessage>> pickAudioFiles() async => const [];

  @override
  Future<List<MemoryMedia>> pickImages() async => const [];

  @override
  Future<MemoryMediaImportResult> pickVideos({
    required int maxCount,
    MemoryAttachmentImportProgressCallback? onProgress,
  }) async {
    return MemoryMediaImportResult(media: const [], selectedCount: 0);
  }

  @override
  Future<bool> startRecording() async => false;

  @override
  Future<MemoryVoiceMessage?> stopRecording() async => null;

  @override
  Future<MemoryMedia?> takePhoto() async => null;
}
