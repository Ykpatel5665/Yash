import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable row for dialog actions (e.g., Yes/No, Save/Cancel).
///
/// [actions]: List of action buttons (usually 2).
/// [spacing]: Space between buttons.
class DialogActionRow extends StatelessWidget {
  final List<Widget> actions;
  final double spacing;

  const DialogActionRow({
    super.key,
    required this.actions,
    this.spacing = 18,
  });

  @override
  Widget build(BuildContext context) {
    final double responsiveSpacing = (MediaQuery.of(context).size.width * 0.045).clamp(10, 28); // Responsive spacing
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing == 18 ? responsiveSpacing : spacing),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}
