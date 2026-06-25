import 'package:flutter/material.dart';

abstract final class AppAssets {
  static const heroImage = 'assets/images/anniversary-hero.png';
}

abstract final class AppColors {
  static const paper = Color(0xFFFFF8F2);
  static const paperMuted = Color(0xFFF4EBE4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFFFF4EE);
  static const ink = Color(0xFF20191D);
  static const inkSoft = Color(0xFF3A3036);
  static const muted = Color(0xFF75686F);
  static const mutedLight = Color(0xFF9B8D93);
  static const line = Color(0xFFE7D9CF);
  static const rose = Color(0xFFBF5363);
  static const roseDark = Color(0xFF923B4A);
  static const wine = Color(0xFF5F2634);
  static const teal = Color(0xFF3F7B84);
  static const moss = Color(0xFF687F6F);
  static const amber = Color(0xFFC5964F);
  static const lavender = Color(0xFF87779D);
  static const night = Color(0xFF19151D);
  static const success = Color(0xFF5E8C73);
  static const warning = Color(0xFFC5964F);
  static const danger = Color(0xFFB84A52);

  static const warmPageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [paper, Color(0xFFF7EEE8)],
  );

  static const photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, .46, 1],
    colors: [Color(0x0519151D), Color(0x4D19151D), Color(0xE019151D)],
  );
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const s = 12.0;
  static const m = 16.0;
  static const l = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const screenX = 20.0;
  static const screenTop = 16.0;
  static const sectionGap = 24.0;
  static const cardGap = 12.0;
}

abstract final class AppRadius {
  static const xs = 6.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 18.0;
  static const xl = 26.0;
  static const pill = 999.0;
}

abstract final class AppSizes {
  static const primaryButtonHeight = 52.0;
  static const secondaryButtonHeight = 44.0;
  static const iconButtonSize = 40.0;
  static const tabBarHeight = 64.0;
  static const tabBarBottom = 12.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 520);
  static const ritual = Duration(milliseconds: 900);
  static const standard = Cubic(.2, .8, .2, 1);
  static const soft = Cubic(.16, 1, .3, 1);
}

abstract final class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0x1438222A),
      offset: const Offset(0, 12),
      blurRadius: 28,
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: const Color(0x2E23181F),
      offset: const Offset(0, 18),
      blurRadius: 48,
    ),
  ];

  static List<BoxShadow> get hero => [
    BoxShadow(
      color: const Color(0x3823181F),
      offset: const Offset(0, 26),
      blurRadius: 72,
    ),
  ];
}

abstract final class AppTextStyles {
  static const _displayFallback = ['Georgia', 'Times New Roman'];

  static const displayXL = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: _displayFallback,
    fontSize: 44,
    height: 1,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const displayL = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: _displayFallback,
    fontSize: 34,
    height: 36 / 34,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const titleL = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: _displayFallback,
    fontSize: 26,
    height: 29 / 26,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const titleM = TextStyle(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const bodyL = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const bodyM = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const bodyS = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w800,
    letterSpacing: .8,
  );
}
