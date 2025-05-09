import 'package:flutter/material.dart';
import 'dart:ui';

/// A reusable card widget with glassmorphism, rounded corners, and shadow.
/// Use for scoreboards, dialogs, and info cards.
///
/// [child]: The content of the card.
/// [width]: Optional width.
/// [maxWidth]: Optional max width.
/// [padding]: Optional padding.
/// [borderRadius]: Optional border radius.
/// [backgroundColor]: Optional background color (default: semi-transparent black).
/// [border]: Optional border.
/// [boxShadow]: Optional box shadow.
class GameCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const GameCard({
    super.key,
    required this.child,
    this.width,
    this.maxWidth,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = borderRadius ?? 32.0;
    final Color effectiveBg = backgroundColor ?? Colors.black.withOpacity(0.32);
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(24.0);
    final List<BoxShadow> effectiveShadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ];
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              width: width,
              constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
              padding: effectivePadding,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: BorderRadius.circular(effectiveRadius),
                border: border ?? Border.all(color: Colors.white.withOpacity(0.25), width: 2.5),
                boxShadow: effectiveShadow,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
