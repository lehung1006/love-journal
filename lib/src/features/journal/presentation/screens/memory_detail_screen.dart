import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({
    required this.memory,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onEdit,
    super.key,
  });

  final Memory memory;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cover = memory.coverMedia;
    final hasCover = cover != null;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.warmPageGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: hasCover ? 326 : 196,
              backgroundColor: AppColors.paper,
              foregroundColor: AppColors.ink,
              leading: IconButton(
                tooltip: l10n.backTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                IconButton(
                  tooltip: 'Sửa kỷ niệm',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  tooltip: l10n.favoriteTooltip,
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.rose : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: hasCover
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          if (cover.type == MemoryMediaType.video)
                            MemoryVideoPlayer(
                              uri: cover.uri,
                              autoPlay: true,
                              automaticPlayCount: 3,
                              fit: BoxFit.cover,
                            )
                          else
                            GestureDetector(
                              onTap: () => unawaited(
                                showMemoryMediaViewer(
                                  context: context,
                                  media: memory.media,
                                  initialIndex: memory.media.indexWhere(
                                    (item) => item.id == cover.id,
                                  ),
                                ),
                              ),
                              child: Hero(
                                tag: 'memory-cover-${memory.id}',
                                child: AssetCoverImage(imagePath: cover.uri),
                              ),
                            ),
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.night.withValues(alpha: .08),
                                    AppColors.night.withValues(alpha: .38),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const _TextMemoryCover(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                AppSpacing.xl,
                AppSpacing.screenX,
                40,
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    formatDateAndPlace(memory),
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.roseDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    memory.title,
                    style: AppTextStyles.displayL.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  if (memory.story.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      memory.story.trim(),
                      style: AppTextStyles.bodyL.copyWith(
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                  if (memory.note?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      memory.note!.trim(),
                      style: AppTextStyles.bodyL.copyWith(
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                  if (memory.voiceMessages.isNotEmpty ||
                      memory.voiceNoteUrl != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'LỜI NHẮN CHO KHOẢNH KHẮC NÀY',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.roseDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    if (memory.voiceMessages.isNotEmpty)
                      for (final message in memory.voiceMessages) ...[
                        VoiceNotePlayer(
                          duration: _formatDuration(
                            message.durationSeconds ?? 0,
                          ),
                        ),
                        if (message != memory.voiceMessages.last)
                          const SizedBox(height: AppSpacing.xs),
                      ]
                    else
                      const VoiceNotePlayer(),
                  ],
                  if (memory.favoriteMoment?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xl),
                    QuoteBlock(quote: memory.favoriteMoment!.trim()),
                  ],
                  if (memory.messageForHer?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.m),
                    QuoteBlock(quote: memory.messageForHer!.trim()),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (memory.mediaGroups.isNotEmpty)
                    _MemoryMediaGroups(groups: memory.mediaGroups)
                  else if (memory.media.isNotEmpty)
                    _LegacyMediaSection(media: memory.media),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }
}

class _TextMemoryCover extends StatelessWidget {
  const _TextMemoryCover();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWarm,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.rose,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryMediaGroups extends StatelessWidget {
  const _MemoryMediaGroups({required this.groups});

  final List<MemoryMediaGroup> groups;

  @override
  Widget build(BuildContext context) {
    final visible = groups
        .where(
          (group) =>
              group.items.isNotEmpty || group.note?.trim().isNotEmpty == true,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < visible.length; index++) ...[
          Text(
            visible[index].title?.trim().isNotEmpty == true
                ? visible[index].title!.trim()
                : 'Đoạn ${index + 1}',
            style: AppTextStyles.titleM.copyWith(color: AppColors.ink),
          ),
          if (visible[index].note?.trim().isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              visible[index].note!.trim(),
              style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
            ),
          ],
          if (visible[index].items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            _MemoryMediaRail(media: visible[index].items),
          ],
          if (index < visible.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}

class _LegacyMediaSection extends StatelessWidget {
  const _LegacyMediaSection({required this.media});

  final List<MemoryMedia> media;

  @override
  Widget build(BuildContext context) {
    return _MemoryMediaRail(media: media);
  }
}

class _MemoryMediaRail extends StatelessWidget {
  const _MemoryMediaRail({required this.media});

  final List<MemoryMedia> media;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, index) {
          final item = media[index];
          return SizedBox(
            width: index == 0 ? 292 : 180,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => unawaited(
                showMemoryMediaViewer(
                  context: context,
                  media: media,
                  initialIndex: index,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.type == MemoryMediaType.video)
                      MemoryVideoPreview(
                        uri: item.uri,
                        thumbnailUri: item.thumbnailUri,
                      )
                    else
                      AssetCoverImage(imagePath: item.uri),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
