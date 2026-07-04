import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';

class LetterDetailScreen extends StatefulWidget {
  const LetterDetailScreen({required this.letter, super.key});

  final Letter letter;

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.slow)
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
      body: AppScaffold(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          34,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = disableMotion ? 1.0 : _controller.value;
            final unfold = Curves.easeOutCubic.transform(value);

            return ListView(
              children: [
                Row(
                  children: [
                    AppCircleButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Quay lại',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Mở vào hôm nay',
                          style: AppTextStyles.bodyS,
                        ),
                      ),
                    ),
                    AppCircleButton(
                      icon: Icons.favorite_border_rounded,
                      tooltip: 'Giữ lá thư',
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Transform.scale(
                    scaleY: .82 + (.18 * unfold),
                    child: EnvelopeMark(
                      style: widget.letter.coverStyle,
                      size: 118,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  widget.letter.occasion,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.letter.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.xl),
                Opacity(
                  opacity: unfold,
                  child: Transform.translate(
                    offset: Offset(0, (1 - unfold) * 12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .86),
                        borderRadius: BorderRadius.circular(AppRadius.s),
                        border: Border.all(color: AppColors.line),
                        boxShadow: AppShadows.card,
                      ),
                      child: Text(
                        widget.letter.body,
                        style: AppTextStyles.bodyL.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Giữ lá thư này',
                  icon: Icons.bookmark_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
