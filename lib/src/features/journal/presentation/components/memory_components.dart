import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../journal_formatters.dart';
import '_pressable_scale.dart';
import 'layout_components.dart';
import 'media_components.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.value,
    required this.label,
    this.accentColor = AppColors.roseDark,
    super.key,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.displayL.copyWith(
              color: accentColor,
              fontSize: 30,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class MemoryListCard extends StatelessWidget {
  const MemoryListCard({
    required this.memory,
    required this.onTap,
    this.tagLabel,
    this.mediaSummary,
    this.onMore,
    super.key,
  });

  final Memory memory;
  final VoidCallback onTap;
  final String? tagLabel;
  final String? mediaSummary;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final imagePath = memory.coverMedia?.uri;

    return PressableScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.s),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MemoryThumbnail(imagePath: imagePath),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    memory.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyL.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                      height: 19 / 15,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatDateAndPlace(memory),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    memory.story,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                  ),
                  if (tagLabel != null || mediaSummary != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        if (tagLabel != null)
                          _MemoryMetaPill(
                            label: tagLabel!,
                            foreground: AppColors.roseDark,
                            background: AppColors.surfaceWarm,
                          ),
                        if (mediaSummary != null)
                          _MemoryMetaPill(
                            label: mediaSummary!,
                            foreground: AppColors.teal,
                            background: AppColors.teal.withValues(alpha: .1),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onMore != null) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: 'Tùy chọn kỷ niệm',
                onPressed: onMore,
                icon: const Icon(Icons.more_horiz_rounded),
                color: AppColors.mutedLight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemoryMetaPill extends StatelessWidget {
  const _MemoryMetaPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: foreground,
            fontSize: 10,
            height: 12 / 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class TimelineSpine extends StatelessWidget {
  const TimelineSpine({
    required this.memories,
    required this.onMemoryTap,
    this.tagLabelForMemory,
    this.mediaSummaryForMemory,
    this.onMemoryMore,
    super.key,
  });

  final List<Memory> memories;
  final ValueChanged<Memory> onMemoryTap;
  final String Function(Memory memory)? tagLabelForMemory;
  final String Function(Memory memory)? mediaSummaryForMemory;
  final ValueChanged<Memory>? onMemoryMore;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const EmptyStateCard(
        title: 'Chưa có kỷ niệm nào được viết',
        body: 'Khi có dữ liệu, timeline sẽ hiện theo thứ tự thời gian.',
      );
    }

    return Stack(
      children: [
        Positioned(
          left: 5,
          top: 12,
          bottom: 12,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.rose, AppColors.teal, AppColors.amber],
              ),
            ),
          ),
        ),
        Column(
          children: [
            for (final entry in memories.asMap().entries)
              Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  bottom: entry.key == memories.length - 1 ? 0 : AppSpacing.s,
                ),
                child: _TimelineEntry(
                  index: entry.key,
                  child: MemoryListCard(
                    memory: entry.value,
                    onTap: () => onMemoryTap(entry.value),
                    tagLabel: tagLabelForMemory?.call(entry.value),
                    mediaSummary: mediaSummaryForMemory?.call(entry.value),
                    onMore: onMemoryMore == null
                        ? null
                        : () => onMemoryMore!(entry.value),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.rose,
      AppColors.teal,
      AppColors.amber,
      AppColors.moss,
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.base + Duration(milliseconds: index * 45),
      curve: AppMotion.soft,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            left: -17,
            top: 28,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withValues(alpha: .18),
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
