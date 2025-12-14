import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double value; // 0..1
  final double height;
  final Color activeColor;
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.activeColor = Colors.blue,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _anim = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  color: Colors.grey.withValues(alpha: 0.3),
                  height: widget.height,
                ),
                FractionallySizedBox(
                  widthFactor: _anim.value,
                  child: Container(
                    color: widget.activeColor,
                    height: widget.height,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
