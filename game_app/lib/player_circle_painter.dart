import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerCirclePainter extends CustomPainter {
  final List<String> players;
  final double radius;
  final int? highlightedIndex;

  // LOCKED: 20 high-saturation, punchy colors for the wheel (reordered and tweaked for maximum contrast between neighbors)
  static const List<Color> _basePlayerColors = [
Color(0xFFFF3D00), // Blaze Orange
  Color(0xFF00B0FF), // Electric Sky Blue
  Color(0xFFFFEA00), // Danger Yellow
  Color(0xFF00E676), // Toxic Green
  Color(0xFFD500F9), // Neon Violet
  Color(0xFFFF1744), // Intense Red
  Color(0xFF00E5FF), // Aqua Shock
  Color(0xFFFF6D00), // Punch Orange
  Color(0xFF69F0AE), // Mint Flash
  Color(0xFF651FFF), // Vivid Indigo
  Color(0xFFFF4081), // Arcade Pink
  Color(0xFF00C853), // Game Green
  Color(0xFF6200EA), // Power Purple
  Color(0xFFFFAB00), // Citrus Amber
  Color(0xFF2979FF), // Bold Blue
  Color(0xFFF50057), // Flash Pink
  Color(0xFF76FF03), // Bright Lime
  Color(0xFFDD2C00), // Fire Red
  Color(0xFF00B8D4), // Game Cyan
  Color(0xFF304FFE), // Hardcore Blue
  ];

  // Returns a shuffled copy of the color palette
  static List<Color> shuffleColors() {
    final colors = List<Color>.from(_basePlayerColors);
    colors.shuffle();
    return colors;
  }

  final List<Color> playerColors;

  PlayerCirclePainter({
    required this.players,
    required this.radius,
    this.highlightedIndex,
    List<Color>? playerColors,
  }) : playerColors = playerColors ?? _basePlayerColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    if (players.isEmpty) return;

    final double sweepAngle = (2 * math.pi) / players.length;
    final double responsiveBorderWidth = math.max(10.0, radius * 0.015);
    final Paint outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = responsiveBorderWidth;

    for (int i = 0; i < players.length; i++) {
      final double startAngle = -math.pi / 2 + i * sweepAngle;
      final Color baseColor = playerColors[i % playerColors.length];
      final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
      // Use a radial gradient for each slice (center 70% opacity, edge 100%)
      final Paint sectionPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [baseColor.withOpacity(0.7), baseColor],
          stops: const [0.3, 1.0],
        ).createShader(arcRect)
        ..style = PaintingStyle.fill;
      // Draw only the slice using a path
      final Path slicePath = Path();
      slicePath.moveTo(center.dx, center.dy);
      slicePath.arcTo(
        arcRect,
        startAngle,
        sweepAngle,
        false,
      );
      slicePath.close();
      canvas.save();
      canvas.clipPath(slicePath);
      canvas.drawCircle(center, radius, sectionPaint);
      canvas.restore();
      if (highlightedIndex != null && i == highlightedIndex) {
        // Add a subtle white radial glow fill for the highlighted slice
        final Paint glowFill = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.22),
              Colors.transparent,
            ],
            stops: [0.0, 1.0],
          ).createShader(arcRect)
          ..style = PaintingStyle.fill;
        canvas.save();
        canvas.clipPath(slicePath);
        canvas.drawCircle(center, radius, glowFill);
        canvas.restore();
        // Existing highlight stroke
        final Paint highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = responsiveBorderWidth * 2.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(
          arcRect,
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
      // Use only white text for all slices
      final Color textColor = Colors.white;
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
        // Removed maxLines and ellipsis to allow full text rendering
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
  final List<Color>? colors;

  const PlayerCircle({
    super.key,
    required this.players,
    this.size = 300.0,
    this.highlightedIndex,
    this.previousIndex,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 600),
    this.colors,
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
        colors: colors,
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
          playerColors: colors,
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
  final List<Color>? colors;

  const _AnimatedPlayerCircle({
    required this.players,
    required this.size,
    required this.fromIndex,
    required this.toIndex,
    required this.duration,
    this.colors,
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
              playerColors: widget.colors,
            ),
          ),
        );
      },
    );
  }
}
