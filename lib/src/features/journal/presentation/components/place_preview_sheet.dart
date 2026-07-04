import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import 'buttons_and_chips.dart';
import 'media_components.dart';

class PlacePreviewSheet extends StatelessWidget {
  const PlacePreviewSheet({
    required this.place,
    required this.memories,
    required this.onOpen,
    super.key,
  });

  final Place place;
  final List<Memory> memories;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cover = memories.isEmpty ? null : memories.first.coverMedia?.uri;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                MemoryThumbnail(imagePath: cover),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: AppTextStyles.titleM.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${memories.length} kỷ niệm · ${place.shortNote ?? ''}',
                        maxLines: 3,
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
            PrimaryButton(
              label: 'Xem kỷ niệm',
              icon: Icons.arrow_forward_rounded,
              onPressed: onOpen,
            ),
          ],
        ),
      ),
    );
  }
}
