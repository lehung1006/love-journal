import 'package:video_player/video_player.dart';

VideoPlayerController? createMemoryVideoController(String uri) {
  if (uri.startsWith('assets/')) {
    return VideoPlayerController.asset(uri);
  }

  final parsed = Uri.tryParse(uri);
  if (parsed != null && (parsed.scheme == 'http' || parsed.scheme == 'https')) {
    return VideoPlayerController.networkUrl(parsed);
  }
  return null;
}
