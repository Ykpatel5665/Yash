import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'dart:ui';

class RandomTurnScreen extends StatefulWidget {
  final List<String> players;
  final List<Color> playerColors;
  final dynamic ageGroup;
  const RandomTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup});

  @override
  State<RandomTurnScreen> createState() => _RandomTurnScreenState();
}

class _RandomTurnScreenState extends State<RandomTurnScreen> {
  late List<int> _remainingIndices;
  int? _currentIndex;
  final Random _random = Random();
  bool _showTruthDarePrompt = false;
  bool _showTruthDareButtons = false;
  String? _lastChoice;
  bool _lastPlayerFinished = false; // Track if last player finished

  @override
  void initState() {
    super.initState();
    _resetTurns();
    // Immediately pick the first player
    _pickRandomPlayer();
  }

  void _resetTurns() {
    setState(() {
      _remainingIndices = List.generate(widget.players.length, (i) => i);
      _currentIndex = null;
      _lastPlayerFinished = false; // Reset last player finished
      // Immediately pick the first player after reset
      Future.delayed(Duration.zero, _pickRandomPlayer);
    });
  }

  void _pickRandomPlayer() {
    if (_remainingIndices.isEmpty) return;
    final idx = _random.nextInt(_remainingIndices.length);
    setState(() {
      _currentIndex = _remainingIndices[idx];
      _remainingIndices.removeAt(idx);
      _showTruthDarePrompt = true;
      _showTruthDareButtons = false;
      _lastChoice = null;
    });
  }

  void _onShowTruthDareButtons() {
    setState(() {
      _showTruthDarePrompt = false;
      _showTruthDareButtons = true;
      _lastChoice = null; // Clear last choice when showing buttons
    });
  }

  void _onTruthOrDare(String choice) {
    setState(() {
      _showTruthDareButtons = false;
      _lastChoice = choice;
      // If this was the last player, mark finished
      if (_remainingIndices.isEmpty) {
        _lastPlayerFinished = true;
      } else {
        _pickRandomPlayer(); // Immediately pick next player, matching auto next turn logic
      }
    });
  }

  Future<bool> _showQuitConfirmation() async {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = 24.0;
    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.32),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
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
                    children: [
                      Text(
                        'Quit Game?',
                        style: GoogleFonts.baloo2(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white70,
                        size: screenSize.width * 0.14,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Are you sure you want to quit the game?',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5B86E5),
                                    Color(0xFF8F6ED5),
                                  ],
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
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "No",
                                    style: GoogleFonts.baloo2(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Colors.black.withOpacity(0.25),
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: GoogleFonts.baloo2(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              child: const Text("Yes"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 3);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // --- Theme and sizing ---
    final Size size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.8;
    final double cardHeight = size.height * 0.32;
    final double avatarSize = size.width * 0.22;
    final double buttonFontSize = (size.width * 0.045).clamp(15, 22);
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 252, 118, 84),
        Color.fromARGB(255, 245, 64, 100),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    const Color baseColor = Color.fromARGB(255, 255, 255, 255);
    final Color shadowDark = Colors.black.withOpacity(0.3);
    final Color shadowLight = Colors.white.withOpacity(0.4);

    // --- Fix: Compute cardColor and textColor before widget tree ---
    Color? cardColor;
    Color? textColor;
    if (_currentIndex != null) {
      cardColor = widget.playerColors[_currentIndex!];
      textColor = cardColor.computeLuminance() > 0.6 ? Colors.black : Colors.white;
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await _showQuitConfirmation();
        return shouldQuit;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 15, bottom: 15),
            child: GestureDetector(
              onTap: () async {
                final shouldQuit = await _showQuitConfirmation();
                if (shouldQuit) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                    BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                  ],
                ),
                child: const Icon(Icons.home_rounded, color: Color.fromARGB(255, 0, 0, 0), size: 24),
              ),
            ),
          ),
          title: Text('Whoopsie!', style: appBarTheme.titleTextStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: appBarTheme.toolbarHeight,
          titleSpacing: appBarTheme.titleSpacing,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: backgroundGradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentIndex != null) ...[
                    Container(
                      width: cardWidth,
                      height: cardHeight,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            cardColor!,
                            cardColor!.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.players[_currentIndex!],
                              style: GoogleFonts.baloo2(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                shadows: [
                                  Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "It's your turn!",
                              style: GoogleFonts.baloo2(fontSize: 20, color: textColor!.withOpacity(0.7)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showTruthDarePrompt) ...[
                      ElevatedButton(
                        onPressed: _onShowTruthDareButtons,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Truth or Dare?'),
                      ),
                      const SizedBox(height: 18),
                    ] else if (_showTruthDareButtons) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _onTruthOrDare('Truth'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text('Truth'),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: () => _onTruthOrDare('Dare'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text('Dare'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ]
                    // Only show the restart button/message after last player finished
                    else if (_lastPlayerFinished) ...[
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _resetTurns();
                                _lastPlayerFinished = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                              textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text('Restart'),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'All players had their turn!',
                            style: GoogleFonts.baloo2(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
