import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart';

class TruthDareQuestionScreen extends StatelessWidget {
  final String playerName;
  final String questionText;
  final bool isTruth;
  final VoidCallback onDone;
  final VoidCallback onForfeit;

  const TruthDareQuestionScreen({
    super.key,
    required this.playerName,
    required this.questionText,
    required this.isTruth,
    required this.onDone,
    required this.onForfeit,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = 24.0;
    final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
    final double buttonFontSize = (screenSize.width * 0.05).clamp(18, 28);
    final Color truthColor = Color(0xFF4DD0E1);
    final Color dareColor = Color(0xFFFF5F6D);
    final Color bgColor = isTruth ? truthColor.withOpacity(0.18) : dareColor.withOpacity(0.18);
    final Color mainColor = isTruth ? truthColor : dareColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.32),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: mainColor.withOpacity(0.25),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isTruth ? 'Truth' : 'Dare',
                style: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Text(
                "$playerName, your question:",
                style: GoogleFonts.baloo2(
                  fontSize: fontSize,
                  color: Colors.white.withOpacity(0.92),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18),
              Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  questionText,
                  style: GoogleFonts.baloo2(
                    fontSize: fontSize + 2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onForfeit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      child: const Text('Forfeit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
