import 'package:flutter/material.dart';

class IconBubble extends StatelessWidget {
  const IconBubble({
    required this.icon,
    this.size = 40,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected ? colors.primary : colors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.475,
        color: selected ? colors.onPrimary : const Color(0xFF3A3935),
      ),
    );
  }
}
