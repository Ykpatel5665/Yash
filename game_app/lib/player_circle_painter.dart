import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerCirclePainter extends CustomPainter {
  final List<String> players;
  final double radius;
  // Define a new list of distinct, contrasting colors
  final List<Color> _distinctColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.lime,
    Colors.indigo,
    Colors.brown,
    // Add more distinct colors if needed
  ];

  PlayerCirclePainter({required this.players, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    if (players.isEmpty) return;

    final double sweepAngle = (2 * math.pi) / players.length;
    final Paint sectionPaint = Paint()..style = PaintingStyle.fill;
    // Keep the thin inner border between sections
    final Paint innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3) // Subtle white line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // Thin border

    // Make outer border width responsive
    final double responsiveBorderWidth = math.max(10.0, radius * 0.015); // Ensure minimum width
    final Paint outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = responsiveBorderWidth; // Use responsive width

    int previousColorIndex = -1; // Track the previous color index

    for (int i = 0; i < players.length; i++) {
      final double startAngle = -math.pi / 2 + i * sweepAngle;

      // --- Color Selection Logic using _distinctColors ---
      int colorIndex = i % _distinctColors.length;
      // Ensure adjacent sections have different colors
      if (players.length > 1 && colorIndex == previousColorIndex) {
        colorIndex = (colorIndex + 1) % _distinctColors.length;
      }
      // Special case for the last segment if it matches the first segment's color
      if (players.length > 2 && i == players.length - 1) {
        int firstColorIndex = 0 % _distinctColors.length;
        if (colorIndex == firstColorIndex) {
          colorIndex = (colorIndex + 1) % _distinctColors.length;
          // Avoid collision with the second-to-last segment's color as well
          if (colorIndex == (i - 1) % _distinctColors.length) {
             colorIndex = (colorIndex + 1) % _distinctColors.length;
          }
        }
      }

      final Color color = _distinctColors[colorIndex];
      previousColorIndex = colorIndex; // Update previous color index
      // --- End Color Selection Logic ---

      // Draw the section arc
      sectionPaint.color = color; // Use the selected distinct color directly
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        sectionPaint,
      );

      // --- Draw Player Name ---
      final double textAngle = startAngle + sweepAngle / 2;
      // Adjust radius to place text slightly more towards the center
      final double textRadius = radius * 0.7; // Decreased from 0.8
      final double textX = center.dx + textRadius * math.cos(textAngle);
      final double textY = center.dy + textRadius * math.sin(textAngle);

      // Calculate responsive font size based on radius
      // Adjust the multiplier (e.g., 0.1, 0.12) as needed for visual balance
      final double responsiveFontSize = radius * 0.12;

      final TextSpan span = TextSpan(
        style: GoogleFonts.baloo2(
          color: Colors.white,
          // Use the calculated responsive font size
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

      // Rotate canvas to draw text along the radius, reading from outside in
      canvas.save();
      canvas.translate(textX, textY);
      // Rotate along the angle of the center of the slice + 180 degrees
      canvas.rotate(textAngle + math.pi); // Added math.pi for 180-degree rotation
      // Adjust offset so text is centered at (textX, textY) after rotation
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      // --- End Draw Player Name ---
    }

     // Draw outer border using the dedicated paint
     canvas.drawCircle(center, radius, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant PlayerCirclePainter oldDelegate) {
    // Repaint if players list changes
    return oldDelegate.players != players;
  }
}

// Optional: A simple widget to host the painter
class PlayerCircle extends StatelessWidget {
  final List<String> players;
  final double size; // Diameter of the circle

  const PlayerCircle({
    super.key,
    required this.players,
    this.size = 300.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    // Define neumorphic colors (adjust as needed or get from theme)
    const Color baseColor = Color.fromARGB(255, 235, 235, 235); // Light grey base for effect
    final Color shadowDark = Colors.black.withOpacity(0.35);
    final Color shadowLight = Colors.white.withOpacity(0.6);

    // Calculate responsive shadow properties based on size
    final double shadowOffset = size * 0.015; // e.g., 1.5% of size
    final double blurRadius = size * 0.03;   // e.g., 3% of size
    // Calculate responsive border width for the painter's radius adjustment
    final double responsivePainterBorderWidth = math.max(2.0, (size / 2) * 0.015);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor, // Base color for the container behind the painter
        shape: BoxShape.circle, // Make the container circular
        boxShadow: [
          // Outer shadow (dark)
          BoxShadow(
            color: shadowDark,
            offset: Offset(shadowOffset, shadowOffset), // Use responsive offset
            blurRadius: blurRadius, // Use responsive blur
          ),
          // Inner highlight (light)
          BoxShadow(
            color: shadowLight,
            offset: Offset(-shadowOffset, -shadowOffset), // Use responsive offset
            blurRadius: blurRadius, // Use responsive blur
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: PlayerCirclePainter(
          players: players,
          // Adjust radius slightly based on responsive border width
          radius: (size / 2) - (responsivePainterBorderWidth / 2),
        ),
      ),
    );
  }
}
