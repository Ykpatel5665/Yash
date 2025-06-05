import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation
import 'main.dart'; // For AgeGroup enum
import 'player_circle_painter.dart'; // Import the player circle widget
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart'; // Import for question logic
import 'truth_dare_question_screen.dart';
import 'custom_appbar_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'l10n/app_localizations.dart';

// Define Game States
enum GamePhase { readyToSpin, spinning, awaitingTruthDare }

// Convert to StatefulWidget
class SpinTheBottleScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  final void Function(Locale) setLocale;

  const SpinTheBottleScreen({
    super.key,
    required this.players,
    required this.ageGroup,
    required this.selectedCategoryIds,
    required this.useTimer,
    required this.setLocale,
  });

  @override
  State<SpinTheBottleScreen> createState() => _SpinTheBottleScreenState();
}

class _SpinTheBottleScreenState extends State<SpinTheBottleScreen>
    with SingleTickerProviderStateMixin {
  double _currentAngle = 0.0;
  late AnimationController _controller;
  Animation<double>? _animation;
  bool _isMuted = false;
  GamePhase _gamePhase = GamePhase.readyToSpin;
  int? _selectedPlayerIndex;
  Map<String, int> _playerScores = {};

  // Variables for gesture handling
  Offset? _lastPanPosition; // Store the last pan position

  // Flags for dialog and game state management
  bool _scoreboardOpen = false;
  bool _quitDialogOpen = false;
  bool _pendingShowTruthDare = false;

  // --- ADDED: Store shuffled player colors for this game session ---
  late List<Color> _playerColors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Duration will be set dynamically in _initiateSpinAnimation
    )..addListener(() {
        if (_animation != null && _gamePhase == GamePhase.spinning) {
          setState(() {
            _currentAngle = _animation!.value;
          });
        }
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          if (_gamePhase == GamePhase.spinning) {
            _onSpinComplete();
          }
        }
      });
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    // --- ADDED: Shuffle the color palette at the start of the game ---
    _playerColors = PlayerCirclePainter.shuffleColors();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Called when spin animation finishes ---
  void _onSpinComplete() {
    // print("Spin Complete. Final Raw Angle: ${_currentAngle.toStringAsFixed(2)}");
    final double finalAngle = _currentAngle % (2 * math.pi);
    final normalizedAngle = finalAngle < 0 ? finalAngle + 2 * math.pi : finalAngle;

    final selectedIndex = _getSelectedPlayerIndex(normalizedAngle);

    setState(() {
      _currentAngle = normalizedAngle;
      _gamePhase = GamePhase.awaitingTruthDare;
      _selectedPlayerIndex = selectedIndex;
    });

    // print("Normalized Angle: ${normalizedAngle.toStringAsFixed(2)}, Selected Index: $selectedIndex");

    if (selectedIndex >= 0 && selectedIndex < widget.players.length) {
      final playerName = widget.players[selectedIndex];
      Future.delayed(const Duration(milliseconds: 700), () async {
        await _showTruthDareDialog(playerName);
      });
    } else {
      // No player selected (e.g. if playerCount is 0 or error in logic)
        setState(() {
          _gamePhase = GamePhase.readyToSpin;
          _selectedPlayerIndex = null;
          _controller.reset(); // <--- ADDED RESET
        });
    }
  }

  // --- Show Truth/Dare dialog with interruption logic ---
  Future<void> _showTruthDareDialog(String playerName) async {
    if (_scoreboardOpen || _quitDialogOpen) {
      _pendingShowTruthDare = true;
      return;
    }
    _pendingShowTruthDare = false;
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
      _onTruthSelected();
    } else if (result == 'dare') {
      _onDareSelected();
    } else {
      setState(() {
        _gamePhase = GamePhase.readyToSpin;
        _selectedPlayerIndex = null;
        _controller.reset();
      });
    }
  }

  // --- Calculate Selected Player ---
  int _getSelectedPlayerIndex(double finalAngle) {
    final int playerCount = widget.players.length;
    if (playerCount == 0) return -1;

    final double anglePerPlayer = (2 * math.pi) / playerCount;

    final normalizedTipAngle = finalAngle % (2 * math.pi);
    final positiveNormalizedTipAngle = normalizedTipAngle < 0 ? normalizedTipAngle + (2 * math.pi) : normalizedTipAngle;

    int selectedIndex = (positiveNormalizedTipAngle / anglePerPlayer).floor();

    selectedIndex = selectedIndex % playerCount;

    print(
        "Final Angle (Tip rel UP): $positiveNormalizedTipAngle, Selected Index (by Tip): $selectedIndex");

    return selectedIndex;
  }

  // --- Gesture Handling --- (These are the intended current versions)
  void _onPanStart(DragStartDetails details) {
    if (_gamePhase != GamePhase.readyToSpin) return;
    _controller.stop(); 
    _lastPanPosition = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gamePhase != GamePhase.readyToSpin || _lastPanPosition == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset center = renderBox.size.center(Offset.zero);

    final double previousAngle = math.atan2(_lastPanPosition!.dy - center.dy, _lastPanPosition!.dx - center.dx);
    final double currentGestureAngle = math.atan2(details.localPosition.dy - center.dy, details.localPosition.dx - center.dx);
    
    double deltaAngle = currentGestureAngle - previousAngle;

    if (deltaAngle > math.pi) {
      deltaAngle -= 2 * math.pi;
    } else if (deltaAngle < -math.pi) {
      deltaAngle += 2 * math.pi;
    }

    setState(() {
      _currentAngle += deltaAngle;
    });

    _lastPanPosition = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gamePhase != GamePhase.readyToSpin || _lastPanPosition == null) {
      _lastPanPosition = null;
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset center = renderBox.size.center(Offset.zero);
    
    final Offset pixelsPerSecond = details.velocity.pixelsPerSecond;
    final Offset r = _lastPanPosition! - center;

    if (r.distanceSquared == 0) {
      _lastPanPosition = null;
      return;
    }

    double angularVelocity = (r.dx * pixelsPerSecond.dy - r.dy * pixelsPerSecond.dx) / r.distanceSquared;
    angularVelocity *= 2.0; 

    if (angularVelocity.abs() > 0.5) { 
      _initiateSpinAnimation(angularVelocity);
    }
    _lastPanPosition = null;
  }

  void _initiateSpinAnimation(double initialAngularVelocity) {

    if (!initialAngularVelocity.isFinite || initialAngularVelocity.abs() < 0.1) {
      if (_gamePhase == GamePhase.spinning) {
        setState(() {
          _gamePhase = GamePhase.readyToSpin;
        });
      }
      return;
    }

    if (_gamePhase != GamePhase.spinning) {
      setState(() {
        _gamePhase = GamePhase.spinning;
        _selectedPlayerIndex = null;
      });
    }

    const double testSpinDurationSeconds = 2.0; 
    const double testRotations = 3.0;          

    final double direction = initialAngularVelocity.sign;
    final double targetAngleDelta = direction * testRotations * 2 * math.pi;
    final double targetAngle = _currentAngle + targetAngleDelta;

    if (!_currentAngle.isFinite || !targetAngle.isFinite) {
      setState(() {
        _gamePhase = GamePhase.readyToSpin; 
      });
      return;
    }

    _animation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, 
      ),
    );

    final int animationDurationMilliseconds = (testSpinDurationSeconds * 1000).toInt();
    if (animationDurationMilliseconds <= 0) {
      setState(() {
        _gamePhase = GamePhase.readyToSpin; 
      });
      return;
    }

    _controller.duration = Duration(milliseconds: animationDurationMilliseconds);
    
    _controller.forward(from: 0.0);
  }

  // --- Truth/Dare Action Handlers ---
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

  void _onTruthSelected() async {
    if (_gamePhase != GamePhase.awaitingTruthDare || _selectedPlayerIndex == null) return;
    final question = await _getRandomQuestionFromJson(type: 'truth');
    final playerName = widget.players[_selectedPlayerIndex!];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruthDareQuestionScreen(
          playerName: playerName,
          questionText: question?.text ?? 'No truth found for this category.',
          isTruth: true,
          onDone: () {
            _playerScores[playerName] = (_playerScores[playerName] ?? 0) + 1;
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _controller.reset(); // <--- ADDED RESET
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _controller.reset(); // <--- ADDED RESET
            });
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  }

  void _onDareSelected() async {
    if (_gamePhase != GamePhase.awaitingTruthDare || _selectedPlayerIndex == null) return;
    final question = await _getRandomQuestionFromJson(type: 'dare');
    final playerName = widget.players[_selectedPlayerIndex!];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TruthDareQuestionScreen(
          playerName: playerName,
          questionText: question?.text ?? 'No dare found for this category.',
          isTruth: false,
          onDone: () {
            _playerScores[playerName] = (_playerScores[playerName] ?? 0) + 1;
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _controller.reset(); // <--- ADDED RESET
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _controller.reset(); // <--- ADDED RESET
            });
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  }

  // Helper function to build styled icon buttons (similar to home screen)
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    final Size screenSize = MediaQuery.of(context).size;
    final double minBtn = 44, maxBtn = 70;
    final double btnSize = (screenSize.width * 0.13).clamp(minBtn, maxBtn);
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
          size: btnSize * 0.4, // Adjusted icon size based on button size
        ),
      ),
    );
  }

  // --- Scoreboard dialog with interruption/resume logic ---
  void _showScoreboardDialog() async {
    if (_scoreboardOpen) return;
    setState(() {
      _scoreboardOpen = true;
    });
    await showDialog(
      context: context,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double cardWidth = screenSize.width * 0.92;
        final double maxCardWidth = 420;
        final double cardPadding = 24.0;
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);

        // Gradient for the Close button (similar to Truth/Dare dialog)
        BoxDecoration closeButtonDecoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4DD0E1), // Cyan
              Color(0xFF1976D2), // Blue
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
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.88,
                  ),
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          AppLocalizations.of(context)!.scoreboard,
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
                          minFontSize: 12,
                          maxLines: 2,
                          wrapWords: true,
                        ),
                        SizedBox(height: 28),
                        Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD700), // Gold
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
                        Column(
                          children: [
                            ...widget.players.map((player) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                        SizedBox(height: 32),
                        DecoratedBox(
                          decoration: closeButtonDecoration,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                              textStyle: GoogleFonts.baloo2(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
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
    if (mounted && ModalRoute.of(context)?.isCurrent == true && _pendingShowTruthDare) {
      _pendingShowTruthDare = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true && !_scoreboardOpen && !_quitDialogOpen && _gamePhase == GamePhase.awaitingTruthDare && _selectedPlayerIndex != null) {
          final playerName = widget.players[_selectedPlayerIndex!];
          _showTruthDareDialog(playerName);
        }
      });
    }
  }

  // --- Quit confirmation dialog with interruption/resume logic ---
  Future<bool> _showQuitConfirmation() async {
    if (_quitDialogOpen) return false;
    _quitDialogOpen = true;
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
                                    fontWeight: FontWeight.w800,
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
    // Resume dialog if needed
    if (!result && mounted && ModalRoute.of(context)?.isCurrent == true && _pendingShowTruthDare) {
      _pendingShowTruthDare = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true && !_scoreboardOpen && !_quitDialogOpen && _gamePhase == GamePhase.awaitingTruthDare && _selectedPlayerIndex != null) {
          final playerName = widget.players[_selectedPlayerIndex!];
          _showTruthDareDialog(playerName);
        }
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // ... existing AppBar and background setup ...
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
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
        // ... existing AppBar ...
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
            tooltip: AppLocalizations.of(context)!.homeTooltip,
          ),
          // ...rest of AppBar properties...
          title: AutoSizeText(
            AppLocalizations.of(context)!.spinTitle,
            style: appBarTheme.titleTextStyle,
            maxLines: 1,
            minFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: appBarTheme.toolbarHeight,
          titleSpacing: appBarTheme.titleSpacing,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(gradient: backgroundGradient),
                child: SafeArea(
                  child: LayoutBuilder( // Use LayoutBuilder for responsive sizing
                    builder: (context, constraints) {
                      // Calculate responsive sizes based on available height/width
                      final double availableHeight = constraints.maxHeight;
                      final double availableWidth = constraints.maxWidth;

                      // Define spacing percentages (adjust these as needed)
                      final double topSpacingPercent = 0.08; // Space between AppBar and Wheel
                      final double bottomSpacingPercent = 0.06; // Space between Wheel and Buttons
                      final double buttonBottomPaddingPercent = 0.05; // Padding below buttons

                      // Calculate available height for the wheel itself
                      final double wheelMaxHeight = availableHeight * (1.0 -
                          topSpacingPercent -
                          bottomSpacingPercent -
                          buttonBottomPaddingPercent -
                          0.1); // Subtract space for buttons row height (approx 0.1)

                      // Adjust circle size based on available space
                      final double circleDiameter = math.min(availableWidth * 0.8, wheelMaxHeight);

                      // Calculate spacing in pixels
                      final double topSpacing = availableHeight * topSpacingPercent;
                      final double bottomSpacing = availableHeight * bottomSpacingPercent;
                      final double buttonBottomPadding = availableHeight * buttonBottomPaddingPercent;
                      final double buttonRowHorizontalPadding = availableWidth * 0.05;

                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: topSpacing), // Space below AppBar

                                // Wheel Stack (not centered anymore, positioned by Column)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Player Circle with responsive size and highlight
                                    PlayerCircle(
                                      players: widget.players,
                                      size: circleDiameter,
                                      // Highlight the selected player
                                      highlightedIndex: _gamePhase == GamePhase.awaitingTruthDare ? _selectedPlayerIndex : null,
                                      colors: _playerColors, // Pass the shuffled palette
                                    ),

                                    // Spinning Bottle with responsive size
                                    Positioned(
                                      child: GestureDetector(
                                        onPanStart: _onPanStart,
                                        onPanUpdate: _onPanUpdate,
                                        onPanEnd: _onPanEnd,
                                        // Disable gestures while spinning or choosing T/D
                                        behavior: (_gamePhase == GamePhase.readyToSpin)
                                            ? HitTestBehavior.deferToChild // Allow gestures only when ready
                                            : HitTestBehavior.opaque, // Block gestures otherwise
                                        child: Transform.rotate(
                                          angle: _currentAngle,
                                          child: Image.asset(
                                            'assets/bottle.png',
                                            height: circleDiameter * 0.6,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: circleDiameter * 0.6,
                                                color: Colors.red.withOpacity(0.5),
                                                child: const Center(child: Text('Add bottle.png to assets!', style: TextStyle(color: Colors.white)))
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: bottomSpacing), // Space above buttons

                                // Bottom Action Buttons
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: buttonBottomPadding,
                                    left: buttonRowHorizontalPadding,
                                    right: buttonRowHorizontalPadding,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      _buildIconButton(
                                        _isMuted ? Icons.volume_off : Icons.volume_up,
                                        () {
                                          setState(() {
                                            _isMuted = !_isMuted;
                                          });
                                          print("Volume Toggled: ${_isMuted ? 'Muted' : 'Unmuted'}");
                                          // TODO: Implement actual volume control logic
                                        },
                                      ),
                                      _buildIconButton(
                                        Icons.emoji_events_outlined, // Use trophy icon
                                        _showScoreboardDialog,
                                      ),
                                      _buildIconButton(
                                        Icons.play_circle_outline,
                                        () {
                                          print("Watch Ad / Premium pressed");
                                          // TODO: Implement ad watching or premium feature logic
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure PlayerCircle accepts highlightedIndex
// (Need to check/update player_circle_painter.dart if necessary)

// Popup dialog widget for Truth/Dare selection
class _TruthDareDialog extends StatelessWidget {
  final String playerName;
  const _TruthDareDialog({required this.playerName});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = 24.0;
    final localizations = AppLocalizations.of(context)!;

    // Truth: Blue/Cyan, Dare: Pink/Red
    BoxDecoration truthButtonDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF4DD0E1), // Cyan
          Color(0xFF1976D2), // Blue
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
    );
    BoxDecoration dareButtonDecoration = BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFF5F6D), // Pink
          Color(0xFFFFC371), // Orange/Yellow
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
                    localizations.itsTurn(playerName),
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
                                localizations.truthBtn,
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
                                localizations.dareBtn,
                                style: buttonTextStyle,
                              ),
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
  }
}
