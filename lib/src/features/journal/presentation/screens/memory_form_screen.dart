import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/providers/journal_providers.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';
import '../journal_localizations.dart';

class MemoryFormScreen extends StatefulWidget {
  const MemoryFormScreen({
    required this.data,
    required this.onSubmit,
    required this.onCreateTag,
    this.memory,
    super.key,
  });

  final JournalData data;
  final Memory? memory;
  final Future<Memory> Function(MemoryDraft draft) onSubmit;
  final Future<MemoryTag> Function(String name) onCreateTag;

  @override
  State<MemoryFormScreen> createState() => _MemoryFormScreenState();
}

class _MemoryFormScreenState extends State<MemoryFormScreen> {
  static const _maxVoiceMessages = 3;
  static const _maxMediaGroups = 3;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _storyController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;

  late List<MemoryTag> _tags;
  late DateTime _selectedDate;
  late String _selectedTagId;
  late List<MemoryVoiceMessage> _voiceMessages;
  late List<MemoryMediaGroup> _mediaGroups;

  bool _saving = false;

  bool get _isEditing => widget.memory != null;

  @override
  void initState() {
    super.initState();
    final memory = widget.memory;
    _tags = [...widget.data.tags];
    _titleController = TextEditingController(text: memory?.title ?? '');
    _storyController = TextEditingController(text: memory?.story ?? '');
    _locationController = TextEditingController(
      text: memory?.locationName ?? '',
    );
    _noteController = TextEditingController(text: memory?.note ?? '');
    _selectedDate = memory?.date ?? DateTime.now();
    _selectedTagId =
        memory?.effectiveTagId ??
        (_tags.isEmpty
            ? MemoryTag.systemIdForCategory(MemoryCategory.daily)
            : _tags.first.id);
    _voiceMessages = [...?memory?.voiceMessages];
    _mediaGroups = [...?memory?.mediaGroups];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: AppScaffold(
        safeBottom: false,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenX,
                    AppSpacing.screenTop,
                    AppSpacing.screenX,
                    112,
                  ),
                  children: [
                    _FormTopBar(
                      title: _isEditing
                          ? l10n.memoryFormEditTitle
                          : l10n.memoryFormNewTitle,
                      saving: _saving,
                      onBack: () => Navigator.of(context).pop(),
                      onSave: _submit,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _MainInfoCard(
                      titleController: _titleController,
                      storyController: _storyController,
                      locationController: _locationController,
                      noteController: _noteController,
                      selectedDate: _selectedDate,
                      onPickDate: _pickDate,
                      voiceMessages: _voiceMessages,
                      onAddVoiceMessage:
                          _voiceMessages.length >= _maxVoiceMessages
                          ? null
                          : _showVoiceSourceSheet,
                      onRemoveVoiceMessage: _removeVoiceMessage,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _TagSelector(
                      tags: _tags,
                      selectedTagId: _selectedTagId,
                      onSelected: (tag) {
                        setState(() => _selectedTagId = tag.id);
                      },
                      onCreateTag: _showCreateTagSheet,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _MediaGroupsSection(
                      groups: _mediaGroups,
                      maxGroups: _maxMediaGroups,
                      onAddGroup: _mediaGroups.length >= _maxMediaGroups
                          ? null
                          : _addMediaGroup,
                      onUpdateGroupNote: _updateGroupNote,
                      onAddMedia: _showMediaSourceSheet,
                      onRemoveMedia: _removeMedia,
                      onRemoveGroup: _removeMediaGroup,
                      onMoveGroup: _moveMediaGroup,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.m,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00F7EEE8), Color(0xFFF7EEE8)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: PrimaryButton(
                    label: _saving
                        ? l10n.memoryFormSaving
                        : l10n.memoryFormSave,
                    icon: Icons.check_rounded,
                    onPressed: _saving ? null : _submit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.rose,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  Future<void> _showCreateTagSheet() async {
    final created = await showModalBottomSheet<MemoryTag>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _CreateTagSheet(onCreateTag: widget.onCreateTag);
      },
    );
    if (created == null || !mounted) {
      return;
    }
    setState(() {
      if (!_tags.any((tag) => tag.id == created.id)) {
        _tags = [..._tags, created];
      }
      _selectedTagId = created.id;
    });
  }

  void _showVoiceSourceSheet() {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.m,
            AppSpacing.screenX,
            AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              Text(
                l10n.memoryFormAddVoiceTitle,
                style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.memoryFormAddVoiceHelper,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.m),
              _SourceOption(
                icon: Icons.audio_file_rounded,
                title: l10n.memoryFormPickFromDevice,
                subtitle: l10n.memoryFormPickAudioSubtitle,
                onTap: () {
                  Navigator.of(context).pop();
                  _addMockVoiceMessage(MemoryVoiceMessageSource.imported);
                },
              ),
              const SizedBox(height: AppSpacing.s),
              _SourceOption(
                icon: Icons.mic_rounded,
                title: l10n.memoryFormRecordNew,
                subtitle: l10n.memoryFormRecordSubtitle,
                onTap: () {
                  Navigator.of(context).pop();
                  _showRecorderSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecorderSheet() {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.m,
            AppSpacing.screenX,
            AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              Text(
                l10n.memoryDetailMomentMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.m),
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rose.withValues(alpha: .14),
                  border: Border.all(
                    color: AppColors.rose.withValues(alpha: .3),
                    width: 10,
                  ),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.rose,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '00:34',
                style: AppTextStyles.displayL.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.s),
              const VoiceNotePlayer(duration: '0:34'),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: l10n.memoryFormCancelRecording,
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: SecondaryButton(
                      label: l10n.memoryFormSaveVoice,
                      icon: Icons.check_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addMockVoiceMessage(MemoryVoiceMessageSource.recorded);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMockVoiceMessage(MemoryVoiceMessageSource source) {
    if (_voiceMessages.length >= _maxVoiceMessages) {
      return;
    }
    final now = DateTime.now();
    final number = _voiceMessages.length + 1;
    setState(() {
      _voiceMessages = [
        ..._voiceMessages,
        MemoryVoiceMessage(
          id: 'voice-${now.microsecondsSinceEpoch}',
          uri: 'mock://${source.name}/${now.microsecondsSinceEpoch}',
          source: source,
          fileName: source == MemoryVoiceMessageSource.imported
              ? 'loi-nhan-$number.m4a'
              : null,
          title: source == MemoryVoiceMessageSource.imported
              ? context.l10n.memoryFormImportedAudioTitle(number)
              : context.l10n.memoryFormRecordedVoiceTitle(number),
          durationSeconds: source == MemoryVoiceMessageSource.imported
              ? 42
              : 34,
          waveform: const [.22, .58, .38, .78, .44, .68, .28, .74],
          createdAt: now,
        ),
      ];
    });
  }

  void _removeVoiceMessage(MemoryVoiceMessage message) {
    setState(() {
      _voiceMessages = [
        for (final item in _voiceMessages)
          if (item.id != message.id) item,
      ];
    });
  }

  void _addMediaGroup() {
    if (_mediaGroups.length >= _maxMediaGroups) {
      return;
    }
    final now = DateTime.now();
    setState(() {
      _mediaGroups = [
        ..._mediaGroups,
        MemoryMediaGroup(
          id: 'media-group-${now.microsecondsSinceEpoch}',
          items: const [],
          sortOrder: _mediaGroups.length,
        ),
      ];
    });
  }

  void _updateGroupNote(MemoryMediaGroup group, String value) {
    setState(() {
      _mediaGroups = [
        for (final item in _mediaGroups)
          if (item.id == group.id)
            MemoryMediaGroup(
              id: item.id,
              note: value.trim().isEmpty ? null : value,
              items: item.items,
              sortOrder: item.sortOrder,
            )
          else
            item,
      ];
    });
  }

  void _showMediaSourceSheet(MemoryMediaGroup group) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.m,
            AppSpacing.screenX,
            AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              Text(
                l10n.memoryFormAddMediaTitle,
                style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.m),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                title: l10n.memoryFormAddPhoto,
                subtitle: l10n.memoryFormAddPhotoSubtitle,
                onTap: () {
                  Navigator.of(context).pop();
                  _addMockMedia(group, MemoryMediaType.image);
                },
              ),
              const SizedBox(height: AppSpacing.s),
              _SourceOption(
                icon: Icons.video_library_rounded,
                title: l10n.memoryFormAddVideo,
                subtitle: l10n.memoryFormAddVideoSubtitle,
                onTap: () {
                  Navigator.of(context).pop();
                  _addMockMedia(group, MemoryMediaType.video);
                },
              ),
              const SizedBox(height: AppSpacing.s),
              _SourceOption(
                icon: Icons.photo_camera_rounded,
                title: l10n.memoryFormCamera,
                subtitle: l10n.memoryFormCameraSubtitle,
                onTap: () {
                  Navigator.of(context).pop();
                  _addMockMedia(group, MemoryMediaType.image);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMockMedia(MemoryMediaGroup group, MemoryMediaType type) {
    final now = DateTime.now();
    final media = MemoryMedia(
      id: 'media-${now.microsecondsSinceEpoch}',
      type: type,
      uri: AppAssets.heroImage,
      alt: type == MemoryMediaType.video
          ? context.l10n.memoryFormVideoMockAlt
          : context.l10n.memoryFormImageMockAlt,
    );

    setState(() {
      _mediaGroups = [
        for (final item in _mediaGroups)
          if (item.id == group.id)
            item.copyWith(items: [...item.items, media])
          else
            item,
      ];
    });
  }

  void _removeMedia(MemoryMediaGroup group, MemoryMedia media) {
    setState(() {
      _mediaGroups = [
        for (final item in _mediaGroups)
          if (item.id == group.id)
            item.copyWith(
              items: [
                for (final candidate in item.items)
                  if (candidate.id != media.id) candidate,
              ],
            )
          else
            item,
      ];
    });
  }

  void _removeMediaGroup(MemoryMediaGroup group) {
    setState(() {
      _mediaGroups = [
        for (final item in _mediaGroups)
          if (item.id != group.id) item,
      ];
      _mediaGroups = _reorderGroups(_mediaGroups);
    });
  }

  void _moveMediaGroup(MemoryMediaGroup group, int offset) {
    final currentIndex = _mediaGroups.indexWhere((item) => item.id == group.id);
    if (currentIndex == -1) {
      return;
    }
    final nextIndex = currentIndex + offset;
    if (nextIndex < 0 || nextIndex >= _mediaGroups.length) {
      return;
    }
    final updated = [..._mediaGroups];
    final item = updated.removeAt(currentIndex);
    updated.insert(nextIndex, item);
    setState(() {
      _mediaGroups = _reorderGroups(updated);
    });
  }

  List<MemoryMediaGroup> _reorderGroups(List<MemoryMediaGroup> groups) {
    return [
      for (final entry in groups.asMap().entries)
        entry.value.copyWith(sortOrder: entry.key),
    ];
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      return;
    }

    final normalizedGroups = _reorderGroups(
      _mediaGroups
          .where(
            (group) =>
                group.items.isNotEmpty ||
                (group.note?.trim().isNotEmpty ?? false),
          )
          .toList(growable: false),
    );

    final hasBody =
        _storyController.text.trim().isNotEmpty ||
        _noteController.text.trim().isNotEmpty ||
        _voiceMessages.isNotEmpty ||
        normalizedGroups.any((group) => group.items.isNotEmpty);
    if (!hasBody) {
      _showMessage(context.l10n.memoryFormBodyRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      final draft = MemoryDraft(
        title: _titleController.text,
        story: _storyController.text,
        date: _selectedDate,
        primaryTagId: _selectedTagId,
        locationName: _locationController.text,
        note: _noteController.text,
        voiceMessages: List.unmodifiable(_voiceMessages),
        mediaGroups: List.unmodifiable(normalizedGroups),
        category: widget.memory?.category ?? MemoryCategory.daily,
        phase: widget.memory?.phase ?? RelationshipPhase.year3,
      );
      await widget.onSubmit(draft);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _CreateTagSheet extends StatefulWidget {
  const _CreateTagSheet({required this.onCreateTag});

  final Future<MemoryTag> Function(String name) onCreateTag;

  @override
  State<_CreateTagSheet> createState() => _CreateTagSheetState();
}

class _CreateTagSheetState extends State<_CreateTagSheet> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenX,
        right: AppSpacing.screenX,
        top: AppSpacing.m,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          Text(
            l10n.memoryFormCreateTagTitle,
            style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: l10n.memoryFormCreateTagHint),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.m),
          PrimaryButton(
            label: l10n.memoryFormSaveTag,
            icon: _saving ? Icons.hourglass_top_rounded : Icons.sell_rounded,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      final tag = await widget.onCreateTag(name);
      if (mounted) {
        Navigator.of(context).pop(tag);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _FormTopBar extends StatelessWidget {
  const _FormTopBar({
    required this.title,
    required this.saving,
    required this.onBack,
    required this.onSave,
  });

  final String title;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCircleButton(
          icon: Icons.arrow_back_rounded,
          tooltip: context.l10n.backTooltip,
          onPressed: onBack,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        AppCircleButton(
          icon: saving ? Icons.hourglass_top_rounded : Icons.check_rounded,
          tooltip: context.l10n.saveTooltip,
          isActive: true,
          onPressed: saving ? null : onSave,
        ),
      ],
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({
    required this.titleController,
    required this.storyController,
    required this.locationController,
    required this.noteController,
    required this.selectedDate,
    required this.onPickDate,
    required this.voiceMessages,
    required this.onAddVoiceMessage,
    required this.onRemoveVoiceMessage,
  });

  final TextEditingController titleController;
  final TextEditingController storyController;
  final TextEditingController locationController;
  final TextEditingController noteController;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final List<MemoryVoiceMessage> voiceMessages;
  final VoidCallback? onAddVoiceMessage;
  final ValueChanged<MemoryVoiceMessage> onRemoveVoiceMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SurfaceCard(
      floating: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledTextField(
            label: l10n.memoryFormTitleLabel,
            hint: l10n.memoryFormTitleHint,
            controller: titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.memoryFormTitleRequired;
              }
              return null;
            },
          ),
          _LabeledTextField(
            label: l10n.memoryFormDescriptionLabel,
            hint: l10n.memoryFormDescriptionHint,
            controller: storyController,
            maxLines: 3,
          ),
          _FieldButton(
            label: l10n.memoryFormDateLabel,
            value: formatDate(selectedDate),
            icon: Icons.calendar_month_rounded,
            onTap: onPickDate,
          ),
          _LabeledTextField(
            label: l10n.memoryFormLocationLabel,
            hint: l10n.memoryFormLocationHint,
            controller: locationController,
          ),
          _LabeledTextField(
            label: l10n.memoryFormNoteLabel,
            hint: l10n.memoryFormNoteHint,
            controller: noteController,
            maxLines: 2,
            isLast: false,
          ),
          _VoiceMessageSection(
            messages: voiceMessages,
            onAdd: onAddVoiceMessage,
            onRemove: onRemoveVoiceMessage,
          ),
        ],
      ),
    );
  }
}

class _VoiceMessageSection extends StatelessWidget {
  const _VoiceMessageSection({
    required this.messages,
    required this.onAdd,
    required this.onRemove,
  });

  final List<MemoryVoiceMessage> messages;
  final VoidCallback? onAdd;
  final ValueChanged<MemoryVoiceMessage> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FieldBlock(
      label: l10n.memoryDetailMomentMessage,
      isLast: true,
      child: Column(
        children: [
          if (messages.isEmpty)
            _EmptyInlinePanel(
              title: l10n.memoryFormNoVoiceTitle,
              body: l10n.memoryFormNoVoiceBody,
              primaryLabel: l10n.memoryFormAddVoiceCta,
              icon: Icons.mic_rounded,
              onPressed: onAdd,
            )
          else ...[
            for (final message in messages) ...[
              _VoiceMessageTile(
                message: message,
                onRemove: () => onRemove(message),
              ),
              if (message != messages.last)
                const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.s),
            SecondaryButton(
              label: onAdd == null
                  ? l10n.memoryFormVoiceLimitReached
                  : l10n.memoryFormAddVoiceCta,
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceMessageTile extends StatelessWidget {
  const _VoiceMessageTile({required this.message, required this.onRemove});

  final MemoryVoiceMessage message;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = message.source == MemoryVoiceMessageSource.recorded
        ? l10n.memoryFormRecordedSource
        : l10n.memoryFormImportedSource;
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.rose,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title ??
                      message.fileName ??
                      l10n.memoryFormVoiceFallbackTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.memoryFormVoiceSourceAndDuration(
                    source,
                    _formatDuration(message.durationSeconds),
                  ),
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.memoryFormDeleteVoiceTooltip,
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int? seconds) {
    final value = seconds ?? 0;
    final minutes = value ~/ 60;
    final remaining = (value % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }
}

class _TagSelector extends StatelessWidget {
  const _TagSelector({
    required this.tags,
    required this.selectedTagId,
    required this.onSelected,
    required this.onCreateTag,
  });

  final List<MemoryTag> tags;
  final String selectedTagId;
  final ValueChanged<MemoryTag> onSelected;
  final VoidCallback onCreateTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.memoryFormTagSection),
          const SizedBox(height: AppSpacing.s),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final tag in tags)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: AppFilterChip(
                        label: memoryTagLabel(l10n, tag),
                        selected: selectedTagId == tag.id,
                        onTap: () => onSelected(tag),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: AppFilterChip(
                      label: l10n.memoryFormCreateTagChip,
                      selected: false,
                      onTap: onCreateTag,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MediaGroupsSection extends StatelessWidget {
  const _MediaGroupsSection({
    required this.groups,
    required this.maxGroups,
    required this.onAddGroup,
    required this.onUpdateGroupNote,
    required this.onAddMedia,
    required this.onRemoveMedia,
    required this.onRemoveGroup,
    required this.onMoveGroup,
  });

  final List<MemoryMediaGroup> groups;
  final int maxGroups;
  final VoidCallback? onAddGroup;
  final void Function(MemoryMediaGroup group, String value) onUpdateGroupNote;
  final ValueChanged<MemoryMediaGroup> onAddMedia;
  final void Function(MemoryMediaGroup group, MemoryMedia media) onRemoveMedia;
  final ValueChanged<MemoryMediaGroup> onRemoveGroup;
  final void Function(MemoryMediaGroup group, int offset) onMoveGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(l10n.memoryFormMediaGroupsSection)),
              _LimitPill(l10n.memoryFormGroupLimit(groups.length, maxGroups)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.memoryFormMediaGroupsHelper,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s),
          if (groups.isEmpty)
            _EmptyInlinePanel(
              title: l10n.memoryFormNoMediaGroupTitle,
              body: l10n.memoryFormNoMediaGroupBody,
              primaryLabel: l10n.memoryFormAddMediaGroup,
              icon: Icons.perm_media_rounded,
              onPressed: onAddGroup,
            )
          else ...[
            for (final entry in groups.asMap().entries) ...[
              _MediaGroupCard(
                group: entry.value,
                index: entry.key,
                total: groups.length,
                maxGroups: maxGroups,
                onNoteChanged: (value) => onUpdateGroupNote(entry.value, value),
                onAddMedia: () => onAddMedia(entry.value),
                onRemoveMedia: (media) => onRemoveMedia(entry.value, media),
                onRemoveGroup: () => onRemoveGroup(entry.value),
                onMoveUp: entry.key == 0
                    ? null
                    : () => onMoveGroup(entry.value, -1),
                onMoveDown: entry.key == groups.length - 1
                    ? null
                    : () => onMoveGroup(entry.value, 1),
              ),
              const SizedBox(height: AppSpacing.s),
            ],
            _AddGroupPanel(
              groups: groups.length,
              maxGroups: maxGroups,
              onTap: onAddGroup,
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaGroupCard extends StatelessWidget {
  const _MediaGroupCard({
    required this.group,
    required this.index,
    required this.total,
    required this.maxGroups,
    required this.onNoteChanged,
    required this.onAddMedia,
    required this.onRemoveMedia,
    required this.onRemoveGroup,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final MemoryMediaGroup group;
  final int index;
  final int total;
  final int maxGroups;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onAddMedia;
  final ValueChanged<MemoryMedia> onRemoveMedia;
  final VoidCallback onRemoveGroup;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.drag_indicator_rounded,
                color: AppColors.mutedLight,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.memoryFormMediaGroupTitle(index + 1, maxGroups),
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.roseDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      l10n.memoryFormMediaGroupHelper,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.roseDark,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'add':
                      onAddMedia();
                    case 'up':
                      onMoveUp?.call();
                    case 'down':
                      onMoveDown?.call();
                    case 'delete':
                      onRemoveGroup();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'add',
                    child: Text(l10n.memoryFormAddMediaTitle),
                  ),
                  PopupMenuItem(
                    value: 'up',
                    enabled: onMoveUp != null,
                    child: Text(l10n.memoryFormMoveUp),
                  ),
                  PopupMenuItem(
                    value: 'down',
                    enabled: onMoveDown != null,
                    child: Text(l10n.memoryFormMoveDown),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.memoryFormDeleteGroup),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          TextFormField(
            initialValue: group.note,
            maxLines: 2,
            onChanged: onNoteChanged,
            decoration: InputDecoration(hintText: l10n.memoryFormGroupNoteHint),
          ),
          const SizedBox(height: AppSpacing.s),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.xs,
            mainAxisSpacing: AppSpacing.xs,
            children: [
              for (final media in group.items)
                _MediaDraftTile(
                  media: media,
                  onRemove: () => onRemoveMedia(media),
                ),
              _AddMediaTile(onTap: onAddMedia),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.memoryFormItemCount(group.items.length),
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
              ),
              Text(
                total > 1
                    ? l10n.memoryFormGroupsReorderHint
                    : l10n.memoryFormAddGroupToContinue,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaDraftTile extends StatelessWidget {
  const _MediaDraftTile({required this.media, required this.onRemove});

  final MemoryMedia media;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetCoverImage(imagePath: media.uri),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.night.withValues(alpha: .02),
                  AppColors.night.withValues(alpha: .42),
                ],
              ),
            ),
          ),
          if (media.type == MemoryMediaType.video)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMediaTile extends StatelessWidget {
  const _AddMediaTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWarm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.s),
        side: BorderSide(color: AppColors.rose.withValues(alpha: .24)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: const Icon(Icons.add_rounded, color: AppColors.rose),
      ),
    );
  }
}

class _AddGroupPanel extends StatelessWidget {
  const _AddGroupPanel({
    required this.groups,
    required this.maxGroups,
    required this.onTap,
  });

  final int groups;
  final int maxGroups;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reachedLimit = groups >= maxGroups;
    return _EmptyInlinePanel(
      title: reachedLimit
          ? l10n.memoryFormGroupLimitReachedTitle
          : l10n.memoryFormAddAnotherMediaGroupTitle,
      body: reachedLimit
          ? l10n.memoryFormGroupLimitReachedBody
          : l10n.memoryFormAddAnotherMediaGroupBody,
      primaryLabel: reachedLimit
          ? l10n.memoryFormGroupLimitReachedCta
          : l10n.memoryFormAddMediaGroup,
      icon: reachedLimit
          ? Icons.lock_rounded
          : Icons.add_photo_alternate_rounded,
      onPressed: reachedLimit ? null : onTap,
    );
  }
}

class _EmptyInlinePanel extends StatelessWidget {
  const _EmptyInlinePanel({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.rose.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s),
          SecondaryButton(
            label: primaryLabel,
            icon: icon,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FieldBlock(
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.rose, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.validator,
    this.isLast = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _FieldBlock(
      label: label,
      isLast: isLast,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        validator: validator,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.child,
    this.isLast = false,
  });

  final String label;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.line,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.label.copyWith(color: AppColors.roseDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.floating = false});

  final Widget child;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
        boxShadow: floating ? AppShadows.floating : AppShadows.card,
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyS.copyWith(
        color: AppColors.roseDark,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LimitPill extends StatelessWidget {
  const _LimitPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.s),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.s),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
