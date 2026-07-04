import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

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
