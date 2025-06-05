import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../l10n/app_localizations.dart';
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
    final double fontSize = (MediaQuery.of(context).size.width * 0.045).clamp(14, 22); // Responsive
    final double splashRadius = (MediaQuery.of(context).size.width * 0.06).clamp(18, 32); // Responsive
    final double contentPaddingH = (MediaQuery.of(context).size.width * 0.02).clamp(4, 16);
    return ListTile(
      // Remove the leading color box
      title: AutoSizeText(
        player.name,
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        minFontSize: 10,
        maxLines: 2,
        wrapWords: true,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        tooltip: '${AppLocalizations.of(context)!.remove} ${player.name}',
        onPressed: onRemoveTap,
        splashRadius: splashRadius,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: contentPaddingH, vertical: 0),
    );
  }
}
