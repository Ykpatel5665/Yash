import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'dart:ui';
import 'truth_dare_data.dart';
import 'truth_dare_question_screen.dart';
import 'widgets/cards/game_card.dart';
import 'custom_appbar_button.dart';
import 'player_circle_painter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'l10n/app_localizations.dart';
import 'widgets/headers/app_header.dart';

// Shared dialog constants and helpers
const double kMaxCardWidth = 420.0;
double getResponsiveCardPadding(double screenWidth) => (screenWidth * 0.06).clamp(16, 32);

// --- Add the Whoopsie! _TruthDareDialog widget (copied and adapted from AutoNextTurnScreen) ---
class _TruthDareDialog extends StatelessWidget {
  final String playerName;
  const _TruthDareDialog({required this.playerName});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double cardPadding = 24.0;
    final localizations = AppLocalizations.of(context)!;
    BoxDecoration truthButtonDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4DD0E1), Color(0xFF1976D2)],
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
    BoxDecoration dareButtonDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
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
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
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
    );
    TextStyle buttonTextStyle = GoogleFonts.baloo2(
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
    );
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              width: cardWidth > kMaxCardWidth ? kMaxCardWidth : cardWidth,
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
                  AutoSizeText(
                    localizations.whoopsieTitle,
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
                    minFontSize: 12,
                    maxLines: 2,
                    wrapWords: true,
                  ),
                  SizedBox(height: 28),
                  Icon(
                    Icons.sentiment_very_satisfied_rounded,
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
                  SizedBox(height: 28),
                  AutoSizeText(
                    localizations.itsTurn(playerName),
                    style: GoogleFonts.baloo2(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 10,
                    maxLines: 2,
                    wrapWords: true,
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: truthButtonDecoration,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop('truth');
                            },
                            style: buttonStyle,
                            child: Center(
                              child: AutoSizeText(
                                localizations.truthBtn,
                                style: buttonTextStyle,
                                minFontSize: 10,
                                maxLines: 2,
                                wrapWords: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: DecoratedBox(
                          decoration: dareButtonDecoration,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop('dare');
                            },
                            style: buttonStyle,
                            child: Center(
                              child: AutoSizeText(
                                localizations.dareBtn,
                                style: buttonTextStyle,
                                minFontSize: 10,
                                maxLines: 2,
                                wrapWords: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        final random = Random();
                        final isTruth = random.nextBool();
                        Navigator.of(context).pop(isTruth ? 'truth' : 'dare');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.chooseRandomBtn,
                        style: GoogleFonts.baloo2(
                          fontSize: (screenSize.width * 0.038).clamp(12, 16),
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ); // Center
  }
}

class RandomTurnScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  final void Function(Locale) setLocale;

  const RandomTurnScreen({
    super.key,
    required this.players,
    required this.ageGroup,
    required this.selectedCategoryIds,
    required this.useTimer,
    required this.setLocale,
  });

  @override
  State<RandomTurnScreen> createState() => _RandomTurnScreenState();
}

class _RandomTurnScreenState extends State<RandomTurnScreen> {
  late List<int> _remainingIndices;
  int? _currentIndex;
  final Random _random = Random();
  bool _lastPlayerFinished = false; // Track if last player finished
  Map<String, int> _playerScores = {};
  bool _isMuted = false; // State for volume button

  // --- ADDED: Robust dialog and state management flags ---
  bool _isSpinning = false;
  bool _scoreboardOpen = false;
  bool _quitDialogOpen = false;
  bool _pendingShowTruthDare = false;

  // --- ADDED: Store shuffled player colors for this game session ---
  late List<Color> _playerColors;

  // --- ADDED: Animation/highlight state fields ---
  int? _highlightedIndex;
  int? _previousIndex;

  // --- ADDED: Game start state ---
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _resetTurns();
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    // --- ADDED: Shuffle the color palette at the start of the game ---
    _playerColors = PlayerCirclePainter.shuffleColors();
    // --- REMOVED: Auto start spin on init ---
    // (Do not call _pickRandomPlayerWithSpin here)
  }

  void _resetTurns() {
    setState(() {
      _remainingIndices = List.generate(widget.players.length, (i) => i);
      _remainingIndices.shuffle(_random); // Shuffle for random order
      _currentIndex = null;
      _highlightedIndex = null;
      _lastPlayerFinished = false;
      _gameStarted = false; // Wait for user to press Start
      // --- REMOVED: Auto start spin on reset ---
      // (Do not call _pickRandomPlayerWithSpin here)
      // --- ADDED: Shuffle the color palette on new game/restart ---
      _playerColors = PlayerCirclePainter.shuffleColors();
    });
  }

  void _pickRandomPlayerWithSpin() async {
    if (_remainingIndices.isEmpty || _isSpinning) return;
    final int playerCount = widget.players.length;
    final int from = _highlightedIndex ?? _currentIndex ?? 0;
    // Find the next clockwise index in _remainingIndices
    int nextIdx = _remainingIndices.firstWhere(
      (i) => i > from,
      orElse: () => _remainingIndices.first,
    );
    final int spins = 3 + _random.nextInt(3); // 3, 4, or 5 full spins
    final int stepsToNext = (nextIdx - from + playerCount) % playerCount;
    final int totalSteps = spins * playerCount + stepsToNext;
    setState(() {
      _isSpinning = true;
      _previousIndex = from;
      _highlightedIndex = from + totalSteps; // Always forward, never backward
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() {
      _currentIndex = nextIdx;
      _isSpinning = false;
      _showTruthDareDialog();
    });
  }

  Future<Question?> _getRandomQuestionFromJson({required String type}) async {
    final questions = await loadQuestions(
      type: type,
      selectedCategories: widget.selectedCategoryIds,
      ageGroup: widget.ageGroup.name == 'kids'
          ? 'Kids'
          : widget.ageGroup.name == 'teen'
              ? 'Teens'
              : 'Adults',
    );
    if (questions.isEmpty) return null;
    questions.shuffle();
    return questions.first;
  }

  Future<void> _showTruthOrDareScreen(bool isTruth) async {
    if (_currentIndex == null) return;
    final playerName = widget.players[_currentIndex!];
    final question =
        await _getRandomQuestionFromJson(type: isTruth ? 'truth' : 'dare');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruthDareQuestionScreen(
          playerName: playerName,
          questionText: question?.text ??
              (isTruth ? 'No truth found.' : 'No dare found.'),
          isTruth: isTruth,
          onDone: () {
            _playerScores[playerName] = (_playerScores[playerName] ?? 0) + 1;
            Navigator.of(context).pop();
            setState(() {
              _remainingIndices.remove(_currentIndex); // Remove current player
              if (_remainingIndices.isEmpty) {
                _lastPlayerFinished = true;
              } else {
                _gameStarted = false; // Wait for user to press Start for next turn
              }
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _remainingIndices.remove(_currentIndex); // Remove current player
              if (_remainingIndices.isEmpty) {
                _lastPlayerFinished = true;
              } else {
                _gameStarted = false; // Wait for user to press Start for next turn
              }
            });
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  }

  // Move the actual dialog logic to a new method
  Future<void> _showTruthDareDialogInternal() async {
    final playerName = widget.players[_currentIndex!];
    final result = await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: _TruthDareDialog(playerName: playerName),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
    if (result == 'truth') {
      await _showTruthOrDareScreen(true);
    } else if (result == 'dare') {
      await _showTruthOrDareScreen(false);
    }
  }

  // Replace _showTruthDareDialog with state-driven version
  Future<void> _showTruthDareDialog() async {
    if (_scoreboardOpen || _quitDialogOpen) {
      _pendingShowTruthDare = true;
      return;
    }
    _pendingShowTruthDare = false;
    if (_currentIndex == null) return;
    await _showTruthDareDialogInternal();
  }

  void _showScoreboardDialog() async {
    if (_scoreboardOpen) return;
    setState(() {
      _scoreboardOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double cardPadding = getResponsiveCardPadding(screenSize.width);
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);
        final double iconSize = (screenSize.width * 0.14).clamp(36, 60); // Responsive
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GameCard(
            maxWidth: kMaxCardWidth,
            padding: EdgeInsets.all(cardPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    AppLocalizations.of(context)!.scoreboard,
                    style: GoogleFonts.baloo2(
                      fontSize:
                          (screenSize.width * 0.08).clamp(24, 36), // Responsive
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
                    minFontSize: 12,
                    maxLines: 2,
                    wrapWords: true,
                  ),
                  SizedBox(
                      height: (screenSize.height * 0.03)
                          .clamp(14, 32)), // Responsive
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
                  SizedBox(
                      height: (screenSize.height * 0.03)
                          .clamp(14, 32)), // Responsive
                  Column(
                    children: [
                      ...widget.players.map((player) => Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: (screenSize.height * 0.008)
                                    .clamp(4, 12)), // Responsive
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  player,
                                  style: GoogleFonts.baloo2(
                                    fontSize: fontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  minFontSize: 10,
                                  maxLines: 2,
                                  wrapWords: true,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        (screenSize.width * 0.04).clamp(8, 20),
                                    vertical: (screenSize.height * 0.008)
                                        .clamp(4, 12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AutoSizeText(
                                    _playerScores[player]?.toString() ?? '0',
                                    style: GoogleFonts.baloo2(
                                      fontSize: fontSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    minFontSize: 10,
                                    maxLines: 1,
                                    wrapWords: true,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                      height: (screenSize.height * 0.04)
                          .clamp(18, 40)), // Responsive
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
                        padding: EdgeInsets.symmetric(
                            vertical: (screenSize.height * 0.022).clamp(12, 28),
                            horizontal: (screenSize.width * 0.08)
                                .clamp(18, 40)), // Responsive
                        textStyle: GoogleFonts.baloo2(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.close,
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
    setState(() {
      _scoreboardOpen = false;
    });
    // Resume dialog if needed
    if (mounted &&
        ModalRoute.of(context)?.isCurrent == true &&
        _pendingShowTruthDare) {
      _pendingShowTruthDare = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            ModalRoute.of(context)?.isCurrent == true &&
            !_scoreboardOpen &&
            !_quitDialogOpen &&
            !_lastPlayerFinished) {
          _showTruthDareDialog();
        }
      });
    }
  }

  Future<bool> _showQuitConfirmation() async {
    if (_quitDialogOpen) return false;
    _quitDialogOpen = true;
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = kMaxCardWidth;
    final double cardPadding = getResponsiveCardPadding(screenSize.width); // Responsive
    final double titleFontSize =
        (screenSize.width * 0.08).clamp(24, 36); // Responsive
    final double iconSize =
        (screenSize.width * 0.14).clamp(36, 60); // Responsive
    final double messageFontSize =
        (screenSize.width * 0.05).clamp(15, 22); // Responsive
    final double buttonFontSize =
        (screenSize.width * 0.055).clamp(16, 22); // Responsive
    final double buttonSpacing =
        (screenSize.width * 0.045).clamp(10, 22); // Responsive
    final double sectionSpacing =
        (screenSize.height * 0.03).clamp(14, 32); // Responsive
    final double buttonRowSpacing =
        (screenSize.height * 0.04).clamp(18, 40); // Responsive
    final double buttonVerticalPadding =
        (screenSize.height * 0.022).clamp(12, 28); // Responsive

    final result = await showGeneralDialog<bool>(
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
                  padding: EdgeInsets.symmetric(
                      horizontal: cardPadding, vertical: cardPadding),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quitGameTitle,
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
                        AppLocalizations.of(context)!.quitGameMessage,
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
                                    Color(0xFF8F6ED5)
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: buttonVerticalPadding),
                                  minimumSize: const Size(0, 48),
                                  textStyle: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.w600,
                                    fontSize: buttonFontSize,
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.no,
                                  style: GoogleFonts.baloo2(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w800,
                                    fontSize: buttonFontSize,
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
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: buttonVerticalPadding),
                                minimumSize: const Size(0, 48),
                                textStyle: GoogleFonts.baloo2(
                                  fontWeight: FontWeight.w600,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.yes,
                                style: GoogleFonts.baloo2(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: buttonFontSize,
                                ),
                              ),
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
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ) ?? false;
    _quitDialogOpen = false;
    // Resume dialog if needed
    if (!result &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true &&
        _pendingShowTruthDare) {
      _pendingShowTruthDare = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            ModalRoute.of(context)?.isCurrent == true &&
            !_scoreboardOpen &&
            !_quitDialogOpen &&
            !_lastPlayerFinished) {
          _showTruthDareDialog();
        }
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 252, 118, 84),
        Color.fromARGB(255, 245, 64, 100),
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
        appBar: AppHeader(
          title: AppLocalizations.of(context)!.randomTurn,
          centerTitle: true,
          leading: CustomAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () async {
              final shouldQuit = await _showQuitConfirmation();
              if (shouldQuit) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(setLocale: widget.setLocale)),
                  (Route<dynamic> route) => false,
                );
              }
            },
            tooltip: 'Home',
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: (MediaQuery.of(context).size.height * 0.12).clamp(64, 120),
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
              final double spacingLarge =
                  (constraints.maxHeight * 0.06).clamp(24, 60);
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: spacingLarge),
                        if (!_gameStarted && !_lastPlayerFinished)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _gameStarted = true;
                              });
                              _pickRandomPlayerWithSpin();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: (screenWidth * 0.18).clamp(32, 60),
                                vertical: (constraints.maxHeight * 0.025)
                                    .clamp(14, 28),
                              ),
                              textStyle: GoogleFonts.baloo2(
                                fontSize: (screenWidth * 0.045).clamp(15, 22),
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              shadowColor: Colors.transparent,
                            ),
                            child: AutoSizeText(
                              'Start',
                              minFontSize: 10,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              wrapWords: false,
                              style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.bold,
                                fontSize: (screenWidth * 0.045).clamp(15, 22),
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_gameStarted && (_currentIndex != null || _isSpinning))
                          PlayerCircle(
                            players: widget.players,
                            size: (screenWidth * 0.7).clamp(220.0, screenHeight * 0.55),
                            highlightedIndex: _isSpinning ? _highlightedIndex : _currentIndex,
                            animated: _isSpinning,
                            animationDuration: const Duration(milliseconds: 1800),
                            previousIndex: _isSpinning ? _previousIndex : null,
                            colors: _playerColors,
                          ),
                        SizedBox(height: spacingLarge),
                        if (_lastPlayerFinished) ...[
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
                                horizontal: (screenWidth * 0.18).clamp(32, 60),
                                vertical: (constraints.maxHeight * 0.025)
                                    .clamp(14, 28),
                              ),
                              textStyle: GoogleFonts.baloo2(
                                fontSize: (screenWidth * 0.045).clamp(15, 22),
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                              shadowColor: Colors.transparent,
                            ),
                            child: AutoSizeText(
                              AppLocalizations.of(context)!.restart,
                              minFontSize: 10,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              wrapWords: false,
                              style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.bold,
                                fontSize: (screenWidth * 0.045).clamp(15, 22),
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: spacingLarge * 0.7),
                          AutoSizeText(
                            AppLocalizations.of(context)!.allPlayersHadTurn,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            minFontSize: 10,
                            maxLines: 2,
                            wrapWords: true,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
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
                          },
                        ),
                        _buildIconButton(
                          Icons.emoji_events_outlined,
                          _showScoreboardDialog,
                        ),
                      ],
                    ),
                  ),
                  // Truth/Dare dialog/buttons
                  // Removed the overlay for _showTruthDarePrompt
                ],
              );
            },
          ),
        ),
      ),
    );
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
          BoxShadow(
              color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
          BoxShadow(
              color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
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
}
