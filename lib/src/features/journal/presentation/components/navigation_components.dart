import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';

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
    final l10n = context.l10n;
    final items = [
      _TabSpec(Icons.home_rounded, l10n.navHome),
      _TabSpec(Icons.timeline_rounded, l10n.navTime),
      _TabSpec(Icons.map_rounded, l10n.navMap),
      _TabSpec(Icons.mail_rounded, l10n.navLetters),
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
