import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/device_memory_attachment_service.dart';
import '../../domain/services/memory_attachment_service.dart';

final memoryAttachmentServiceProvider = Provider<MemoryAttachmentService>((
  ref,
) {
  final service = DeviceMemoryAttachmentService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});
