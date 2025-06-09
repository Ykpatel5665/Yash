import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'truth_dare_data.dart';
import 'truth_dare_question_screen.dart';
import 'main.dart'; // For AgeGroup enum
import 'widgets/cards/game_card.dart';
import 'custom_appbar_button.dart';
import 'player_circle_painter.dart';
import 'l10n/app_localizations.dart';
import 'widgets/headers/app_header.dart';
import 'dart:math' as math; // Import math for random selection

// Convert to StatefulWidget for turn management
class AutoNextTurnScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  const AutoNextTurnScreen({super.key, required this.players, required this.ageGroup, required this.selectedCategoryIds, required this.useTimer});

  @override
  State<AutoNextTurnScreen> createState() => _AutoNextTurnScreenState();
}

class _AutoNextTurnScreenState extends State<AutoNextTurnScreen> {
  int _currentIndex = 0;
  bool _lastPlayerFinished = false; // Track if last player finished
  Map<String, int> _playerScores = {};
  bool _isMuted = false; // State for volume button
  bool _scoreboardOpen = false;
  bool _pendingShowTruthDare = false; // Track if dialog should show after scoreboard
  bool _quitDialogOpen = false; // Track if quit confirmation dialog is open

  int _pendingHighlightIndex = -1; // For transition animation
  bool _isAnimatingHighlight = false;
  late List<Color> _playerColors;

  @override
  void initState() {
    super.initState();
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    // --- ADDED: Shuffle the color palette at the start of the game ---
    _playerColors = PlayerCirclePainter.shuffleColors();
    // Automatically show the Truth/Dare dialog after 2 seconds for the first player
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_lastPlayerFinished) {
        _showTruthOrDareDialog();
      }
    });
  }

  void _nextTurn() {
    if (_currentIndex == widget.players.length - 1) {
      setState(() {
        _lastPlayerFinished = true;
      });
    } else {
      // Animate highlight transition to next player
      setState(() {
        _isAnimatingHighlight = true;
        _pendingHighlightIndex = _currentIndex + 1;
      });
      Future.delayed(const Duration(milliseconds: 1800), () { // smoother and slower transition
        if (!mounted) return;
        setState(() {
          _currentIndex = _pendingHighlightIndex;
          _isAnimatingHighlight = false;
        });
        // Only show dialog if scoreboard is not open
        if (mounted && !_lastPlayerFinished && !_scoreboardOpen) {
          _showTruthOrDareDialog();
        }
      });
    }
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
              _nextTurn();
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _nextTurn();
            });
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  }

  void _showScoreboardDialog() async {
    setState(() {
      _scoreboardOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double maxCardWidth = 420;
        final double cardPadding = (screenSize.width * 0.06).clamp(16, 32); // Responsive
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);
        final double iconSize = (screenSize.width * 0.14).clamp(36, 60); // Responsive
        final localizations = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GameCard(
            maxWidth: maxCardWidth,
            padding: EdgeInsets.all(cardPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    localizations.scoreboard,
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
                    minFontSize: 12,
                    maxLines: 2,
                    wrapWords: true,
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
                                horizontal: (screenSize.width * 0.04).clamp(8, 20),
                                vertical: (screenSize.height * 0.008).clamp(4, 12),
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
                          localizations.close,
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
    // Only show dialog if we are still on this screen and not in the process of popping
    if (mounted && ModalRoute.of(context)?.isCurrent == true && (_pendingShowTruthDare || (!_lastPlayerFinished && !_pendingShowTruthDare))) {
      _pendingShowTruthDare = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_lastPlayerFinished && !_pendingShowTruthDare && ModalRoute.of(context)?.isCurrent == true && !_quitDialogOpen) {
          _showTruthOrDareDialog();
        }
      });
    }
  }

  Future<bool> _showQuitConfirmation() async {
    // Track if the Truth/Dare dialog should resume after closing
    final bool shouldResumeTruthDare = !_lastPlayerFinished && !_pendingShowTruthDare && !_scoreboardOpen && !_quitDialogOpen;
    _pendingShowTruthDare = false; // Block dialog while quit dialog is open
    _quitDialogOpen = true;
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonFontSize = (screenSize.width * 0.055).clamp(16, 22); // Responsive
    final double buttonSpacing = (screenSize.width * 0.045).clamp(10, 22); // Responsive
    final double sectionSpacing = (screenSize.height * 0.03).clamp(14, 32); // Responsive
    final double buttonRowSpacing = (screenSize.height * 0.04).clamp(18, 40); // Responsive
    final double buttonVerticalPadding = (screenSize.height * 0.022).clamp(12, 28); // Responsive
    // Define cardPadding, titleFontSize, iconSize, and messageFontSize at the start of the pageBuilder
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final double cardPadding = (screenSize.width * 0.06).clamp(16, 32);
        final double titleFontSize = (screenSize.width * 0.08).clamp(24, 36);
        final double iconSize = (screenSize.width * 0.14).clamp(36, 60);
        final double messageFontSize = (screenSize.width * 0.05).clamp(15, 22);
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding), // Responsive
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
                                  colors: [Color(0xFF5B86E5), Color(0xFF8F6ED5)],
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
                                  padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
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
                                padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
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
    _quitDialogOpen = false;
    // Resume Truth/Dare dialog if it was supposed to show and user said No
    if (!result && mounted && shouldResumeTruthDare) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_lastPlayerFinished && !_pendingShowTruthDare && ModalRoute.of(context)?.isCurrent == true) {
          _showTruthOrDareDialog();
        }
      });
    }
    return result;
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

  Future<void> _showTruthOrDareDialog() async {
    if (_scoreboardOpen || _quitDialogOpen) {
      _pendingShowTruthDare = true;
      return; // Prevent dialog if scoreboard or quit dialog is open
    }
    _pendingShowTruthDare = false;
    final playerName = widget.players[_currentIndex];
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
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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

  @override
  void deactivate() {
    // Prevent dialog from showing if navigating away (e.g., Home pressed)
    _pendingShowTruthDare = false;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double buttonFontSize = (screenWidth * 0.045).clamp(15, 22);
    final double buttonPaddingV = (screenHeight * 0.018).clamp(10, 22);
    final double buttonPaddingH = (screenWidth * 0.08).clamp(24, 40);
    final double spacingLarge = (screenHeight * 0.06).clamp(24, 60);
    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await _showQuitConfirmation();
        return shouldQuit;
      },
      child: Scaffold(        appBar: AppHeader(
          title: AppLocalizations.of(context)!.autoNextTurn,
          centerTitle: true,
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: (MediaQuery.of(context).size.height * 0.12).clamp(64, 120),
          actions: null,
          // Force single line, ellipsis, and responsive font size
          // This is handled by AppHeader's AutoSizeText, but we ensure maxLines: 1 and overflow: ellipsis
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: spacingLarge,
                          ),
                          PlayerCircle(
                            players: widget.players,
                            size: (screenWidth * 0.7).clamp(220.0, screenHeight * 0.55), // Responsive: min 220, max 55% of height
                            highlightedIndex: _isAnimatingHighlight ? _pendingHighlightIndex : _currentIndex,
                            animated: true,
                            animationDuration: const Duration(milliseconds: 1800), // smoother and slower
                            previousIndex: _isAnimatingHighlight ? _currentIndex : null,
                            colors: _playerColors, // Pass the shuffled palette
                          ),
                          SizedBox(height: spacingLarge),
                          if (_lastPlayerFinished) ...[
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentIndex = 0;
                                  _lastPlayerFinished = false;
                                  // --- ADDED: Shuffle the color palette on restart ---
                                  _playerColors = PlayerCirclePainter.shuffleColors();
                                  // Auto show dialog for first player after restart
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (mounted && !_lastPlayerFinished) {
                                      _showTruthOrDareDialog();
                                    }
                                  });
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
                              child: AutoSizeText(
                                AppLocalizations.of(context)!.restart,
                                minFontSize: 10,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                wrapWords: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: buttonFontSize,
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

// Add the _TruthDareDialog widget (copied and adapted from spin_the_bottle_screen.dart)
class _TruthDareDialog extends StatelessWidget {
  final String playerName;
  const _TruthDareDialog({required this.playerName});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = 24.0;
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
                    AppLocalizations.of(context)!.whoopsieTitle,
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
                  Text(
                    AppLocalizations.of(context)!.itsTurn(playerName),
                    style: GoogleFonts.baloo2(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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
                              child: Text(
                                AppLocalizations.of(context)!.truthBtn,
                                style: buttonTextStyle,
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
                              child: Text(
                                AppLocalizations.of(context)!.dareBtn,
                                style: buttonTextStyle,
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
                        final random = math.Random();
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
    );
  }
}