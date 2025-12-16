import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final double height;
  final Color activeColor;
  final Color backgroundColor;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.activeColor = Colors.blue,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          return LinearProgressIndicator(
            value: v,
            minHeight: height,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(activeColor),
          );
        },
      ),
    );
  }
}
