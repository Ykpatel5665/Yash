import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customizable text field for player names and other inputs.
///
/// [controller]: The text editing controller.
/// [hintText]: Placeholder text.
/// [onSubmitted]: Callback when submitted.
/// [focusNode]: Optional focus node.
/// [keyboardType]: Keyboard type.
/// [obscureText]: Hide input (for passwords).
/// [enabled]: Whether the field is enabled.
/// [backgroundColor]: Container background color.
/// [borderRadius]: Container border radius.
/// [padding]: Container padding.
/// [textStyle]: Custom text style.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = backgroundColor ?? Colors.white;
    final double effectiveRadius = borderRadius ?? 10.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? EdgeInsets.zero;
    final TextStyle effectiveTextStyle = textStyle ?? GoogleFonts.baloo2(color: Colors.black, fontSize: 18);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: effectivePadding,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        style: effectiveTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.baloo2(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.transparent, // Container handles color
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
