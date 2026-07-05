import 'package:flutter/material.dart';

import '../../../../app/journal_app_config.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({required this.data, required this.now, super.key});

  final JournalData data;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loveDays = dayDifference(JournalAppConfig.loveStartedAt, now);
    final featured = data.featuredMemoryOrNull;
    final photoCount = data.visibleMemories.fold<int>(
      0,
      (count, memory) => count + memory.media.length,
    );

    return Scaffold(
      body: AppScaffold(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          34,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                AppCircleButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: l10n.backTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            HeroMemoryCard(
              imagePath: featured?.coverMedia?.uri ?? AppAssets.heroImage,
              kicker: l10n.recapKicker,
              title: l10n.recapTitle,
              subtitle: l10n.recapSubtitle,
              height: 300,
            ),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.s,
              mainAxisSpacing: AppSpacing.s,
              childAspectRatio: 1.45,
              children: [
                StatCard(
                  value: formatNumber(loveDays),
                  label: l10n.recapDaysLoved,
                ),
                StatCard(
                  value: formatNumber(data.places.length),
                  label: l10n.recapPlacesVisited,
                  accentColor: AppColors.teal,
                ),
                StatCard(
                  value: formatNumber(photoCount),
                  label: l10n.recapPhotos,
                  accentColor: AppColors.amber,
                ),
                StatCard(
                  value: formatNumber(data.letters.length),
                  label: l10n.recapLetters,
                  accentColor: AppColors.lavender,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            QuoteBlock(quote: l10n.recapQuote),
            const SizedBox(height: AppSpacing.m),
            PrimaryButton(
              label: l10n.recapCta,
              icon: Icons.favorite_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
