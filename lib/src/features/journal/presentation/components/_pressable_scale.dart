import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
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
