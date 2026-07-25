import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_thumbnail_gen/video_thumbnail_gen.dart';

import '../../domain/entities/journal_entities.dart';
import '../../domain/services/memory_attachment_service.dart';

class DeviceMemoryAttachmentService implements MemoryAttachmentService {
  DeviceMemoryAttachmentService({
    ImagePicker? imagePicker,
    AudioRecorder? audioRecorder,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _audioRecorder = audioRecorder ?? AudioRecorder();

  final ImagePicker _imagePicker;
  final AudioRecorder _audioRecorder;
  DateTime? _recordingStartedAt;
  String? _recordingPath;

  @override
  Future<List<MemoryMedia>> pickImages() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 92);
    final media = <MemoryMedia>[];
    for (final file in files) {
      media.add(await _persistMedia(file, MemoryMediaType.image));
    }
    return media;
  }

  @override
  Future<MemoryMediaImportResult> pickVideos({
    required int maxCount,
    MemoryAttachmentImportProgressCallback? onProgress,
  }) async {
    if (maxCount <= 0) {
      return MemoryMediaImportResult(media: const [], selectedCount: 0);
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null) {
      return MemoryMediaImportResult(media: const [], selectedCount: 0);
    }

    final selectedFiles = result.files
        .where((file) => file.path != null)
        .toList(growable: false);
    final acceptedFiles = selectedFiles.take(maxCount).toList(growable: false);
    if (acceptedFiles.isNotEmpty) {
      onProgress?.call(
        MemoryAttachmentImportProgress(
          completedFiles: 0,
          totalFiles: acceptedFiles.length,
        ),
      );
    }

    final media = <MemoryMedia>[];
    for (var index = 0; index < acceptedFiles.length; index++) {
      media.add(
        await _persistMediaPath(
          acceptedFiles[index].path!,
          MemoryMediaType.video,
        ),
      );
      onProgress?.call(
        MemoryAttachmentImportProgress(
          completedFiles: index + 1,
          totalFiles: acceptedFiles.length,
        ),
      );
    }
    return MemoryMediaImportResult(
      media: media,
      selectedCount: selectedFiles.length,
    );
  }

  @override
  Future<MemoryMedia?> takePhoto() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (file == null) {
      return null;
    }
    return _persistMedia(file, MemoryMediaType.image);
  }

  @override
  Future<List<MemoryVoiceMessage>> pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null) {
      return const [];
    }
    final messages = <MemoryVoiceMessage>[];
    for (final file in result.files) {
      final sourcePath = file.path;
      if (sourcePath == null) {
        continue;
      }
      final now = DateTime.now();
      final uri = await _persistFile(
        sourcePath,
        id: 'voice-${now.microsecondsSinceEpoch}',
        fallbackExtension: '.m4a',
      );
      messages.add(
        MemoryVoiceMessage(
          id: 'voice-${now.microsecondsSinceEpoch}',
          uri: uri,
          source: MemoryVoiceMessageSource.imported,
          fileName: file.name,
          title: 'Lời nhắn cho khoảnh khắc này',
          createdAt: now,
        ),
      );
    }
    return messages;
  }

  @override
  Future<bool> startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      return false;
    }
    final now = DateTime.now();
    final directory = await _attachmentsDirectory();
    final destination = path.join(
      directory.path,
      'voice-${now.microsecondsSinceEpoch}.m4a',
    );
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: destination,
    );
    _recordingStartedAt = now;
    _recordingPath = destination;
    return true;
  }

  @override
  Future<MemoryVoiceMessage?> stopRecording() async {
    final resultPath = await _audioRecorder.stop();
    final startedAt = _recordingStartedAt;
    final fallbackPath = _recordingPath;
    _recordingStartedAt = null;
    _recordingPath = null;
    final uri = resultPath ?? fallbackPath;
    if (uri == null) {
      return null;
    }
    final now = DateTime.now();
    return MemoryVoiceMessage(
      id: 'voice-${now.microsecondsSinceEpoch}',
      uri: uri,
      source: MemoryVoiceMessageSource.recorded,
      title: 'Lời nhắn cho khoảnh khắc này',
      durationSeconds: startedAt == null
          ? null
          : now.difference(startedAt).inSeconds,
      createdAt: now,
    );
  }

  @override
  Future<void> cancelRecording() async {
    await _audioRecorder.cancel();
    final destination = _recordingPath;
    _recordingStartedAt = null;
    _recordingPath = null;
    if (destination != null) {
      final file = File(destination);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> dispose() => _audioRecorder.dispose();

  Future<MemoryMedia> _persistMedia(XFile file, MemoryMediaType type) async {
    return _persistMediaPath(file.path, type);
  }

  Future<MemoryMedia> _persistMediaPath(
    String sourcePath,
    MemoryMediaType type,
  ) async {
    final now = DateTime.now();
    final id = 'media-${now.microsecondsSinceEpoch}';
    final uri = await _persistFile(
      sourcePath,
      id: id,
      fallbackExtension: type == MemoryMediaType.image ? '.jpg' : '.mp4',
    );
    return MemoryMedia(
      id: id,
      type: type,
      uri: uri,
      thumbnailUri: type == MemoryMediaType.video
          ? await _createVideoThumbnail(uri, id: id)
          : null,
    );
  }

  Future<String?> _createVideoThumbnail(
    String videoPath, {
    required String id,
  }) async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 78,
        timeMs: 0,
      );
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      final directory = await _attachmentsDirectory();
      final destination = path.join(directory.path, '$id-thumbnail.jpg');
      await File(destination).writeAsBytes(bytes, flush: true);
      return destination;
    } catch (_) {
      return null;
    }
  }

  Future<String> _persistFile(
    String sourcePath, {
    required String id,
    required String fallbackExtension,
  }) async {
    final extension = path.extension(sourcePath);
    final directory = await _attachmentsDirectory();
    final destination = path.join(
      directory.path,
      '$id${extension.isEmpty ? fallbackExtension : extension}',
    );
    await File(sourcePath).copy(destination);
    return destination;
  }

  Future<Directory> _attachmentsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(root.path, 'memory_attachments'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
