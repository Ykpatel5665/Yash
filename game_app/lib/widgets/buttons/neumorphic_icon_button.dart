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
    final double responsiveSize = size ?? (MediaQuery.of(context).size.width * 0.11).clamp(32, 60);
    final double responsiveIconSize = iconSize ?? (MediaQuery.of(context).size.width * 0.06).clamp(18, 36);
    final double responsiveRadius = borderRadius ?? (MediaQuery.of(context).size.width * 0.025).clamp(6, 18);
    final Color baseColor = backgroundColor ?? const Color.fromARGB(255, 255, 255, 255);
    final Color darkShadow = shadowDark ?? Colors.black.withOpacity(0.3);
    final Color lightShadow = shadowLight ?? Colors.white.withOpacity(0.4);
    return Container(
      width: responsiveSize,
      height: responsiveSize,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(responsiveRadius),
        boxShadow: [
          BoxShadow(color: darkShadow, offset: const Offset(3, 3), blurRadius: 6),
          BoxShadow(color: lightShadow, offset: const Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: responsiveIconSize, color: Colors.black),
        onPressed: onPressed,
        splashRadius: responsiveSize / 2,
        color: Colors.black,
      ),
    );
  }
}
