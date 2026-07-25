import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../application/state/memory_composer_state.dart';
import '../../domain/entities/journal_entities.dart';
import 'media_components.dart';
import 'memory_media_viewer.dart';

class MemoryComposerTopBar extends StatelessWidget {
  const MemoryComposerTopBar({
    required this.isEditing,
    required this.status,
    required this.onClose,
    required this.onEditTitle,
    super.key,
  });

  final bool isEditing;
  final MemoryComposerStatus status;
  final VoidCallback onClose;
  final VoidCallback onEditTitle;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (status) {
      MemoryComposerStatus.savingDraft => 'Đang lưu bản nháp...',
      MemoryComposerStatus.draftSaved => 'Đã lưu bản nháp',
      MemoryComposerStatus.failed => 'Chưa thể lưu bản nháp',
      _ => isEditing ? 'Chỉnh sửa kỷ niệm' : 'Kỷ niệm mới',
    };

    return Row(
      children: [
        IconButton(
          tooltip: 'Đóng',
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              statusLabel,
              key: ValueKey(statusLabel),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đặt tên kỷ niệm',
          onPressed: onEditTitle,
          icon: const Icon(Icons.edit_note_rounded),
        ),
      ],
    );
  }
}

class MemoryComposerMetadata extends StatelessWidget {
  const MemoryComposerMetadata({
    required this.dateLabel,
    required this.tagLabel,
    required this.locationLabel,
    required this.onDateTap,
    required this.onTagTap,
    required this.onLocationTap,
    this.onLocationClear,
    super.key,
  });

  final String dateLabel;
  final String tagLabel;
  final String locationLabel;
  final VoidCallback onDateTap;
  final VoidCallback onTagTap;
  final VoidCallback onLocationTap;
  final VoidCallback? onLocationClear;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MetadataChip(
            icon: Icons.calendar_today_rounded,
            label: dateLabel,
            onTap: onDateTap,
          ),
          const SizedBox(width: AppSpacing.xs),
          _MetadataChip(
            icon: Icons.local_offer_outlined,
            label: tagLabel,
            onTap: onTagTap,
          ),
          const SizedBox(width: AppSpacing.xs),
          _MetadataChip(
            icon: Icons.place_outlined,
            label: locationLabel,
            onTap: onLocationTap,
            onClear: onLocationClear,
          ),
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          height: 38,
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: AppColors.roseDark),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.inkSoft),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 4),
                InkResponse(
                  onTap: onClear,
                  radius: 16,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryComposerEmptyPrompt extends StatelessWidget {
  const MemoryComposerEmptyPrompt({
    required this.onMedia,
    required this.onStory,
    required this.onVoice,
    super.key,
  });

  final VoidCallback onMedia;
  final VoidCallback onStory;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Column(
        children: [
          Transform.rotate(
            angle: -.055,
            child: Container(
              width: 116,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                boxShadow: AppShadows.card,
              ),
              child: const AspectRatio(
                aspectRatio: 1.05,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  child: AssetCoverImage(imagePath: AppAssets.heroImage),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Bắt đầu từ điều bạn nhớ',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StartAction(
                icon: Icons.photo_outlined,
                label: 'Ảnh / video',
                onTap: onMedia,
              ),
              _StartAction(
                icon: Icons.edit_rounded,
                label: 'Viết một dòng',
                onTap: onStory,
              ),
              _StartAction(
                icon: Icons.mic_none_rounded,
                label: 'Giọng nói',
                onTap: onVoice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartAction extends StatelessWidget {
  const _StartAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox.square(
                dimension: 72,
                child: Icon(icon, size: 30, color: AppColors.roseDark),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryComposerStoryField extends StatelessWidget {
  const MemoryComposerStoryField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      minLines: 3,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.bodyL.copyWith(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: 'Viết điều bạn muốn giữ lại...',
        hintStyle: AppTextStyles.bodyL.copyWith(color: AppColors.mutedLight),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class MemoryComposerVoiceStrip extends StatelessWidget {
  const MemoryComposerVoiceStrip({
    required this.messages,
    required this.onRemove,
    super.key,
  });

  final List<MemoryVoiceMessage> messages;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final message in messages)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Row(
              children: [
                Expanded(
                  child: VoiceNotePlayer(
                    duration: _formatDuration(message.durationSeconds),
                  ),
                ),
                IconButton(
                  tooltip: 'Xóa lời nhắn',
                  onPressed: () => onRemove(message.id),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDuration(int? seconds) {
    final value = seconds ?? 0;
    final minutes = value ~/ 60;
    final rest = (value % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class MemoryComposerMediaGroupView extends StatelessWidget {
  const MemoryComposerMediaGroupView({
    required this.group,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onTitleChanged,
    required this.onNoteChanged,
    required this.onAddMedia,
    required this.onOpenMedia,
    required this.onRemoveMedia,
    required this.onRemoveGroup,
    required this.onMoveUp,
    required this.onMoveDown,
    super.key,
  });

  final MemoryMediaGroup group;
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onAddMedia;
  final ValueChanged<String> onOpenMedia;
  final ValueChanged<String> onRemoveMedia;
  final VoidCallback onRemoveGroup;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('title-${group.id}'),
                  initialValue: group.title ?? 'Đoạn ${index + 1}',
                  onChanged: onTitleChanged,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.titleM.copyWith(
                    color: AppColors.ink,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tên đoạn này',
                    suffixIcon: const Icon(
                      Icons.edit_rounded,
                      size: 17,
                      color: AppColors.mutedLight,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.rose),
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PopupMenuButton<String>(
                tooltip: 'Tùy chọn đoạn',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  switch (value) {
                    case 'up':
                      onMoveUp();
                      break;
                    case 'down':
                      onMoveDown();
                      break;
                    case 'delete':
                      onRemoveGroup();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'up',
                    enabled: canMoveUp,
                    child: const Text('Đưa lên trên'),
                  ),
                  PopupMenuItem(
                    value: 'down',
                    enabled: canMoveDown,
                    child: const Text('Đưa xuống dưới'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa đoạn')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            key: ValueKey('note-${group.id}'),
            initialValue: group.note,
            onChanged: onNoteChanged,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.inkSoft),
            decoration: InputDecoration(
              hintText: 'Một lời nhỏ cho đoạn này...',
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.mutedLight,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (group.items.isNotEmpty)
            SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: group.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, itemIndex) {
                  if (itemIndex == group.items.length) {
                    return _AddMediaTile(onTap: onAddMedia);
                  }
                  final media = group.items[itemIndex];
                  return _MediaTile(
                    media: media,
                    isPrimary: itemIndex == 0,
                    onOpen: () => onOpenMedia(media.id),
                    onRemove: () => onRemoveMedia(media.id),
                  );
                },
              ),
            )
          else
            _EmptyMediaGroup(onTap: onAddMedia),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.media,
    required this.isPrimary,
    required this.onOpen,
    required this.onRemove,
  });

  final MemoryMedia media;
  final bool isPrimary;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isPrimary ? 238 : 142,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (media.type == MemoryMediaType.video)
                MemoryVideoPreview(
                  uri: media.uri,
                  thumbnailUri: media.thumbnailUri,
                )
              else
                AssetCoverImage(imagePath: media.uri),
              Positioned(
                top: 7,
                right: 7,
                child: IconButton.filledTonal(
                  tooltip: 'Xóa media',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMediaTile extends StatelessWidget {
  const _AddMediaTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Material(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.rose,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMediaGroup extends StatelessWidget {
  const _EmptyMediaGroup({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWarm,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: Container(
          height: 112,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppColors.rose),
              SizedBox(height: 6),
              Text('Thêm ảnh hoặc video'),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryComposerBottomBar extends StatelessWidget {
  const MemoryComposerBottomBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.canAddGroup,
    required this.canAddVoice,
    required this.onMedia,
    required this.onStory,
    required this.onVoice,
    required this.onSubmit,
    super.key,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final bool canAddGroup;
  final bool canAddVoice;
  final VoidCallback onMedia;
  final VoidCallback onStory;
  final VoidCallback onVoice;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Thêm ảnh hoặc video',
                onPressed: canAddGroup ? onMedia : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
              IconButton(
                tooltip: 'Viết lời kể',
                onPressed: onStory,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: 'Thêm lời nhắn giọng nói',
                onPressed: canAddVoice ? onVoice : null,
                icon: const Icon(Icons.mic_none_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canSubmit ? onSubmit : null,
                  icon: isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.favorite_rounded, size: 19),
                  label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu kỷ niệm'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: AppColors.roseDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryComposerMediaImportOverlay extends StatelessWidget {
  const MemoryComposerMediaImportOverlay({
    required this.completedFiles,
    required this.totalFiles,
    super.key,
  });

  final int completedFiles;
  final int totalFiles;

  @override
  Widget build(BuildContext context) {
    final currentFile = totalFiles == 0
        ? 0
        : (completedFiles + 1).clamp(1, totalFiles);
    final title = totalFiles == 0
        ? 'Đang chuẩn bị video...'
        : totalFiles == 1
        ? 'Đang thêm video...'
        : 'Đang thêm video $currentFile/$totalFiles';

    return Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x6620191D)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Material(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 42,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleM.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Video lớn có thể cần thêm một chút thời gian.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ComposerSheetHandle extends StatelessWidget {
  const ComposerSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class ComposerSourceOption extends StatelessWidget {
  const ComposerSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return AnimatedOpacity(
      opacity: enabled ? 1 : .52,
      duration: AppMotion.fast,
      child: Material(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(icon, color: AppColors.roseDark),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyL.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
