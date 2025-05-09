import 'package:flutter/material.dart';

/// A reusable neumorphic/soft UI icon button.
///
/// [icon]: The icon to display.
/// [onPressed]: The callback when pressed.
/// [size]: The button's width/height.
/// [iconSize]: The icon's size.
/// [backgroundColor]: The button background color.
/// [borderRadius]: The button border radius.
/// [shadowDark]: The dark shadow color.
/// [shadowLight]: The light shadow color.
class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double? size;
  final double? iconSize;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? shadowDark;
  final Color? shadowLight;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size,
    this.iconSize,
    this.backgroundColor,
    this.borderRadius,
    this.shadowDark,
    this.shadowLight,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = size ?? 40;
    final double effectiveIconSize = iconSize ?? 24;
    final Color baseColor = backgroundColor ?? const Color.fromARGB(255, 255, 255, 255);
    final double effectiveRadius = borderRadius ?? 10.0;
    final Color darkShadow = shadowDark ?? Colors.black.withOpacity(0.3);
    final Color lightShadow = shadowLight ?? Colors.white.withOpacity(0.4);
    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: [
          BoxShadow(color: darkShadow, offset: const Offset(3, 3), blurRadius: 6),
          BoxShadow(color: lightShadow, offset: const Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: effectiveIconSize, color: Colors.black),
        onPressed: onPressed,
        splashRadius: effectiveSize / 2,
        color: Colors.black,
      ),
    );
  }
}
