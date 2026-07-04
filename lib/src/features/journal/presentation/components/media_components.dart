import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '_pressable_scale.dart';

class AssetCoverImage extends StatelessWidget {
  const AssetCoverImage({
    required this.imagePath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surfaceWarm, AppColors.paperMuted],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.mutedLight,
            ),
          ),
        );
      },
    );
  }
}

class MemoryThumbnail extends StatelessWidget {
  const MemoryThumbnail({required this.imagePath, this.size = 84, super.key});

  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: imagePath == null
            ? const ColoredBox(color: AppColors.surfaceWarm)
            : Stack(
                fit: StackFit.expand,
                children: [
                  AssetCoverImage(imagePath: imagePath!),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.rose.withValues(alpha: .32),
                          AppColors.teal.withValues(alpha: .18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class HeroMemoryCard extends StatelessWidget {
  const HeroMemoryCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.kicker,
    this.onTap,
    this.height = 252,
    super.key,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String? kicker;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.s),
          boxShadow: AppShadows.hero,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AssetCoverImage(imagePath: imagePath),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.photoOverlay),
            ),
            Positioned(
              left: AppSpacing.m,
              right: AppSpacing.m,
              bottom: AppSpacing.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kicker != null) ...[
                    Text(
                      kicker!,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white.withValues(alpha: .78),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayL.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0x66000000),
                          offset: Offset(0, 8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(
                      color: Colors.white.withValues(alpha: .78),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCarousel extends StatelessWidget {
  const MediaCarousel({required this.media, super.key});

  final List<MemoryMedia> media;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 84,
            child: MemoryThumbnail(imagePath: media[index].uri),
          );
        },
      ),
    );
  }
}

class QuoteBlock extends StatelessWidget {
  const QuoteBlock({required this.quote, super.key});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F4),
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(AppRadius.s),
        ),
        border: const Border(left: BorderSide(color: AppColors.rose, width: 3)),
      ),
      child: Text(
        quote,
        style: AppTextStyles.bodyM.copyWith(
          color: AppColors.inkSoft,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class VoiceNotePlayer extends StatelessWidget {
  const VoiceNotePlayer({this.duration = '0:34', super.key});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(14, (index) {
                final height = 8.0 + ((index * 7) % 20);
                return Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 3,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.rose.withValues(alpha: .58),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            duration,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
