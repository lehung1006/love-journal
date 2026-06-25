import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/journal_models.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class MemoryDetailScreen extends StatelessWidget {
  const MemoryDetailScreen({
    required this.memory,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  final Memory memory;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final imagePath = memory.coverMedia?.uri ?? AppAssets.heroImage;
    final storyBlocks = _splitStory(memory.story);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.warmPageGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 324,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'memory-cover-${memory.id}',
                      child: AssetCoverImage(imagePath: imagePath),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, .52, 1],
                          colors: [
                            AppColors.night.withValues(alpha: .02),
                            AppColors.night.withValues(alpha: .22),
                            AppColors.night.withValues(alpha: .82),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenX,
                          AppSpacing.s,
                          AppSpacing.screenX,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppCircleButton(
                              icon: Icons.arrow_back_rounded,
                              tooltip: 'Quay lại',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            AppCircleButton(
                              icon: isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              tooltip: 'Yêu thích',
                              isActive: isFavorite,
                              onPressed: onToggleFavorite,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -42),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenX,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .96),
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      border: Border.all(color: AppColors.line),
                      boxShadow: AppShadows.floating,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDateAndPlace(memory),
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          memory.title,
                          style: AppTextStyles.titleL.copyWith(
                            color: AppColors.ink,
                            fontSize: 29,
                            height: 31 / 29,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        for (final block in storyBlocks) ...[
                          Text(
                            block,
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          if (block != storyBlocks.last)
                            const SizedBox(height: AppSpacing.s),
                        ],
                        if (memory.favoriteMoment != null) ...[
                          const SizedBox(height: AppSpacing.m),
                          QuoteBlock(quote: memory.favoriteMoment!),
                        ],
                        if (memory.voiceNoteUrl != null) ...[
                          const SizedBox(height: AppSpacing.m),
                          const VoiceNotePlayer(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  0,
                  AppSpacing.screenX,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (memory.messageForHer != null) ...[
                      QuoteBlock(quote: memory.messageForHer!),
                      const SizedBox(height: AppSpacing.m),
                    ],
                    MediaCarousel(media: memory.media),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _splitStory(String story) {
    if (story.length <= 600) {
      return [story];
    }

    final sentences = story.split('. ');
    final blocks = <String>[];
    final buffer = StringBuffer();

    for (final sentence in sentences) {
      final normalized = sentence.endsWith('.') ? sentence : '$sentence.';
      if (buffer.length + normalized.length > 260 && buffer.isNotEmpty) {
        blocks.add(buffer.toString().trim());
        buffer.clear();
      }
      buffer.write(normalized);
      buffer.write(' ');
    }

    if (buffer.isNotEmpty) {
      blocks.add(buffer.toString().trim());
    }

    return blocks;
  }
}
