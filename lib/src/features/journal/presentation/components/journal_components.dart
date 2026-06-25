import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/journal_models.dart';
import '../journal_formatters.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenX,
      vertical: AppSpacing.screenTop,
    ),
    this.safeTop = true,
    this.safeBottom = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.warmPageGradient),
      child: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).top);
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    required this.title,
    this.kicker,
    this.leading,
    this.trailing,
    this.large = false,
    super.key,
  });

  final String title;
  final String? kicker;
  final Widget? leading;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kicker != null) ...[
          Text(
            kicker!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: (large ? AppTextStyles.displayL : AppTextStyles.titleL)
              .copyWith(color: AppColors.ink),
        ),
      ],
    );

    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.s)],
        Expanded(child: titleWidget),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s),
          trailing!,
        ],
      ],
    );
  }
}

class AppCircleButton extends StatelessWidget {
  const AppCircleButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isActive = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final background = isActive ? AppColors.rose : Colors.white;
    final foreground = isActive ? Colors.white : AppColors.rose;

    return SizedBox.square(
      dimension: AppSizes.iconButtonSize,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: background.withValues(alpha: isActive ? 1 : .9),
          shape: const CircleBorder(side: BorderSide(color: Color(0x2EBF5363))),
          elevation: 0,
          shadowColor: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(icon, color: foreground, size: 20),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.primaryButtonHeight,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.rose.withValues(alpha: .4),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.secondaryButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roseDark,
          side: const BorderSide(color: AppColors.line),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Material(
        color: selected ? AppColors.rose : Colors.white.withValues(alpha: .82),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? AppColors.rose
                : AppColors.rose.withValues(alpha: .18),
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  color: selected ? Colors.white : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
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
    return _TappableScale(
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
  const MemoryListCard({required this.memory, required this.onTap, super.key});

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imagePath = memory.coverMedia?.uri;

    return _TappableScale(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineSpine extends StatelessWidget {
  const TimelineSpine({
    required this.memories,
    required this.onMemoryTap,
    super.key,
  });

  final List<Memory> memories;
  final ValueChanged<Memory> onMemoryTap;

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

class LetterCard extends StatelessWidget {
  const LetterCard({
    required this.letter,
    required this.now,
    required this.opened,
    required this.onTap,
    super.key,
  });

  final Letter letter;
  final DateTime now;
  final bool opened;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = letter.isLocked(now);
    final description = locked
        ? letter.occasion
        : letter.preview ?? letter.occasion;

    return Opacity(
      opacity: locked ? .72 : 1,
      child: _TappableScale(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.fromLTRB(82, 16, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -64,
                top: 14,
                child: EnvelopeMark(style: letter.coverStyle, size: 46),
              ),
              Positioned(
                left: -108,
                bottom: -62,
                child: IgnorePointer(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.rose.withValues(alpha: .12),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    letter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyL.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  LockedLetterBadge(
                    label: letterStateLabel(letter, now, opened),
                    locked: locked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LockedLetterBadge extends StatelessWidget {
  const LockedLetterBadge({
    required this.label,
    required this.locked,
    super.key,
  });

  final String label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: locked ? AppColors.paperMuted : AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: locked
              ? AppColors.line
              : AppColors.rose.withValues(alpha: .18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              locked ? Icons.lock_rounded : Icons.favorite_rounded,
              size: 13,
              color: locked ? AppColors.muted : AppColors.rose,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                color: locked ? AppColors.muted : AppColors.roseDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnvelopeMark extends StatelessWidget {
  const EnvelopeMark({required this.style, this.size = 70, super.key});

  final LetterCoverStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (style) {
      LetterCoverStyle.rose => AppColors.rose,
      LetterCoverStyle.paper => AppColors.amber,
      LetterCoverStyle.night => AppColors.wine,
    };

    return SizedBox(
      width: size,
      height: size * .74,
      child: CustomPaint(painter: _EnvelopePainter(color: color)),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  _EnvelopePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = RRect.fromRectAndRadius(
      Offset(0, size.height * .18) & Size(size.width, size.height * .72),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, stroke);

    final path = Path()
      ..moveTo(size.width * .1, size.height * .22)
      ..lineTo(size.width * .5, size.height * .58)
      ..lineTo(size.width * .9, size.height * .22);
    canvas.drawPath(path, stroke);

    final flap = Path()
      ..moveTo(size.width * .1, size.height * .9)
      ..lineTo(size.width * .5, size.height * .58)
      ..lineTo(size.width * .9, size.height * .9);
    canvas.drawPath(flap, stroke);
  }

  @override
  bool shouldRepaint(covariant _EnvelopePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    required this.currentIndex,
    required this.onChanged,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      _TabSpec(Icons.home_rounded, 'Home'),
      _TabSpec(Icons.timeline_rounded, 'Time'),
      _TabSpec(Icons.map_rounded, 'Map'),
      _TabSpec(Icons.mail_rounded, 'Thư'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        0,
        AppSpacing.m,
        AppSizes.tabBarBottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: AppSizes.tabBarHeight,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.line.withValues(alpha: .92)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x2638222A),
                  offset: const Offset(0, 16),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: _BottomTabItem(
                      spec: items[index],
                      selected: currentIndex == index,
                      onTap: () => onChanged(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AppMotion.fast,
            width: selected ? 28 : 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? AppColors.rose : const Color(0xFFE8DCD4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.rose.withValues(alpha: .25),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              spec.icon,
              size: 15,
              color: selected ? Colors.white : AppColors.mutedLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            spec.label,
            style: AppTextStyles.bodyS.copyWith(
              fontSize: 10,
              height: 13 / 10,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.roseDark : AppColors.mutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

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

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyL.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

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

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.roseDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _TappableScale extends StatefulWidget {
  const _TappableScale({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<_TappableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }
}
