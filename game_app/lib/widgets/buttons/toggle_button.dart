import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:auto_size_text/auto_size_text.dart';

/// A reusable toggle/category button for selections.
///
/// [label]: The button text.
/// [selected]: Whether the button is selected.
/// [onTap]: Callback when tapped.
/// [icon]: Optional icon.
/// [selectedColor]: Background color when selected.
/// [unselectedColor]: Background color when not selected.
/// [iconSize]: Icon size.
/// [fontSize]: Font size.
class ToggleButton extends StatelessWidget {
  final Widget label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double? iconSize;
  final double? fontSize;

  const ToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final double responsiveIconSize = iconSize ?? (MediaQuery.of(context).size.width * 0.07).clamp(20, 36);
    // final double responsiveFontSize = fontSize ?? (MediaQuery.of(context).size.width * 0.045).clamp(13, 22);
    final double horizontalPadding = (MediaQuery.of(context).size.width * 0.02).clamp(4, 16);
    final double verticalPadding = (MediaQuery.of(context).size.width * 0.035).clamp(8, 20);
    final Color bg = selected
        ? (selectedColor ?? Colors.white.withOpacity(0.15))
        : (unselectedColor ?? Colors.white.withOpacity(0.05));
    final Color border = selected ? Colors.white : Colors.white24;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding / 3), // Responsive
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
          width: 1.0, // Keep border width same for both selected and unselected
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap, // Remove sound here
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding * 2.2, // Add extra left space
            right: horizontalPadding,
            top: verticalPadding * 0.6,
            bottom: verticalPadding * 0.6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: responsiveIconSize),
                SizedBox(width: horizontalPadding),
              ],
              Expanded(
                child: label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
