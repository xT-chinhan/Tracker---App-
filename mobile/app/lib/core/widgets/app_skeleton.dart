import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({required this.width, required this.height, super.key});

  final double width;
  final double height;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final box = SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.radius.xs),
          color: const Color(0xFFECEBE7),
        ),
      ),
    );
    if (reduceMotion) return box;
    return AnimatedBuilder(
      animation: _controller,
      child: box,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5 + _controller.value * 3, 0),
          end: Alignment(-0.5 + _controller.value * 3, 0),
          colors: const [
            Color(0xFFECEBE7),
            Color(0xFFF4F3F0),
            Color(0xFFECEBE7),
          ],
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}
