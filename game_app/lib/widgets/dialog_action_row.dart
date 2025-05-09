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
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}
