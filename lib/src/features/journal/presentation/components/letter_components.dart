import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../journal_localizations.dart';
import '_pressable_scale.dart';

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
      child: PressableScale(
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
                    label: localizedLetterStateLabel(
                      context.l10n,
                      letter,
                      now,
                      opened,
                    ),
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
