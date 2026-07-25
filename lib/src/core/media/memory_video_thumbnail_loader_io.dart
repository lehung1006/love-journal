import 'dart:typed_data';

import 'package:video_thumbnail_gen/video_thumbnail_gen.dart';

Future<Uint8List?> loadMemoryVideoThumbnail(String uri) async {
  try {
    return await VideoThumbnail.thumbnailData(
      video: uri,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 640,
      quality: 78,
      timeMs: 0,
    );
  } catch (_) {
    return null;
  }
}
