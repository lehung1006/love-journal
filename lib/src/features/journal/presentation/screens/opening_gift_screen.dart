import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../components/journal_components.dart';

class OpeningGiftScreen extends StatefulWidget {
  const OpeningGiftScreen({required this.onOpenGift, super.key});

  final VoidCallback onOpenGift;

  @override
  State<OpeningGiftScreen> createState() => _OpeningGiftScreenState();
}

class _OpeningGiftScreenState extends State<OpeningGiftScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.ritual)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = disableMotion ? 1.0 : _controller.value;
          final zoom = 1.04 - (.04 * Curves.easeOut.transform(value));

          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: zoom,
                child: const AssetCoverImage(imagePath: AppAssets.heroImage),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.photoOverlay),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenX,
                    AppSpacing.screenTop,
                    AppSpacing.screenX,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      _StaggeredFade(
                        value: value,
                        interval: const Interval(0, .55),
                        child: Text(
                          'Gửi riêng em',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _StaggeredFade(
                        value: value,
                        interval: const Interval(.12, .72),
                        child: Text(
                          'Ba năm, mình vẫn ở đây.',
                          style: AppTextStyles.displayXL.copyWith(
                            color: Colors.white,
                            fontSize: 46,
                            height: 45 / 46,
                            shadows: const [
                              Shadow(
                                color: Color(0x4D000000),
                                offset: Offset(0, 12),
                                blurRadius: 34,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _StaggeredFade(
                        value: value,
                        interval: const Interval(.24, .84),
                        child: Text(
                          'Anh gói lại vài nơi mình đã đi qua, vài ngày mình đã thương nhau, và một lời hẹn thật nhỏ cho chặng sau.',
                          style: AppTextStyles.bodyM.copyWith(
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _StaggeredFade(
                        value: value,
                        interval: const Interval(.42, 1),
                        child: PrimaryButton(
                          label: 'Mở món quà',
                          icon: Icons.favorite_rounded,
                          onPressed: widget.onOpenGift,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  const _StaggeredFade({
    required this.value,
    required this.interval,
    required this.child,
  });

  final double value;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = interval.transform(value.clamp(0, 1));
    return Opacity(
      opacity: curved,
      child: Transform.translate(
        offset: Offset(0, (1 - curved) * 10),
        child: child,
      ),
    );
  }
}
