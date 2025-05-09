import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart';

class TruthDareQuestionScreen extends StatefulWidget {
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
  State<TruthDareQuestionScreen> createState() => _TruthDareQuestionScreenState();
}

class _TruthDareQuestionScreenState extends State<TruthDareQuestionScreen> with SingleTickerProviderStateMixin {
  static const int _startSeconds = 60;
  late int _secondsLeft;
  Timer? _timer;
  late AnimationController _progressController;

  // Move color combo selection here so it only happens once per screen
  static final List<List<Color>> colorCombos = [
    [Color.fromARGB(255, 100, 230, 200), Color.fromARGB(255, 80, 130, 255)],
    [Color(0xFF4DD0E1), Color(0xFF1976D2)],
    [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    [Color(0xFF8F6ED5), Color(0xFF5B86E5)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFA8BFF), Color(0xFF2BD2FF)],
    [Color(0xFFFFD700), Color(0xFFFF5F6D)],
  ];
  late final List<Color> combo;
  late final Color mainColor;
  late final Color secondaryColor;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _startSeconds;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _startSeconds),
    )..forward();
    // Only pick a color combo once per screen/question
    combo = (List<List<Color>>.from(colorCombos)..shuffle()).first;
    mainColor = combo[0];
    secondaryColor = combo[1];
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _handleForfeit();
      }
    });
  }

  void _handleForfeit() {
    _timer?.cancel();
    _progressController.stop();
    widget.onForfeit();
  }

  void _handleDone() {
    _timer?.cancel();
    _progressController.stop();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;
    final double fontSize = (width * 0.045).clamp(14, 28);
    final double questionFontSize = (width * 0.055).clamp(16, 32);
    final double timerFontSize = (width * 0.07).clamp(20, 36);
    final double headerFontSize = (width * 0.09).clamp(24, 44);
    final double buttonFontSize = (width * 0.058).clamp(18, 36);
    final double iconSize = (width * 0.18).clamp(48, 120);
    final double buttonIconSize = (buttonFontSize * 1.28).clamp(24, 48);
    final double horizontalPadding = (width * 0.045).clamp(10, 28);
    final double buttonVerticalPadding = (height * 0.032).clamp(18, 44);
    final double buttonSpacing = (width * 0.045).clamp(10, 28);
    final double headerTopPadding = (height * 0.02).clamp(10, 32);
    final double headerSidePadding = (width * 0.02).clamp(6, 18);
    final double rowBottomPadding = (height * 0.08).clamp(32, 90);
    final double betweenHeaderAndIcon = (height * 0.02).clamp(8, 28);
    final double betweenIconAndQuestion = (height * 0.01).clamp(4, 18);
    final double betweenQuestionAndButtons = (height * 0.01).clamp(8, 24);
    final double afterButtons = (height * 0.01).clamp(8, 24);

    // Gradient for Done button
    final BoxDecoration doneButtonDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [mainColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.18),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    );

    final ButtonStyle doneButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 26), // Increased height
      textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
    );

    final TextStyle doneButtonTextStyle = GoogleFonts.baloo2(
      fontWeight: FontWeight.bold,
      fontSize: buttonFontSize,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 2),
        ),
      ],
    );

    final ButtonStyle forfeitButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.black.withOpacity(0.85),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 26), // Increased height
      textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
    );

    final TextStyle forfeitButtonTextStyle = GoogleFonts.baloo2(
      fontWeight: FontWeight.bold,
      fontSize: buttonFontSize,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Stack(
      children: [
        // Solid background to block splash/logo
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, // or Colors.white for a light base
        ),
        // Fully opaque vibrant gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor], // No opacity for vibrancy
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Blurred overlay (keep subtle, not hiding gradient)
        Container(
          width: double.infinity,
          height: double.infinity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: Colors.black.withOpacity(0.08), // Lower opacity for vibrancy
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: headerTopPadding,
                  left: headerSidePadding,
                  right: headerSidePadding,
                  bottom: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(3, 3), blurRadius: 6),
                          BoxShadow(color: Colors.white.withOpacity(0.4), offset: Offset(-3, -3), blurRadius: 6),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.black, size: buttonIconSize),
                        tooltip: 'Forfeit',
                        onPressed: _handleForfeit,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.isTruth ? "It's a Truth!" : "It's a Dare!",
                        style: GoogleFonts.baloo2(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: buttonIconSize + 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: betweenHeaderAndIcon, bottom: betweenIconAndQuestion),
                child: Icon(
                  widget.isTruth ? Icons.lightbulb_rounded : Icons.whatshot_rounded,
                  color: widget.isTruth ? mainColor : secondaryColor,
                  size: iconSize,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black.withAlpha((0.4 * 255).round()),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.playerName}, your task:",
                        style: GoogleFonts.baloo2(
                          fontSize: fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: betweenHeaderAndIcon * 0.7),
                      Text(
                        widget.questionText,
                        style: GoogleFonts.baloo2(
                          fontSize: questionFontSize * 1.18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Timer is now only above the buttons, not affecting the question
              Padding(
                padding: EdgeInsets.only(bottom: (height * 0.06).clamp(18, 48)), // Increased bottom padding for more lift
                child: Center(
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      double progress = 1.0 - _progressController.value;
                      final double ringDiameter = timerFontSize * 3.2;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: ringDiameter,
                            height: ringDiameter,
                            child: CustomPaint(
                              painter: _TimerRingPainter(
                                progress: progress,
                                mainColor: mainColor,
                                secondaryColor: secondaryColor,
                                smooth: true,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              (_secondsLeft - 1).clamp(0, 59).toString(),
                              style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.bold,
                                fontSize: timerFontSize,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, rowBottomPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleForfeit,
                        style: forfeitButtonStyle.copyWith(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: buttonVerticalPadding / 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                              size: buttonIconSize,
                            ),
                            SizedBox(width: buttonSpacing / 2),
                            Text(
                              'Forfeit',
                              style: forfeitButtonTextStyle.copyWith(fontSize: buttonFontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: buttonSpacing),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleDone,
                        style: forfeitButtonStyle.copyWith(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: buttonVerticalPadding / 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: buttonIconSize,
                            ),
                            SizedBox(width: buttonSpacing / 2),
                            Text(
                              'Done',
                              style: forfeitButtonTextStyle.copyWith(fontSize: buttonFontSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: afterButtons),
              // Placeholder for smart ad banner
              // SmartBannerMobile(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color mainColor;
  final Color secondaryColor;
  final bool smooth;
  _TimerRingPainter({required this.progress, required this.mainColor, required this.secondaryColor, this.smooth = false});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.10; // Slightly thinner for bigger ring
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true;
    final fgPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeCap = smooth ? StrokeCap.round : StrokeCap.butt
      ..strokeWidth = stroke * 1.1
      ..isAntiAlias = true;
    // Draw background ring
    canvas.drawArc(
      Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke),
      0,
      2 * 3.1415926535,
      false,
      bgPaint,
    );
    // Draw progress arc
    double sweep = 2 * 3.1415926535 * progress;
    if (sweep > 0.01) {
      canvas.drawArc(
        Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke),
        -3.1415926535 / 2,
        sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.mainColor != mainColor || oldDelegate.secondaryColor != secondaryColor || oldDelegate.smooth != smooth;
  }
}
