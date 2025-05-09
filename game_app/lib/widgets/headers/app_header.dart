import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable app header for consistent AppBar styling.
///
/// [title]: The header text.
/// [centerTitle]: Whether to center the title.
/// [leading]: Optional leading widget (e.g., back button).
/// [actions]: Optional action widgets.
/// [backgroundColor]: Optional background color (default: transparent).
/// [elevation]: Optional elevation (default: 0).
/// [toolbarHeight]: Optional toolbar height.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final double? toolbarHeight;

  const AppHeader({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    final double responsiveFontSize = (MediaQuery.of(context).size.width * 0.08).clamp(22, 36); // Responsive
    return AppBar(
      title: Text(
        title,
        style: (appBarTheme.titleTextStyle ?? GoogleFonts.baloo2(
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize,
          color: Colors.white,
          decoration: TextDecoration.none, // Ensure no decoration
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withAlpha((0.5 * 255).round()),
              offset: const Offset(1.0, 1.0),
            ),
          ],
        )),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading: leading,
      actions: actions,
      toolbarHeight: toolbarHeight ?? appBarTheme.toolbarHeight,
      titleSpacing: appBarTheme.titleSpacing,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
