import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final String label;
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
    final Color bg = selected
        ? (selectedColor ?? Colors.white.withOpacity(0.15))
        : (unselectedColor ?? Colors.white.withOpacity(0.05));
    final Color border = selected ? Colors.white : Colors.white24;
    final double effectiveIconSize = iconSize ?? 28;
    final double effectiveFontSize = fontSize ?? 15;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
          width: selected ? 2.5 : 1.0,
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white, size: effectiveIconSize),
              if (icon != null) const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: effectiveFontSize,
                  height: 1.1,
                  shadows: selected
                      ? [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.white.withOpacity(0.3),
                          )
                        ]
                      : [],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
