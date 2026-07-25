import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/modal_bottom_sheet.dart';
import '../../application/providers/journal_providers.dart';
import '../../application/providers/memory_attachment_providers.dart';
import '../../application/state/memory_composer_controller.dart';
import '../../application/state/memory_composer_state.dart';
import '../../domain/entities/journal_entities.dart';
import '../../domain/services/memory_attachment_service.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';
import '../journal_localizations.dart';

class MemoryFormScreen extends ConsumerStatefulWidget {
  const MemoryFormScreen({
    required this.data,
    required this.onSubmit,
    required this.onCreateTag,
    required this.onPickLocation,
    required this.onSaved,
    this.memory,
    super.key,
  });

  final JournalData data;
  final Memory? memory;
  final Future<Memory> Function(MemoryDraft draft) onSubmit;
  final Future<MemoryTag> Function(String name) onCreateTag;
  final Future<MemoryLocationSelection?> Function(
    MemoryLocationSelection? current,
  )
  onPickLocation;
  final ValueChanged<Memory> onSaved;

  @override
  ConsumerState<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends ConsumerState<MemoryFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _storyController;
  late final FocusNode _storyFocusNode;
  late final String _draftId;
  late List<MemoryTag> _tags;
  bool _resumePromptShown = false;
  _VideoImportViewState? _videoImport;

  bool get _isEditing => widget.memory != null;

  @override
  void initState() {
    super.initState();
    final memory = widget.memory;
    _draftId = memory == null ? 'new-memory' : 'edit-${memory.id}';
    _tags = [...widget.data.tags];
    _titleController = TextEditingController(text: memory?.title ?? '');
    _storyController = TextEditingController(text: _initialStory(memory));
    _storyFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final defaultTagId = memory?.effectiveTagId ?? _defaultTagId;
      final baseDraft = memory == null
          ? MemoryComposerDraft.empty(
              now: DateTime.now(),
              primaryTagId: defaultTagId,
            )
          : MemoryComposerDraft.fromMemory(memory);
      await ref
          .read(memoryComposerControllerProvider(_draftId).notifier)
          .initialize(baseDraft);
      if (!mounted) {
        return;
      }
      final state = ref.read(memoryComposerControllerProvider(_draftId));
      _syncTextFields(state.draft);
      if (state.restorableDraft != null) {
        _showResumeDraftSheet();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MemoryFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final tag in widget.data.tags) {
      if (!_tags.any((item) => item.id == tag.id)) {
        _tags.add(tag);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _storyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = memoryComposerControllerProvider(_draftId);
    final state = ref.watch(provider);
    final draft = state.draft;
    final tag = _tagForId(draft.primaryTagId);
    final locationName = _locationName(draft.locationSelection);
    final generatedTitle = resolveMemoryTitle(
      draft: draft,
      tagName: _tagLabel(tag),
      locationName: locationName,
    );
    final isSubmitting = state.status == MemoryComposerStatus.submitting;
    final videoImport = _videoImport;

    return PopScope(
      canPop: videoImport == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(ref.read(provider.notifier).saveNow());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            AppScaffold(
              safeBottom: false,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.xs,
                      AppSpacing.xs,
                      0,
                    ),
                    child: MemoryComposerTopBar(
                      isEditing: _isEditing,
                      status: state.status,
                      onClose: _closeComposer,
                      onEditTitle: () => _showTitleSheet(generatedTitle),
                    ),
                  ),
                  Expanded(
                    child: state.isInitialized
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenX,
                              AppSpacing.s,
                              AppSpacing.screenX,
                              AppSpacing.xxl,
                            ),
                            children: [
                              MemoryComposerMetadata(
                                dateLabel: formatDate(draft.date),
                                tagLabel: _tagLabel(tag),
                                locationLabel: locationName ?? 'Thêm địa điểm',
                                onDateTap: _pickDate,
                                onTagTap: _showTagSheet,
                                onLocationTap: _pickLocation,
                                onLocationClear: draft.locationSelection == null
                                    ? null
                                    : () => ref
                                          .read(provider.notifier)
                                          .setLocation(null),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              Text(
                                generatedTitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleL.copyWith(
                                  color: AppColors.ink,
                                ),
                              ),
                              if (!draft.hasMeaningfulContent)
                                MemoryComposerEmptyPrompt(
                                  onMedia: () => _showMediaSourceSheet(),
                                  onStory: _focusStory,
                                  onVoice: _showVoiceSourceSheet,
                                )
                              else
                                const SizedBox(height: AppSpacing.xl),
                              MemoryComposerStoryField(
                                controller: _storyController,
                                focusNode: _storyFocusNode,
                                onChanged: ref.read(provider.notifier).setStory,
                              ),
                              if (draft.voiceMessages.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.l),
                                MemoryComposerVoiceStrip(
                                  messages: draft.voiceMessages,
                                  onRemove: ref
                                      .read(provider.notifier)
                                      .removeVoiceMessage,
                                ),
                              ],
                              if (draft.mediaGroups.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xl),
                                for (
                                  var index = 0;
                                  index < draft.mediaGroups.length;
                                  index++
                                )
                                  MemoryComposerMediaGroupView(
                                    key: ValueKey(draft.mediaGroups[index].id),
                                    group: draft.mediaGroups[index],
                                    index: index,
                                    canMoveUp: index > 0,
                                    canMoveDown:
                                        index < draft.mediaGroups.length - 1,
                                    onTitleChanged: (value) => ref
                                        .read(provider.notifier)
                                        .updateGroupTitle(
                                          draft.mediaGroups[index].id,
                                          value,
                                        ),
                                    onNoteChanged: (value) => ref
                                        .read(provider.notifier)
                                        .updateGroupNote(
                                          draft.mediaGroups[index].id,
                                          value,
                                        ),
                                    onAddMedia: () => _showMediaSourceSheet(
                                      groupId: draft.mediaGroups[index].id,
                                    ),
                                    onOpenMedia: (mediaId) {
                                      final media =
                                          draft.mediaGroups[index].items;
                                      final mediaIndex = media.indexWhere(
                                        (item) => item.id == mediaId,
                                      );
                                      unawaited(
                                        showMemoryMediaViewer(
                                          context: context,
                                          media: media,
                                          initialIndex: mediaIndex,
                                        ),
                                      );
                                    },
                                    onRemoveMedia: (mediaId) => ref
                                        .read(provider.notifier)
                                        .removeMedia(
                                          draft.mediaGroups[index].id,
                                          mediaId,
                                        ),
                                    onRemoveGroup: () => ref
                                        .read(provider.notifier)
                                        .removeMediaGroup(
                                          draft.mediaGroups[index].id,
                                        ),
                                    onMoveUp: () => ref
                                        .read(provider.notifier)
                                        .moveMediaGroup(
                                          draft.mediaGroups[index].id,
                                          -1,
                                        ),
                                    onMoveDown: () => ref
                                        .read(provider.notifier)
                                        .moveMediaGroup(
                                          draft.mediaGroups[index].id,
                                          1,
                                        ),
                                  ),
                              ],
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  MemoryComposerBottomBar(
                    canSubmit: state.canSubmit,
                    isSubmitting: isSubmitting,
                    canAddGroup:
                        draft.mediaGroups.length <
                        MemoryComposerController.maxMediaGroups,
                    canAddVoice:
                        draft.voiceMessages.length <
                        MemoryComposerController.maxVoiceMessages,
                    onMedia: () => _showMediaSourceSheet(),
                    onStory: _focusStory,
                    onVoice: _showVoiceSourceSheet,
                    onSubmit: () => _submit(generatedTitle),
                  ),
                ],
              ),
            ),
            if (videoImport != null)
              Positioned.fill(
                child: MemoryComposerMediaImportOverlay(
                  completedFiles: videoImport.completedFiles,
                  totalFiles: videoImport.totalFiles,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _defaultTagId {
    if (_tags.isNotEmpty) {
      final dailyId = MemoryTag.systemIdForCategory(MemoryCategory.daily);
      return _tags.any((tag) => tag.id == dailyId) ? dailyId : _tags.first.id;
    }
    return MemoryTag.systemIdForCategory(MemoryCategory.daily);
  }

  String _initialStory(Memory? memory) {
    if (memory == null) {
      return '';
    }
    final note = memory.note?.trim();
    return [
      memory.story.trim(),
      if (note != null && note.isNotEmpty) note,
    ].where((part) => part.isNotEmpty).join('\n\n');
  }

  MemoryTag? _tagForId(String id) {
    for (final tag in _tags) {
      if (tag.id == id) {
        return tag;
      }
    }
    return null;
  }

  String _tagLabel(MemoryTag? tag) {
    if (tag == null) {
      return 'Đời thường';
    }
    return memoryTagLabel(context.l10n, tag);
  }

  String? _locationName(MemoryLocationSelection? selection) {
    if (selection == null) {
      return null;
    }
    final draft = selection.draftLocation;
    if (draft != null) {
      return draft.displayName;
    }
    return widget.data
        .locationByIdOrNull(selection.existingLocationId)
        ?.displayName;
  }

  void _syncTextFields(MemoryComposerDraft draft) {
    final title = draft.titleOverride ?? '';
    if (_titleController.text != title) {
      _titleController.text = title;
    }
    if (_storyController.text != draft.story) {
      _storyController.text = draft.story;
    }
  }

  void _focusStory() {
    _storyFocusNode.requestFocus();
  }

  Future<void> _closeComposer() async {
    await ref
        .read(memoryComposerControllerProvider(_draftId).notifier)
        .saveNow();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final provider = memoryComposerControllerProvider(_draftId);
    final current = ref.read(provider).draft.date;
    final picked = await showUnfocusedModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => MemoryComposerDatePicker(
        initialDate: current,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        onSelected: (date) => Navigator.of(context).pop(date),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
    if (picked != null && mounted) {
      ref
          .read(provider.notifier)
          .setDate(
            DateTime(
              picked.year,
              picked.month,
              picked.day,
              current.hour,
              current.minute,
            ),
          );
    }
  }

  Future<void> _pickLocation() async {
    final provider = memoryComposerControllerProvider(_draftId);
    final current = ref.read(provider).draft.locationSelection;
    final selected = await widget.onPickLocation(current);
    if (!mounted || selected == null) {
      return;
    }
    ref.read(provider.notifier).setLocation(selected);
  }

  Future<void> _showTagSheet() async {
    final provider = memoryComposerControllerProvider(_draftId);
    final selectedId = ref.read(provider).draft.primaryTagId;
    final selection = await showUnfocusedModalBottomSheet<String>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComposerSheetHandle(),
            Text(
              'Nhãn cho kỷ niệm',
              style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in _tags)
                  ChoiceChip(
                    label: Text(_tagLabel(tag)),
                    selected: tag.id == selectedId,
                    onSelected: (_) => Navigator.of(context).pop(tag.id),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nhãn mới'),
                  onPressed: () => Navigator.of(context).pop('__create__'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (!mounted || selection == null) {
      return;
    }
    if (selection == '__create__') {
      await _showCreateTagSheet();
      return;
    }
    ref.read(provider.notifier).setTag(selection);
  }

  Future<void> _showCreateTagSheet() async {
    final controller = TextEditingController();
    final name = await showUnfocusedModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComposerSheetHandle(),
            Text(
              'Tạo nhãn mới',
              style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ví dụ: Hẹn hò'),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('Tạo nhãn'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.trim().isEmpty) {
      return;
    }
    try {
      final tag = await widget.onCreateTag(name);
      if (!mounted) {
        return;
      }
      if (!_tags.any((item) => item.id == tag.id)) {
        setState(() => _tags = [..._tags, tag]);
      }
      ref
          .read(memoryComposerControllerProvider(_draftId).notifier)
          .setTag(tag.id);
    } catch (error) {
      if (mounted) {
        _showError('Chưa thể tạo nhãn. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _showTitleSheet(String generatedTitle) async {
    _titleController.text =
        ref
            .read(memoryComposerControllerProvider(_draftId))
            .draft
            .titleOverride ??
        '';
    final result = await showUnfocusedModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComposerSheetHandle(),
            Text(
              'Tên kỷ niệm',
              style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Để trống để dùng tên gợi ý: $generatedTitle',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Tên bạn muốn nhớ'),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(_titleController.text),
                child: const Text('Xong'),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      ref
          .read(memoryComposerControllerProvider(_draftId).notifier)
          .setTitle(result);
    }
  }

  Future<void> _showMediaSourceSheet({String? groupId}) async {
    if (_videoImport != null) {
      return;
    }
    final currentDraft = ref
        .read(memoryComposerControllerProvider(_draftId))
        .draft;
    final remainingVideos =
        MemoryComposerController.maxVideos - currentDraft.videoCount;
    final source = await showUnfocusedModalBottomSheet<_MediaSource>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComposerSheetHandle(),
            Text(
              'Thêm vào kỷ niệm',
              style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.m),
            ComposerSourceOption(
              icon: Icons.photo_library_outlined,
              title: 'Chọn ảnh',
              subtitle: 'Mở thư viện ảnh trên thiết bị',
              onTap: () => Navigator.of(context).pop(_MediaSource.images),
            ),
            const SizedBox(height: AppSpacing.s),
            ComposerSourceOption(
              icon: Icons.video_library_outlined,
              title: remainingVideos > 0 ? 'Chọn video' : 'Đã đủ 3 video',
              subtitle: remainingVideos > 0
                  ? 'Có thể chọn cùng lúc · còn $remainingVideos/3 video'
                  : 'Mỗi kỷ niệm có tối đa 3 video',
              onTap: remainingVideos > 0
                  ? () => Navigator.of(context).pop(_MediaSource.video)
                  : null,
            ),
            const SizedBox(height: AppSpacing.s),
            ComposerSourceOption(
              icon: Icons.photo_camera_outlined,
              title: 'Chụp ảnh',
              subtitle: 'Mở camera và lưu khoảnh khắc mới',
              onTap: () => Navigator.of(context).pop(_MediaSource.camera),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) {
      return;
    }
    Object? importError;
    MemoryMediaImportResult? videoResult;
    var media = const <MemoryMedia>[];
    try {
      final service = ref.read(memoryAttachmentServiceProvider);
      switch (source) {
        case _MediaSource.images:
          media = await service.pickImages();
        case _MediaSource.video:
          final latestDraft = ref
              .read(memoryComposerControllerProvider(_draftId))
              .draft;
          final availableSlots =
              MemoryComposerController.maxVideos - latestDraft.videoCount;
          if (availableSlots <= 0) {
            break;
          }
          _updateVideoImportProgress(
            const MemoryAttachmentImportProgress(
              completedFiles: 0,
              totalFiles: 0,
            ),
          );
          await WidgetsBinding.instance.endOfFrame;
          if (!mounted) {
            return;
          }
          videoResult = await service.pickVideos(
            maxCount: availableSlots,
            onProgress: _updateVideoImportProgress,
          );
          media = videoResult.media;
        case _MediaSource.camera:
          final item = await service.takePhoto();
          media = item == null ? const [] : [item];
      }
    } catch (error) {
      importError = error;
    } finally {
      if (mounted && _videoImport != null) {
        setState(() => _videoImport = null);
      }
    }
    if (!mounted) {
      return;
    }
    if (importError != null) {
      _showError('Chưa thể mở media trên thiết bị. Vui lòng thử lại.');
      return;
    }
    if (media.isEmpty) {
      return;
    }
    final controller = ref.read(
      memoryComposerControllerProvider(_draftId).notifier,
    );
    if (groupId == null) {
      controller.addMediaGroup(media);
    } else {
      controller.addMedia(groupId, media);
    }
    if (videoResult?.wasLimited == true) {
      _showError(
        'Mỗi kỷ niệm chỉ có tối đa 3 video. '
        '${videoResult!.skippedByLimit} video vượt giới hạn đã được bỏ qua.',
      );
    }
  }

  void _updateVideoImportProgress(MemoryAttachmentImportProgress progress) {
    if (!mounted) {
      return;
    }
    setState(
      () => _videoImport = _VideoImportViewState(
        completedFiles: progress.completedFiles,
        totalFiles: progress.totalFiles,
      ),
    );
  }

  Future<void> _showVoiceSourceSheet() async {
    final source =
        await showUnfocusedModalBottomSheet<MemoryVoiceMessageSource>(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX,
              AppSpacing.m,
              AppSpacing.screenX,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ComposerSheetHandle(),
                Text(
                  'Lời nhắn cho khoảnh khắc này',
                  style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.m),
                ComposerSourceOption(
                  icon: Icons.audio_file_outlined,
                  title: 'Chọn file có sẵn',
                  subtitle: 'Dùng một đoạn âm thanh trên thiết bị',
                  onTap: () => Navigator.of(
                    context,
                  ).pop(MemoryVoiceMessageSource.imported),
                ),
                const SizedBox(height: AppSpacing.s),
                ComposerSourceOption(
                  icon: Icons.mic_rounded,
                  title: 'Ghi âm ngay',
                  subtitle: 'Mở giao diện ghi âm',
                  onTap: () => Navigator.of(
                    context,
                  ).pop(MemoryVoiceMessageSource.recorded),
                ),
              ],
            ),
          ),
        );
    if (!mounted || source == null) {
      return;
    }
    if (source == MemoryVoiceMessageSource.recorded) {
      await _showRecorderSheet();
    } else {
      await _pickAudioFiles();
    }
  }

  Future<void> _showRecorderSheet() async {
    final service = ref.read(memoryAttachmentServiceProvider);
    try {
      if (!await service.startRecording()) {
        if (mounted) {
          _showError('Ứng dụng cần quyền micro để ghi lời nhắn.');
        }
        return;
      }
    } catch (error) {
      if (mounted) {
        _showError('Chưa thể bắt đầu ghi âm. Vui lòng thử lại.');
      }
      return;
    }
    if (!mounted) {
      await service.cancelRecording();
      return;
    }
    final confirmed = await showUnfocusedModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ComposerSheetHandle(),
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: AppColors.rose,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Đang ghi lời nhắn',
              style: AppTextStyles.titleM.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chạm hoàn tất khi bạn đã nói xong.',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Hoàn tất'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      await service.cancelRecording();
      return;
    }
    try {
      if (confirmed == true) {
        final message = await service.stopRecording();
        if (message != null && mounted) {
          ref
              .read(memoryComposerControllerProvider(_draftId).notifier)
              .addVoiceMessage(message);
        }
      } else {
        await service.cancelRecording();
      }
    } catch (error) {
      await service.cancelRecording();
      if (mounted) {
        _showError('Chưa thể lưu đoạn ghi âm. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _pickAudioFiles() async {
    try {
      final messages = await ref
          .read(memoryAttachmentServiceProvider)
          .pickAudioFiles();
      if (!mounted) {
        return;
      }
      final controller = ref.read(
        memoryComposerControllerProvider(_draftId).notifier,
      );
      for (final message in messages) {
        controller.addVoiceMessage(message);
      }
    } catch (error) {
      if (mounted) {
        _showError('Chưa thể mở file âm thanh. Vui lòng thử lại.');
      }
    }
  }

  Future<void> _showResumeDraftSheet() async {
    if (_resumePromptShown || !mounted) {
      return;
    }
    _resumePromptShown = true;
    final shouldResume = await showUnfocusedModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.m,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComposerSheetHandle(),
            Text(
              'Tiếp tục bản nháp?',
              style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kỷ niệm bạn đang viết lần trước vẫn còn ở đây.',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Bỏ bản nháp'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Tiếp tục'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    final controller = ref.read(
      memoryComposerControllerProvider(_draftId).notifier,
    );
    if (shouldResume == true) {
      controller.resumeStoredDraft();
      _syncTextFields(
        ref.read(memoryComposerControllerProvider(_draftId)).draft,
      );
    } else {
      await controller.discardStoredDraft();
    }
  }

  Future<void> _submit(String generatedTitle) async {
    final state = ref.read(memoryComposerControllerProvider(_draftId));
    if (!state.draft.hasMeaningfulContent) {
      _showError('Hãy thêm một dòng, ảnh/video hoặc lời nhắn trước khi lưu.');
      return;
    }
    final memory = await ref
        .read(memoryComposerControllerProvider(_draftId).notifier)
        .submit(title: generatedTitle, onSubmit: widget.onSubmit);
    if (!mounted) {
      return;
    }
    if (memory == null) {
      _showError('Chưa thể lưu kỷ niệm. Bản nháp của bạn vẫn được giữ lại.');
      return;
    }
    widget.onSaved(memory);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _MediaSource { images, video, camera }

class _VideoImportViewState {
  const _VideoImportViewState({
    required this.completedFiles,
    required this.totalFiles,
  });

  final int completedFiles;
  final int totalFiles;
}
