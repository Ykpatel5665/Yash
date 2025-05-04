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
        // All players have played, stay on last player and show restart button
        // Do not advance index
      } else {
        _currentIndex = (_currentIndex + 1) % widget.players.length;
      }
    });
  }

  void _showTruthOrDare() {
    setState(() {
      _showTruthDare = true;
    });
  }

  Future<bool> _showQuitConfirmation() async {
    final size = MediaQuery.of(context).size;
    final double dialogPadding = size.width * 0.06;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(dialogPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 84, 51, 255),
                Color.fromARGB(255, 153, 50, 204),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 3.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 10.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quit Game?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.025),
              const Text(
                'Are you sure you want to quit the game?',
                style: TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Use the same AppBar style from MyApp theme, but allow customization if needed
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;

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
    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await _showQuitConfirmation();
        return shouldQuit;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Whoopsie!', style: appBarTheme.titleTextStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.01, top: screenHeight * 0.015, bottom: screenHeight * 0.015),
            child: GestureDetector(
              onTap: () async {
                final shouldQuit = await _showQuitConfirmation();
                if (shouldQuit) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 252, 118, 84),
                Color.fromARGB(255, 245, 64, 100),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: spacingLarge),
                        // Card design instead of colored circle
                        Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.23,
                          margin: EdgeInsets.only(bottom: spacingLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                playerColor,
                                playerColor.withOpacity(0.7),
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
                                  playerName,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "It's your turn!",
                                  style: TextStyle(fontSize: turnFontSize, color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_currentIndex == widget.players.length - 1) ...[
                          // Only show restart and message, hide Truth/Dare and other controls
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentIndex = 0;
                                _showTruthDare = false;
                              });
                            },
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
                            child: const Text('Restart'),
                          ),
                          SizedBox(height: spacingLarge * 0.7),
                          Text(
                            'All players had their turn!',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ] else ...[
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
      ),
    );
  }
}
