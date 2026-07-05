import 'package:flutter/material.dart';

import '../../../../app/journal_app_config.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.data,
    required this.now,
    required this.openedLetterIds,
    required this.onMemoryTap,
    required this.onLetterTap,
    required this.onRecapTap,
    super.key,
  });

  final JournalData data;
  final DateTime now;
  final Set<String> openedLetterIds;
  final ValueChanged<Memory> onMemoryTap;
  final ValueChanged<Letter> onLetterTap;
  final VoidCallback onRecapTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loveDays = dayDifference(JournalAppConfig.loveStartedAt, now);
    final featured = data.featuredMemoryOrNull;
    final nextLetter = data.nextHomeLetter(now);
    final memoryCount = data.visibleMemories.length;

    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          112,
        ),
        children: [
          TopBar(
            kicker: l10n.homeKicker,
            title: l10n.appTitle,
            large: true,
            trailing: AppCircleButton(
              icon: Icons.favorite_rounded,
              tooltip: l10n.homeRecapTooltip,
              onPressed: onRecapTap,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          HeroMemoryCard(
            imagePath: featured?.coverMedia?.uri ?? AppAssets.heroImage,
            kicker: l10n.homeHeroKicker,
            title: l10n.homeLoveDays(formatNumber(loveDays)),
            subtitle: l10n.homeHeroSubtitle,
            onTap: onRecapTap,
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: formatNumber(memoryCount),
                  label: l10n.homeMemoriesWritten,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: StatCard(
                  value: formatNumber(data.places.length),
                  label: l10n.homePlacesVisited,
                  accentColor: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SectionHeader(title: l10n.homeFeaturedMemory),
          const SizedBox(height: AppSpacing.s),
          if (featured == null)
            EmptyStateCard(
              title: l10n.homeNoFeaturedTitle,
              body: l10n.homeNoFeaturedBody,
            )
          else
            MemoryListCard(
              memory: featured,
              onTap: () => onMemoryTap(featured),
            ),
          const SizedBox(height: AppSpacing.l),
          SectionHeader(title: l10n.homeNextLetter),
          const SizedBox(height: AppSpacing.s),
          if (nextLetter == null)
            EmptyStateCard(
              title: l10n.homeNoLettersTitle,
              body: l10n.homeNoLettersBody,
            )
          else
            LetterCard(
              letter: nextLetter,
              now: now,
              opened: openedLetterIds.contains(nextLetter.id),
              onTap: () => onLetterTap(nextLetter),
            ),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            label: l10n.homeRecapCta,
            icon: Icons.auto_stories_rounded,
            onPressed: onRecapTap,
          ),
        ],
      ),
    );
  }
}
