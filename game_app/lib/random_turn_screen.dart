import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'dart:ui';
import 'truth_dare_data.dart';
import 'truth_dare_question_screen.dart';
import 'widgets/cards/game_card.dart';
import 'widgets/buttons/neumorphic_icon_button.dart';
import 'custom_appbar_button.dart';

class RandomTurnScreen extends StatefulWidget {
  final List<String> players;
  final List<Color> playerColors;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  const RandomTurnScreen({super.key, required this.players, required this.playerColors, required this.ageGroup, required this.selectedCategoryIds, required this.useTimer});

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
  Map<String, int> _playerScores = {};
  bool _isMuted = false; // State for volume button
  List<String> get _allCategoryIds => [
    'KIDS_FUNNY','KIDS_FAMILY','KIDS_SCHOOL','KIDS_CARTOONS','KIDS_GAMES','KIDS_ANIMALS','KIDS_FOOD','KIDS_IMAGINATION','KIDS_CHALLENGES','KIDS_HOBBIES',
    'TEENS_FRIENDS','TEENS_SCHOOL','TEENS_MUSIC','TEENS_MOVIES','TEENS_TECH','TEENS_HOBBIES','TEENS_DREAMS','TEENS_EMBARRASSING','TEENS_STYLE','TEENS_ADVENTURE',
    'ADULTS_RELATIONSHIPS','ADULTS_PARTY','ADULTS_WORK','ADULTS_TRAVEL','ADULTS_DEEP','ADULTS_WILD','ADULTS_FLIRTY','ADULTS_CHILDHOOD','ADULTS_POPCULTURE','ADULTS_PERSONAL',
  ];

  @override
  void initState() {
    super.initState();
    _resetTurns();
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    // Remove this line:
    // _pickRandomPlayer();
  }

  void _resetTurns() {
    setState(() {
      _remainingIndices = List.generate(widget.players.length, (i) => i);
      _remainingIndices.shuffle(_random); // Shuffle for random order
      _currentIndex = null;
      _lastPlayerFinished = false;
      // Immediately pick the first player after reset
      Future.delayed(Duration.zero, _pickRandomPlayer);
    });
  }

  void _pickRandomPlayer() {
    if (_remainingIndices.isEmpty) return;
    setState(() {
      _currentIndex = _remainingIndices.removeLast(); // Always pick last for true random order
      _showTruthDarePrompt = true;
      _showTruthDareButtons = false;
      _lastChoice = null;
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
    if (_currentIndex == null) return;
    final playerName = widget.players[_currentIndex!];
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
              _showTruthDareButtons = false;
              if (_remainingIndices.isEmpty) {
                _lastPlayerFinished = true;
              } else {
                _pickRandomPlayer();
              }
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _showTruthDareButtons = false;
              if (_remainingIndices.isEmpty) {
                _lastPlayerFinished = true;
              } else {
                _pickRandomPlayer();
              }
            });
          },
          useTimer: widget.useTimer,
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

  void _onShowTruthDareButtons() {
    setState(() {
      _showTruthDarePrompt = false;
      _showTruthDareButtons = true;
      _lastChoice = null;
    });
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
    final Size size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.8;
    final double cardHeight = size.height * 0.23;
    final double buttonFontSize = (size.width * 0.045).clamp(15, 22);
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 252, 118, 84),
        Color.fromARGB(255, 245, 64, 100),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
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
          leading: CustomAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () async {
              final shouldQuit = await _showQuitConfirmation();
              if (shouldQuit) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            tooltip: 'Home',
          ),
          title: Text('Whoopsie!', style: Theme.of(context).appBarTheme.titleTextStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: Theme.of(context).appBarTheme.toolbarHeight,
          titleSpacing: Theme.of(context).appBarTheme.titleSpacing,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: backgroundGradient),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double bottomPadding = constraints.maxHeight * 0.04;
              final double horizontalPadding = constraints.maxWidth * 0.07;
              return Stack(
                children: [
                  // Centered card and content
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentIndex != null) ...[
                            Container(
                              width: constraints.maxWidth * 0.8,
                              height: constraints.maxHeight * 0.23,
                              margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.04),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: cardColor != null
                                    ? LinearGradient(
                                        colors: [cardColor, cardColor.withOpacity(0.7)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
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
                                        fontSize: (constraints.maxWidth * 0.08).clamp(22, 36),
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        shadows: [
                                          Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1)),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: (constraints.maxHeight * 0.02).clamp(10, 24)),
                                    Text(
                                      "It's your turn!",
                                      style: GoogleFonts.baloo2(
                                        fontSize: (constraints.maxWidth * 0.05).clamp(16, 24),
                                        color: textColor != null ? textColor.withOpacity(0.7) : Colors.white,
                                      ),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (constraints.maxWidth * 0.18).clamp(32, 60),
                                    vertical: (constraints.maxHeight * 0.025).clamp(14, 28),
                                  ),
                                  textStyle: GoogleFonts.baloo2(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 3,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text('Truth or Dare?'),
                              ),
                              SizedBox(height: (constraints.maxHeight * 0.018).clamp(10, 22)),
                            ] else if (_showTruthDareButtons) ...[
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
                                        horizontal: (constraints.maxWidth * 0.13).clamp(24, 48),
                                        vertical: (constraints.maxHeight * 0.02).clamp(10, 20),
                                      ),
                                      textStyle: GoogleFonts.baloo2(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 3,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: const Text('Truth'),
                                  ),
                                  SizedBox(width: (constraints.maxWidth * 0.06).clamp(16, 32)),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _showTruthOrDareScreen(false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (constraints.maxWidth * 0.13).clamp(24, 48),
                                        vertical: (constraints.maxHeight * 0.02).clamp(10, 20),
                                      ),
                                      textStyle: GoogleFonts.baloo2(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 3,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: const Text('Dare'),
                                  ),
                                ],
                              ),
                              SizedBox(height: (constraints.maxHeight * 0.018).clamp(10, 22)),
                            ]
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (constraints.maxWidth * 0.18).clamp(32, 60),
                                        vertical: (constraints.maxHeight * 0.025).clamp(14, 28),
                                      ),
                                      textStyle: GoogleFonts.baloo2(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 3,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: const Text('Restart'),
                                  ),
                                  SizedBox(height: (constraints.maxHeight * 0.018).clamp(10, 22)),
                                  Text(
                                    'All players had their turn!',
                                    style: GoogleFonts.baloo2(
                                      fontSize: (constraints.maxWidth * 0.045).clamp(15, 22),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: (constraints.maxHeight * 0.01).clamp(6, 16)),
                            ],
                        ],
                        ],
                      ),
                    ),
                  ),
                  // Bottom buttons row
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: bottomPadding,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
