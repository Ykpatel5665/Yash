import 'package:flutter/material.dart';

// Convert to StatefulWidget for turn management
class AutoNextTurnScreen extends StatefulWidget {
  final List<String> players;
  final List<Color> playerColors;
  final dynamic ageGroup;
  const AutoNextTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup});

  @override
  State<AutoNextTurnScreen> createState() => _AutoNextTurnScreenState();
}

class _AutoNextTurnScreenState extends State<AutoNextTurnScreen> {
  int _currentIndex = 0;
  bool _showTruthDare = false;

  void _nextTurn() {
    setState(() {
      _showTruthDare = false;
      if (_currentIndex == widget.players.length - 1) {
        // All players have played, show dialog
        Future.delayed(Duration.zero, _showRestartDialog);
      } else {
        _currentIndex = (_currentIndex + 1) % widget.players.length;
      }
    });
  }

  void _showRestartDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 27, 123, 212),
                Color.fromARGB(255, 50, 196, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'All players had their turn!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text(
                'Do you want to start another round?',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _currentIndex = 0;
        _showTruthDare = false;
      });
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showTruthOrDare() {
    setState(() {
      _showTruthDare = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerName = widget.players[_currentIndex];
    final playerColor = widget.playerColors[_currentIndex];
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double emojiSize = (screenWidth * 0.18).clamp(48, 120);
    final double circleSize = emojiSize + 32;
    final double titleFontSize = (screenWidth * 0.07).clamp(22, 36);
    final double turnFontSize = (screenWidth * 0.055).clamp(18, 28);
    final double buttonFontSize = (screenWidth * 0.045).clamp(15, 22);
    final double buttonPaddingV = (screenHeight * 0.018).clamp(10, 22);
    final double buttonPaddingH = (screenWidth * 0.08).clamp(24, 40);
    final double spacingLarge = (screenHeight * 0.06).clamp(24, 60);
    final double spacingMed = (screenHeight * 0.035).clamp(14, 32);
    final double spacingSmall = (screenHeight * 0.018).clamp(7, 18);
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 50, 196, 255),
        Color.fromARGB(255, 27, 123, 212),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Whoopsie!', style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.01, top: screenHeight * 0.015, bottom: screenHeight * 0.015),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Builder(
              builder: (context) {
                const Color baseColor = Color.fromARGB(255, 255, 255, 255);
                final Color shadowDark = Colors.black.withOpacity(0.3);
                final Color shadowLight = Colors.white.withOpacity(0.4);
                return Container(
                  width: screenWidth * 0.11,
                  height: screenWidth * 0.11,
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                      BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                    ],
                  ),
                  child: Icon(Icons.home_rounded, color: Colors.black, size: screenWidth * 0.065),
                );
              },
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: spacingLarge),
                      // Restore CircleAvatar with player's initial
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: playerColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            playerName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: emojiSize,
                              fontWeight: FontWeight.bold,
                              color: playerColor.computeLuminance() > 0.6 ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacingMed),
                      Text(
                        "It's $playerName's turn!",
                        style: TextStyle(
                          fontSize: turnFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black.withAlpha(100), offset: Offset(1, 1)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacingLarge),
                      if (!_showTruthDare) ...[
                        ElevatedButton(
                          onPressed: _showTruthOrDare,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonPaddingH,
                              vertical: buttonPaddingV,
                            ),
                            textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                          ),
                          child: const Text('Truth or Dare?'),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _nextTurn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingH,
                                  vertical: buttonPaddingV,
                                ),
                                textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 3,
                              ),
                              child: const Text('Truth'),
                            ),
                            SizedBox(width: screenWidth * 0.06),
                            ElevatedButton(
                              onPressed: _nextTurn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingH,
                                  vertical: buttonPaddingV,
                                ),
                                textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 3,
                              ),
                              child: const Text('Dare'),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: spacingLarge),
                      Text(
                        'Player ${_currentIndex + 1} of ${widget.players.length}',
                        style: TextStyle(fontSize: buttonFontSize, color: Colors.white),
                      ),
                      SizedBox(height: spacingLarge),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
