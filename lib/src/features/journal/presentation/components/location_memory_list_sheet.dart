import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../journal_formatters.dart';
import 'media_components.dart';
import 'memory_media_viewer.dart';

class LocationMemoryListSheet extends StatelessWidget {
  const LocationMemoryListSheet({
    required this.group,
    required this.onMemoryTap,
    super.key,
  });

  final MemoryLocationGroup group;
  final ValueChanged<Memory> onMemoryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = group.location;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .72,
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWarm,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.rose,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.displayName,
                        style: AppTextStyles.titleM.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        location.formattedAddress ??
                            l10n.mapLocationAddressFallback,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              l10n.mapLocationMemoryListTitle,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.roseDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: group.memories.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.line),
                itemBuilder: (context, index) {
                  final memory = group.memories[index];
                  return _MemoryRow(
                    memory: memory,
                    onTap: () => onMemoryTap(memory),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryRow extends StatelessWidget {
  const _MemoryRow({required this.memory, required this.onTap});

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = memory.coverMedia;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            children: [
              MemoryThumbnail(
                imagePath: cover?.uri,
                content: cover?.type == MemoryMediaType.video
                    ? MemoryVideoPreview(
                        uri: cover!.uri,
                        thumbnailUri: cover.thumbnailUri,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      formatDate(memory.date),
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.roseDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      memory.story,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.muted,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
