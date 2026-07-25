import 'package:flutter/material.dart';

import '../../../../app/journal_app_config.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';
import '../journal_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.data,
    required this.now,
    required this.openedLetterIds,
    required this.onMemoryTap,
    required this.onLetterTap,
    required this.onRecapTap,
    required this.onAddMemory,
    super.key,
  });

  final JournalData data;
  final DateTime now;
  final Set<String> openedLetterIds;
  final ValueChanged<Memory> onMemoryTap;
  final ValueChanged<Letter> onLetterTap;
  final VoidCallback onRecapTap;
  final VoidCallback onAddMemory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  bool _entranceStarted = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entranceController.value = 1;
      return;
    }
    if (!_entranceStarted) {
      _entranceStarted = true;
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loveDays = dayDifference(JournalAppConfig.loveStartedAt, widget.now);
    final featured = widget.data.featuredMemoryOrNull;
    final nextLetter = widget.data.nextHomeLetter(widget.now);
    final visibleMemories = widget.data.visibleMemories.toList()
      ..sort((first, second) {
        final byDate = second.date.compareTo(first.date);
        return byDate != 0
            ? byDate
            : second.updatedAt.compareTo(first.updatedAt);
      });
    final recentMemories = visibleMemories
        .where((memory) => memory.id != featured?.id)
        .take(5)
        .toList(growable: false);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final letterStateLabel = nextLetter == null
        ? null
        : localizedLetterStateLabel(
            l10n,
            nextLetter,
            widget.now,
            widget.openedLetterIds.contains(nextLetter.id),
          );

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
          HomeEntrance(
            animation: _entranceController,
            begin: 0,
            end: .35,
            child: TopBar(
              kicker: l10n.homeKicker,
              title: l10n.homeTitle,
              large: true,
              trailing: AppCircleButton(
                icon: Icons.favorite_rounded,
                tooltip: l10n.homeRecapTooltip,
                onPressed: widget.onRecapTap,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          HomeEntrance(
            animation: _entranceController,
            begin: .08,
            end: .56,
            child: featured == null
                ? HomeEmptyHero(
                    kicker: l10n.homeEmptyKicker,
                    title: l10n.homeEmptyTitle,
                    body: l10n.homeEmptyBody,
                    ctaLabel: l10n.homeEmptyCta,
                    onAddMemory: widget.onAddMemory,
                  )
                : HomeLivingHero(
                    memory: featured,
                    kicker: l10n.homeHeroKicker,
                    loveDays: formatNumber(loveDays),
                    daysLabel: l10n.homeDaysTogether,
                    onTap: widget.onRecapTap,
                  ),
          ),
          const SizedBox(height: AppSpacing.l),
          HomeEntrance(
            animation: _entranceController,
            begin: .18,
            end: .66,
            child: HomeStatsRibbon(
              loveDays: formatNumber(loveDays),
              memoryCount: formatNumber(visibleMemories.length),
              locationCount: formatNumber(widget.data.mapLocationGroups.length),
              loveDaysLabel: l10n.homeDaysTogether,
              memoriesLabel: l10n.homeMemoriesWritten,
              locationsLabel: l10n.homePlacesVisited,
            ),
          ),
          if (recentMemories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            HomeEntrance(
              animation: _entranceController,
              begin: .3,
              end: .78,
              child: HomeMemoryDiscoveryCarousel(
                memories: recentMemories,
                kicker: l10n.homeRecentKicker,
                title: l10n.homeRecentMemories,
                pageLabel: l10n.homePageIndicator,
                featuredLabel: l10n.homeFeaturedBadge,
                onMemoryTap: widget.onMemoryTap,
                reduceMotion: reduceMotion,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          HomeEntrance(
            animation: _entranceController,
            begin: .42,
            end: .9,
            child: HomeCompactLetterSection(
              kicker: l10n.homeLetterKicker,
              title: l10n.homeLetterSectionTitle,
              letter: nextLetter,
              now: widget.now,
              stateLabel: letterStateLabel,
              emptyTitle: l10n.homeNoLettersTitle,
              emptyBody: l10n.homeNoLettersBody,
              onTap: nextLetter == null
                  ? null
                  : () => widget.onLetterTap(nextLetter),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          HomeEntrance(
            animation: _entranceController,
            begin: .55,
            end: 1,
            child: HomeRecapBand(
              title: l10n.homeRecapTitle,
              body: l10n.homeRecapBody,
              ctaLabel: l10n.homeRecapCta,
              onTap: widget.onRecapTap,
            ),
          ),
        ],
      ),
    );
  }
}
