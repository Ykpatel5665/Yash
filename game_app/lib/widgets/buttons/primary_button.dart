import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
    final double responsiveRadius = borderRadius ?? (MediaQuery.of(context).size.width * 0.025).clamp(6, 18);
    final double responsiveFontSize = fontSize ?? (MediaQuery.of(context).size.width * 0.055).clamp(15, 28);
    final EdgeInsetsGeometry responsivePadding = padding ?? EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.018).clamp(8, 22));
    final Color effectiveFg = foregroundColor ?? Colors.white;
    final Color effectiveBg = backgroundColor ?? Colors.black;
    final double effectiveElevation = elevation ?? 3.0;

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: effectiveFg, size: responsiveFontSize + 8),
          SizedBox(width: (MediaQuery.of(context).size.width * 0.025).clamp(6, 18)),
        ],
        AutoSizeText(
          label,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            fontSize: responsiveFontSize,
            color: effectiveFg,
            shadows: [
              const Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2)),
            ],
          ),
          minFontSize: 10,
          maxLines: 2,
          wrapWords: true,
        ),
      ],
    );

    Widget button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: gradient == null ? effectiveBg : Colors.transparent,
        foregroundColor: effectiveFg,
        padding: responsivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveRadius)),
        elevation: gradient == null ? effectiveElevation : 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: responsiveFontSize),
      ),
      child: buttonChild,
    );

    if (gradient != null) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(responsiveRadius),
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
