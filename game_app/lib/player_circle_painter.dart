import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerCirclePainter extends CustomPainter {
  final List<String> players;
  final double radius;
  final int? highlightedIndex;

  PlayerCirclePainter({required this.players, required this.radius, this.highlightedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    if (players.isEmpty) return;

    final double sweepAngle = (2 * math.pi) / players.length;
    final Paint sectionPaint = Paint()..style = PaintingStyle.fill;
    final double responsiveBorderWidth = math.max(10.0, radius * 0.015);
    final Paint outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = responsiveBorderWidth;

    for (int i = 0; i < players.length; i++) {
      final double startAngle = -math.pi / 2 + i * sweepAngle;
      // Use a default color palette or a generated color
      final Color color = Colors.primaries[i % Colors.primaries.length].shade400;
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
          ..color = Colors.white.withOpacity(0.45) // Decreased from 0.7 for less glow
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
      final double spacing = radius * 0.08;
      final double textRadius = radius - spacing;
      final double textX = center.dx + textRadius * math.cos(textAngle);
      final double textY = center.dy + textRadius * math.sin(textAngle);
      final double responsiveFontSize = radius * 0.12;
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
      final double maxTextWidth = sweepAngle * textRadius * 2.2;
      final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      tp.layout(minWidth: 0, maxWidth: maxTextWidth);
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi);
      tp.paint(canvas, Offset(0, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, radius, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant PlayerCirclePainter oldDelegate) {
    return oldDelegate.players != players || oldDelegate.highlightedIndex != highlightedIndex;
  }
}

class PlayerCircle extends StatelessWidget {
  final List<String> players;
  final double size;
  final int? highlightedIndex;
  final int? previousIndex;
  final bool animated;
  final Duration animationDuration;

  const PlayerCircle({
    super.key,
    required this.players,
    this.size = 300.0,
    this.highlightedIndex,
    this.previousIndex,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    if (animated && previousIndex != null && highlightedIndex != null && previousIndex != highlightedIndex) {
      return _AnimatedPlayerCircle(
        players: players,
        size: size,
        fromIndex: previousIndex!,
        toIndex: highlightedIndex!,
        duration: animationDuration,
      );
    }
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
          radius: (size / 2) - (responsivePainterBorderWidth / 2),
          highlightedIndex: highlightedIndex,
        ),
      ),
    );
  }
}

class _AnimatedPlayerCircle extends StatefulWidget {
  final List<String> players;
  final double size;
  final int fromIndex;
  final int toIndex;
  final Duration duration;

  const _AnimatedPlayerCircle({
    required this.players,
    required this.size,
    required this.fromIndex,
    required this.toIndex,
    required this.duration,
  });

  @override
  State<_AnimatedPlayerCircle> createState() => _AnimatedPlayerCircleState();
}

class _AnimatedPlayerCircleState extends State<_AnimatedPlayerCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;
        final int playerCount = widget.players.length;
        double anglePerPlayer = (2 * math.pi) / playerCount;
        double fromAngle = widget.fromIndex * anglePerPlayer;
        double toAngle = widget.toIndex * anglePerPlayer;
        // Shortest direction
        double delta = toAngle - fromAngle;
        if (delta.abs() > math.pi) {
          if (delta > 0) {
            delta -= 2 * math.pi;
          } else {
            delta += 2 * math.pi;
          }
        }
        double currentAngle = fromAngle + delta * t;
        int highlighted = ((currentAngle / anglePerPlayer).round()) % playerCount;
        // ...existing code for drawing circle...
        const Color baseColor = Color.fromARGB(255, 235, 235, 235);
        final Color shadowDark = Colors.black.withOpacity(0.35);
        final Color shadowLight = Colors.white.withOpacity(0.6);
        final double shadowOffset = widget.size * 0.015;
        final double blurRadius = widget.size * 0.03;
        final double responsivePainterBorderWidth = math.max(2.0, (widget.size / 2) * 0.015);
        return Container(
          width: widget.size,
          height: widget.size,
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
            size: Size(widget.size, widget.size),
            painter: PlayerCirclePainter(
              players: widget.players,
              radius: (widget.size / 2) - (responsivePainterBorderWidth / 2),
              highlightedIndex: highlighted,
            ),
          ),
        );
      },
    );
  }
}
