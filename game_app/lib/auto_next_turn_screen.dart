import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart';
import 'truth_dare_question_screen.dart';
import 'main.dart'; // For AgeGroup enum
import 'widgets/cards/game_card.dart';
import 'widgets/buttons/neumorphic_icon_button.dart';
import 'widgets/dialog_action_row.dart';
import 'custom_appbar_button.dart';

// Convert to StatefulWidget for turn management
class AutoNextTurnScreen extends StatefulWidget {
  final List<String> players;
  final List<Color> playerColors;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  const AutoNextTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup, required this.selectedCategoryIds});

  @override
  State<AutoNextTurnScreen> createState() => _AutoNextTurnScreenState();
}

class _AutoNextTurnScreenState extends State<AutoNextTurnScreen> {
  int _currentIndex = 0;
  bool _showTruthDare = false;
  bool _lastPlayerFinished = false; // Track if last player finished
  Map<String, int> _playerScores = {};
  bool _isMuted = false; // State for volume button
  // For demo, use all categories (or pass selectedCategoryIds if you want to filter)
  List<String> get _allCategoryIds => [
    'KIDS_FUNNY','KIDS_FAMILY','KIDS_SCHOOL','KIDS_CARTOONS','KIDS_GAMES','KIDS_ANIMALS','KIDS_FOOD','KIDS_IMAGINATION','KIDS_CHALLENGES','KIDS_HOBBIES',
    'TEENS_FRIENDS','TEENS_SCHOOL','TEENS_MUSIC','TEENS_MOVIES','TEENS_TECH','TEENS_HOBBIES','TEENS_DREAMS','TEENS_EMBARRASSING','TEENS_STYLE','TEENS_ADVENTURE',
    'ADULTS_RELATIONSHIPS','ADULTS_PARTY','ADULTS_WORK','ADULTS_TRAVEL','ADULTS_DEEP','ADULTS_WILD','ADULTS_FLIRTY','ADULTS_CHILDHOOD','ADULTS_POPCULTURE','ADULTS_PERSONAL',
  ];

  @override
  void initState() {
    super.initState();
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
  }

  void _nextTurn() {
    setState(() {
      if (_currentIndex == widget.players.length - 1) {
        // Last player just finished their turn
        _showTruthDare = false;
        _lastPlayerFinished = true;
      } else {
        _showTruthDare = false;
        _currentIndex = (_currentIndex + 1) % widget.players.length;
      }
    });
  }

  void _showTruthOrDare() {
    setState(() {
      _showTruthDare = true;
    });
  }

  Future<Question?> _getRandomQuestionFromJson({required String type}) async {
    final questions = await loadQuestions(
      type: type,
      selectedCategories: widget.selectedCategoryIds,
      ageGroup: widget.ageGroup.name == 'kids' ? 'Kids' : widget.ageGroup.name == 'teen' ? 'Teens' : 'Adults',
    );
    if (questions.isEmpty) return null;
    questions.shuffle();
    return questions.first;
  }

  Future<void> _showTruthOrDareScreen(bool isTruth) async {
    final playerName = widget.players[_currentIndex];
    final question = await _getRandomQuestionFromJson(type: isTruth ? 'truth' : 'dare');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruthDareQuestionScreen(
          playerName: playerName,
          questionText: question?.text ?? (isTruth ? 'No truth found.' : 'No dare found.'),
          isTruth: isTruth,
          onDone: () {
            _playerScores[playerName] = (_playerScores[playerName] ?? 0) + 1;
            Navigator.of(context).pop();
            setState(() {
              _showTruthDare = false;
              _nextTurn();
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _showTruthDare = false;
              _nextTurn();
            });
          },
        ),
      ),
    );
  }

  void _showScoreboardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double cardWidth = screenSize.width * 0.92;
        final double maxCardWidth = 420;
        final double cardPadding = (screenSize.width * 0.06).clamp(16, 32); // Responsive
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);
        final double iconSize = (screenSize.width * 0.14).clamp(36, 60); // Responsive
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GameCard(
            maxWidth: maxCardWidth,
            padding: EdgeInsets.all(cardPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scoreboard',
                    style: GoogleFonts.baloo2(
                      fontSize: (screenSize.width * 0.08).clamp(24, 36), // Responsive
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
                  SizedBox(height: (screenSize.height * 0.03).clamp(14, 32)), // Responsive
                  Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700), // Gold
                    size: iconSize,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withAlpha((0.4 * 255).round()),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  SizedBox(height: (screenSize.height * 0.03).clamp(14, 32)), // Responsive
                  Column(
                    children: [
                      ...widget.players.map((player) => Padding(
                        padding: EdgeInsets.symmetric(vertical: (screenSize.height * 0.008).clamp(4, 12)), // Responsive
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              player,
                              style: GoogleFonts.baloo2(
                                fontSize: fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: (screenSize.width * 0.04).clamp(8, 20),
                                vertical: (screenSize.height * 0.008).clamp(4, 12),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _playerScores[player]?.toString() ?? '0',
                                style: GoogleFonts.baloo2(
                                  fontSize: fontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: (screenSize.height * 0.04).clamp(18, 40)), // Responsive
                  DecoratedBox(
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
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: (screenSize.height * 0.022).clamp(12, 28), horizontal: (screenSize.width * 0.08).clamp(18, 40)), // Responsive
                        textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                      ),
                      child: Center(
                        child: Text(
                          'Close',
                          style: GoogleFonts.baloo2(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showQuitConfirmation() async {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = (screenSize.width * 0.06).clamp(16, 32); // Responsive
    final double titleFontSize = (screenSize.width * 0.08).clamp(24, 36); // Responsive
    final double iconSize = (screenSize.width * 0.14).clamp(36, 60); // Responsive
    final double messageFontSize = (screenSize.width * 0.05).clamp(15, 22); // Responsive
    final double buttonFontSize = (screenSize.width * 0.055).clamp(16, 22); // Responsive
    final double buttonSpacing = (screenSize.width * 0.045).clamp(10, 22); // Responsive
    final double sectionSpacing = (screenSize.height * 0.03).clamp(14, 32); // Responsive
    final double buttonRowSpacing = (screenSize.height * 0.04).clamp(18, 40); // Responsive
    final double buttonVerticalPadding = (screenSize.height * 0.022).clamp(12, 28); // Responsive
    final double textButtonVerticalPadding = (screenSize.height * 0.016).clamp(8, 22); // Responsive

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
                  padding: EdgeInsets.all(cardPadding), // Responsive
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
                          fontSize: titleFontSize, // Responsive
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
                      SizedBox(height: sectionSpacing), // Responsive
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white70,
                        size: iconSize, // Responsive
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionSpacing), // Responsive
                      Text(
                        'Are you sure you want to quit the game?',
                        style: GoogleFonts.baloo2(
                          fontSize: messageFontSize, // Responsive
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: buttonRowSpacing), // Responsive
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
                                  padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding), // Responsive
                                  textStyle: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.bold,
                                    fontSize: buttonFontSize, // Responsive
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "No",
                                    style: GoogleFonts.baloo2(
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonFontSize, // Responsive
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
                          SizedBox(width: buttonSpacing), // Responsive
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: EdgeInsets.symmetric(vertical: textButtonVerticalPadding), // Responsive
                                textStyle: GoogleFonts.baloo2(
                                  fontWeight: FontWeight.w600,
                                  fontSize: (screenSize.width * 0.045).clamp(14, 18), // Responsive
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

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    final Size screenSize = MediaQuery.of(context).size;
    final double minBtn = 44, maxBtn = 70;
    final double btnSize = (screenSize.width * 0.13).clamp(minBtn, maxBtn);
    final double iconSize = (screenSize.width * 0.07).clamp(22, 36);
    const Color baseColor = Color.fromARGB(255, 255, 255, 255);
    final Color shadowDark = Colors.black.withOpacity(0.3);
    final Color shadowLight = Colors.white.withOpacity(0.4);
    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
          BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(btnSize * 0.25),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(btnSize, btnSize),
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the same AppBar style from MyApp theme, but allow customization if needed
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;

    final playerName = widget.players[_currentIndex];
    final playerColor = widget.playerColors[_currentIndex];
    final Color textColor = playerColor.computeLuminance() > 0.6 ? Colors.black : Colors.white;
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
          leading: CustomAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () async {
              final shouldQuit = await _showQuitConfirmation();
              if (shouldQuit) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            tooltip: 'Home',
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
            child: Stack(
              children: [
                LayoutBuilder(
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
                                        color: textColor,
                                        shadows: [
                                          Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "It's your turn!",
                                      style: TextStyle(fontSize: turnFontSize, color: textColor.withOpacity(0.7)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Only show restart and message after last player has finished their turn
                            if (_lastPlayerFinished) ...[
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentIndex = 0;
                                    _showTruthDare = false;
                                    _lastPlayerFinished = false;
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
                                      onPressed: () async {
                                        await _showTruthOrDareScreen(true);
                                      },
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
                                      onPressed: () async {
                                        await _showTruthOrDareScreen(false);
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
                // Bottom buttons row (volume and scorecard)
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.07,
                  right: MediaQuery.of(context).size.width * 0.07,
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                          // TODO: Implement actual volume control logic
                        },
                      ),
                      _buildIconButton(
                        Icons.emoji_events_outlined,
                        _showScoreboardDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

