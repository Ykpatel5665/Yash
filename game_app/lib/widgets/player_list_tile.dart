import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/player.dart';

/// A reusable widget for displaying player information in a list.
///
/// [player]: The player object containing name and color.
/// [onRemoveTap]: Callback when the remove button is pressed.
class PlayerListTile extends StatelessWidget {
  final Player player;
  final VoidCallback onRemoveTap;

  const PlayerListTile({
    super.key,
    required this.player,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = (MediaQuery.of(context).size.width * 0.09).clamp(28, 48); // Responsive
    final double borderRadius = (MediaQuery.of(context).size.width * 0.025).clamp(6, 16); // Responsive
    final double borderWidth = (MediaQuery.of(context).size.width * 0.011).clamp(2, 6); // Responsive
    final double fontSize = (MediaQuery.of(context).size.width * 0.045).clamp(14, 22); // Responsive
    final double splashRadius = (MediaQuery.of(context).size.width * 0.06).clamp(18, 32); // Responsive
    final double contentPaddingH = (MediaQuery.of(context).size.width * 0.02).clamp(4, 16);
    return ListTile(
      // Remove the leading color box
      title: Text(
        player.name,
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        tooltip: 'Remove ${player.name}',
        onPressed: onRemoveTap,
        splashRadius: splashRadius,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: contentPaddingH, vertical: 0),
    );
  }
}
