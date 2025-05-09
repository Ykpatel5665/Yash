import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A primary button with gradient/shadow support, used throughout the app.
///
/// [label]: The button text.
/// [onPressed]: The callback when pressed.
/// [icon]: Optional icon to display.
/// [gradient]: Optional gradient background. If null, uses [backgroundColor].
/// [backgroundColor]: Fallback background color if no gradient.
/// [foregroundColor]: Text/icon color.
/// [padding]: Custom padding.
/// [borderRadius]: Custom border radius.
/// [fontSize]: Custom font size.
/// [elevation]: Shadow elevation.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? fontSize;
  final double? elevation;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.elevation,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = borderRadius ?? 10.0;
    final double effectiveFontSize = fontSize ?? 22.0;
    final Color effectiveFg = foregroundColor ?? Colors.white;
    final Color effectiveBg = backgroundColor ?? Colors.black;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 18);
    final double effectiveElevation = elevation ?? 3.0;

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: effectiveFg, size: effectiveFontSize + 8),
          const SizedBox(width: 12),
        ],
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            fontSize: effectiveFontSize,
            color: effectiveFg,
            shadows: [
              const Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );

    Widget button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: gradient == null ? effectiveBg : Colors.transparent,
        foregroundColor: effectiveFg,
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveRadius)),
        elevation: gradient == null ? effectiveElevation : 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: effectiveFontSize),
      ),
      child: buttonChild,
    );

    if (gradient != null) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(effectiveRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: button,
      );
    }

    return button;
  }
}
