import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/player.dart';

/// A reusable widget for displaying player information in a list.
///
/// [player]: The player object containing name and color.
/// [onColorTap]: Callback when the color box is tapped.
/// [onRemoveTap]: Callback when the remove button is pressed.
class PlayerListTile extends StatelessWidget {
  final Player player;
  final VoidCallback onColorTap;
  final VoidCallback onRemoveTap;

  const PlayerListTile({
    super.key,
    required this.player,
    required this.onColorTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: onColorTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: player.color,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
        ),
      ),
      title: Text(
        player.name,
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        tooltip: 'Remove ${player.name}',
        onPressed: onRemoveTap,
        splashRadius: 24,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
