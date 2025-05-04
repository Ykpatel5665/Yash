import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerCirclePainter extends CustomPainter {
  final List<String> players;
  final List<Color> colors;
  final double radius;
  final int? highlightedIndex;

  PlayerCirclePainter({required this.players, required this.colors, required this.radius, this.highlightedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    if (players.isEmpty) return;

    final double sweepAngle = (2 * math.pi) / players.length;
    final Paint sectionPaint = Paint()..style = PaintingStyle.fill;
    final Paint innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double responsiveBorderWidth = math.max(10.0, radius * 0.015);
    final Paint outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = responsiveBorderWidth;

    for (int i = 0; i < players.length; i++) {
      final double startAngle = -math.pi / 2 + i * sweepAngle;
      final Color color = (i < colors.length) ? colors[i] : Colors.grey;
      sectionPaint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        sectionPaint,
      );
      if (highlightedIndex != null && i == highlightedIndex) {
        final Paint highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = responsiveBorderWidth * 2.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          highlightPaint,
        );
      }
      final double textAngle = startAngle + sweepAngle / 2;
      final double textRadius = radius * 0.7;
      final double textX = center.dx + textRadius * math.cos(textAngle);
      final double textY = center.dy + textRadius * math.sin(textAngle);
      final double responsiveFontSize = radius * 0.12;
      // --- Dynamic text color based on background ---
      // Compute luminance to decide text color
      final double luminance = color.computeLuminance();
      final Color textColor = luminance > 0.6 ? Colors.black : Colors.white;
      final TextSpan span = TextSpan(
        style: GoogleFonts.baloo2(
          color: textColor,
          fontSize: responsiveFontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(1.0, 1.0),
            ),
          ],
        ),
        text: players[i],
      );
      final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, radius, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant PlayerCirclePainter oldDelegate) {
    return oldDelegate.players != players || oldDelegate.colors != colors || oldDelegate.highlightedIndex != highlightedIndex;
  }
}

class PlayerCircle extends StatelessWidget {
  final List<String> players;
  final List<Color> colors;
  final double size;
  final int? highlightedIndex;

  const PlayerCircle({
    super.key,
    required this.players,
    required this.colors,
    this.size = 300.0,
    this.highlightedIndex,
  });

  @override
  Widget build(BuildContext context) {
    const Color baseColor = Color.fromARGB(255, 235, 235, 235);
    final Color shadowDark = Colors.black.withOpacity(0.35);
    final Color shadowLight = Colors.white.withOpacity(0.6);
    final double shadowOffset = size * 0.015;
    final double blurRadius = size * 0.03;
    final double responsivePainterBorderWidth = math.max(2.0, (size / 2) * 0.015);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: blurRadius,
          ),
          BoxShadow(
            color: shadowLight,
            offset: Offset(-shadowOffset, -shadowOffset),
            blurRadius: blurRadius,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: PlayerCirclePainter(
          players: players,
          colors: colors,
          radius: (size / 2) - (responsivePainterBorderWidth / 2),
          highlightedIndex: highlightedIndex,
        ),
      ),
    );
  }
}
