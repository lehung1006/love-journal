import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

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
