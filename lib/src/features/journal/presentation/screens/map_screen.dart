import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/journal_models.dart';
import '../components/journal_components.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({required this.data, required this.onMemoryTap, super.key});

  final JournalData data;
  final ValueChanged<Memory> onMemoryTap;

  @override
  Widget build(BuildContext context) {
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
            kicker: 'Những nơi mình qua',
            title: 'Bản đồ',
            trailing: AppCircleButton(
              icon: Icons.location_pin,
              tooltip: 'Địa điểm',
              onPressed: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AspectRatio(
            aspectRatio: .64,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.s),
                border: Border.all(color: AppColors.line),
                color: const Color(0xFFF7EFE9),
                boxShadow: AppShadows.card,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _MapWashPainter()),
                  for (final entry in data.places.asMap().entries)
                    _PlacePin(
                      place: entry.value,
                      alignment: _pinAlignment(entry.key),
                      onTap: () => _showPlace(context, entry.value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _pinAlignment(int index) {
    const positions = [
      Alignment(-.54, -.36),
      Alignment(.24, -.12),
      Alignment(-.16, .28),
      Alignment(.56, .46),
    ];
    return positions[index % positions.length];
  }

  void _showPlace(BuildContext context, Place place) {
    final memories = data.memoriesForPlace(place);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return PlacePreviewSheet(
          place: place,
          memories: memories,
          onOpen: () {
            Navigator.of(context).pop();
            if (memories.isNotEmpty) {
              onMemoryTap(memories.first);
            }
          },
        );
      },
    );
  }
}

class _PlacePin extends StatelessWidget {
  const _PlacePin({
    required this.place,
    required this.alignment,
    required this.onTap,
  });

  final Place place;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.rose,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withValues(alpha: .28),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .86),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                place.name,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapWashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x6BFFFFFF), Color(0x3D3F7B84)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final routePaint = Paint()
      ..color = AppColors.rose.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(size.width * .18, size.height * .28)
      ..cubicTo(
        size.width * .76,
        size.height * .05,
        size.width * .68,
        size.height * .52,
        size.width * .36,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .1,
        size.height * .58,
        size.width * .52,
        size.height * .78,
        size.width * .72,
        size.height * .72,
      );
    canvas.drawPath(route, routePaint);

    final softLinePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawLine(
      Offset(size.width * -.08, size.height * .18),
      Offset(size.width * .94, size.height * .9),
      softLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
