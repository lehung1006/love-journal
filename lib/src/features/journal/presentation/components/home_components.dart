import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../journal_formatters.dart';
import '_pressable_scale.dart';
import 'buttons_and_chips.dart';
import 'letter_components.dart';
import 'media_components.dart';
import 'memory_media_viewer.dart';

class HomeEntrance extends StatelessWidget {
  const HomeEntrance({
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: AppMotion.soft),
    );
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - curved.value)),
            child: child,
          ),
        );
      },
    );
  }
}

class HomeLivingHero extends StatelessWidget {
  const HomeLivingHero({
    required this.memory,
    required this.kicker,
    required this.loveDays,
    required this.daysLabel,
    required this.onTap,
    super.key,
  });

  final Memory memory;
  final String kicker;
  final String loveDays;
  final String daysLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('home-living-hero'),
      height: 334,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: 14,
            right: 8,
            top: 14,
            bottom: 4,
            child: Transform.rotate(
              angle: math.pi / 180 * -1.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE9D5BF),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
              ),
            ),
          ),
          Positioned.fill(
            left: 5,
            right: 15,
            top: 5,
            bottom: 13,
            child: Transform.rotate(
              angle: math.pi / 180 * 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: AppShadows.hero,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 12,
            bottom: 12,
            child: PressableScale(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _HomeMemoryCover(memory: memory),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, .38, 1],
                          colors: [
                            Color(0x1419151D),
                            Color(0x4719151D),
                            Color(0xE619151D),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.m,
                      right: AppSpacing.m,
                      bottom: AppSpacing.m,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kicker,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white.withValues(alpha: .78),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    loveDays,
                                    style: AppTextStyles.displayXL.copyWith(
                                      color: Colors.white,
                                      fontSize: 48,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x66000000),
                                          offset: Offset(0, 8),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  daysLabel,
                                  maxLines: 1,
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: Colors.white.withValues(alpha: .82),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            memory.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleM.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            formatDateAndPlace(memory),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyS.copyWith(
                              color: Colors.white.withValues(alpha: .76),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.m,
                      right: AppSpacing.m,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .88),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: AppColors.rose,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeEmptyHero extends StatelessWidget {
  const HomeEmptyHero({
    required this.kicker,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onAddMemory,
    super.key,
  });

  final String kicker;
  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onAddMemory;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-empty-hero'),
      height: 334,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.s),
        boxShadow: AppShadows.hero,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AssetCoverImage(imagePath: AppAssets.heroImage),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .3, 1],
                colors: [
                  Color(0x2419151D),
                  Color(0x7819151D),
                  Color(0xF219151D),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.m,
            right: AppSpacing.m,
            bottom: AppSpacing.m,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kicker,
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleL.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: Colors.white.withValues(alpha: .78),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                PrimaryButton(
                  key: const ValueKey('home-empty-add-memory'),
                  label: ctaLabel,
                  icon: Icons.add_rounded,
                  onPressed: onAddMemory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeStatsRibbon extends StatelessWidget {
  const HomeStatsRibbon({
    required this.loveDays,
    required this.memoryCount,
    required this.locationCount,
    required this.loveDaysLabel,
    required this.memoriesLabel,
    required this.locationsLabel,
    super.key,
  });

  final String loveDays;
  final String memoryCount;
  final String locationCount;
  final String loveDaysLabel;
  final String memoriesLabel;
  final String locationsLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-stats-ribbon'),
      constraints: const BoxConstraints(minHeight: 84),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.line.withValues(alpha: .8)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _HomeStat(value: loveDays, label: loveDaysLabel),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.line,
              indent: AppSpacing.m,
              endIndent: AppSpacing.m,
            ),
            Expanded(
              child: _HomeStat(value: memoryCount, label: memoriesLabel),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.line,
              indent: AppSpacing.m,
              endIndent: AppSpacing.m,
            ),
            Expanded(
              child: _HomeStat(
                value: locationCount,
                label: locationsLabel,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMemoryDiscoveryCarousel extends StatefulWidget {
  const HomeMemoryDiscoveryCarousel({
    required this.memories,
    required this.kicker,
    required this.title,
    required this.pageLabel,
    required this.featuredLabel,
    required this.onMemoryTap,
    required this.reduceMotion,
    super.key,
  });

  final List<Memory> memories;
  final String kicker;
  final String title;
  final String Function(int current, int total) pageLabel;
  final String featuredLabel;
  final ValueChanged<Memory> onMemoryTap;
  final bool reduceMotion;

  @override
  State<HomeMemoryDiscoveryCarousel> createState() =>
      _HomeMemoryDiscoveryCarouselState();
}

class _HomeMemoryDiscoveryCarouselState
    extends State<HomeMemoryDiscoveryCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .86);
  }

  @override
  void didUpdateWidget(covariant HomeMemoryDiscoveryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= widget.memories.length) {
      _currentPage = math.max(0, widget.memories.length - 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home-memory-carousel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.kicker,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.roseDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              widget.pageLabel(_currentPage + 1, widget.memories.length),
              style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 232,
          child: PageView.builder(
            key: const ValueKey('home-memory-page-view'),
            controller: _controller,
            clipBehavior: Clip.none,
            padEnds: false,
            itemCount: widget.memories.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final memory = widget.memories[index];
              return AnimatedBuilder(
                animation: _controller,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: _HomeMemoryCard(
                    memory: memory,
                    featuredLabel: widget.featuredLabel,
                    onTap: () => widget.onMemoryTap(memory),
                  ),
                ),
                builder: (context, child) {
                  if (widget.reduceMotion || !_controller.hasClients) {
                    return child!;
                  }
                  final page = _controller.position.hasContentDimensions
                      ? _controller.page ?? _currentPage.toDouble()
                      : _currentPage.toDouble();
                  final distance = (page - index).abs().clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 8 * distance),
                    child: Transform.scale(
                      scale: 1 - (.045 * distance),
                      alignment: Alignment.centerLeft,
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            for (var index = 0; index < widget.memories.length; index++)
              AnimatedContainer(
                duration: widget.reduceMotion ? Duration.zero : AppMotion.fast,
                curve: AppMotion.standard,
                width: index == _currentPage ? 22 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? AppColors.rose
                      : AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class HomeCompactLetterSection extends StatelessWidget {
  const HomeCompactLetterSection({
    required this.kicker,
    required this.title,
    required this.letter,
    required this.now,
    required this.stateLabel,
    required this.emptyTitle,
    required this.emptyBody,
    required this.onTap,
    super.key,
  });

  final String kicker;
  final String title;
  final Letter? letter;
  final DateTime now;
  final String? stateLabel;
  final String emptyTitle;
  final String emptyBody;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentLetter = letter;
    return Column(
      key: const ValueKey('home-letter-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kicker,
          style: AppTextStyles.label.copyWith(color: AppColors.roseDark),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.s),
        if (currentLetter == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.line),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emptyTitle,
                  style: AppTextStyles.bodyL.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  emptyBody,
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          PressableScale(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 104),
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .74),
                border: const Border.symmetric(
                  horizontal: BorderSide(color: AppColors.line),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Center(
                      child: EnvelopeMark(
                        style: currentLetter.coverStyle,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLetter.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyL.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          currentLetter.isLocked(now)
                              ? currentLetter.occasion
                              : currentLetter.preview ?? currentLetter.occasion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        if (stateLabel case final label?) ...[
                          const SizedBox(height: AppSpacing.s),
                          LockedLetterBadge(
                            label: label,
                            locked: currentLetter.isLocked(now),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.mutedLight,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class HomeRecapBand extends StatelessWidget {
  const HomeRecapBand({
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onTap,
    super.key,
  });

  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      key: const ValueKey('home-recap-band'),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.wine,
          borderRadius: BorderRadius.circular(AppRadius.s),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleM.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(
                      color: Colors.white.withValues(alpha: .72),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Text(
                        ctaLabel,
                        style: AppTextStyles.bodyS.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Container(
              width: 58,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(AppRadius.s),
                border: Border.all(color: Colors.white.withValues(alpha: .16)),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeStat extends StatelessWidget {
  const _HomeStat({
    required this.value,
    required this.label,
    this.color = AppColors.roseDark,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.s,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.titleM.copyWith(color: color),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _HomeMemoryCard extends StatelessWidget {
  const _HomeMemoryCard({
    required this.memory,
    required this.featuredLabel,
    required this.onTap,
  });

  final Memory memory;
  final String featuredLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      key: ValueKey('home-memory-card-${memory.id}'),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.s),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HomeMemoryCover(memory: memory),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x5E19151D)],
                      ),
                    ),
                  ),
                  if (memory.isFeatured)
                    Positioned(
                      left: AppSpacing.s,
                      top: AppSpacing.s,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .9),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              size: 13,
                              color: AppColors.rose,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              featuredLabel,
                              style: AppTextStyles.bodyS.copyWith(
                                color: AppColors.roseDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyL.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    formatDateAndPlace(memory),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
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

class _HomeMemoryCover extends StatelessWidget {
  const _HomeMemoryCover({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final cover = memory.coverMedia;
    if (cover == null) {
      return const AssetCoverImage(imagePath: AppAssets.heroImage);
    }
    if (cover.type == MemoryMediaType.video) {
      return MemoryVideoPreview(
        uri: cover.uri,
        thumbnailUri: cover.thumbnailUri,
        showPlayIcon: false,
      );
    }
    return AssetCoverImage(imagePath: cover.uri);
  }
}
