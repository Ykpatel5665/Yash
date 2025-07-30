import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'widgets/headers/app_header.dart';
import 'utils/sound_manager.dart';
import 'package:provider/provider.dart';
import 'providers/sound_provider.dart';
import 'widgets/cards/game_card.dart';

// Define Game States
enum GamePhase { readyToSpin, spinning, awaitingTruthDare }

// Convert to StatefulWidget
class SpinTheBottleScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  final void Function(Locale) setLocale;
  final bool hapticsEnabled;
  final void Function(bool)? onHapticsChanged;

  const SpinTheBottleScreen({
    super.key,
    required this.players,
    required this.ageGroup,
    required this.selectedCategoryIds,
    required this.useTimer,
    required this.setLocale,
    required this.hapticsEnabled,
    this.onHapticsChanged,
  });

  @override
  State<SpinTheBottleScreen> createState() => _SpinTheBottleScreenState();
}

class _SpinTheBottleScreenState extends State<SpinTheBottleScreen>
    with SingleTickerProviderStateMixin {
  double _currentAngle = 0.0;
  late final Ticker _spinTicker;
  double _angularVelocity = 0.0; // radians per tick
  static const double _friction = 0.020; // Increased friction for faster stop
  static const double _minAngularVelocity = 0.01; // Increased threshold to stop
  static const double _maxAngularVelocity = 1.5; // Allow harder/faster spins
  bool _isSpinning = false;
  GamePhase _gamePhase = GamePhase.readyToSpin;
  int? _selectedPlayerIndex;
  Map<String, int> _playerScores = {};

  // Variables for gesture handling
  Offset? _lastPanPosition; // Store the last pan position
  double? _dragStartAngle; // Angle at drag start
  double? _dragPrevAngle; // Previous angle during drag
  DateTime? _dragStartTime; // For velocity calculation
  DateTime? _dragPrevTime;

  // Flags for dialog and game state management
  bool _scoreboardOpen = false;
  bool _quitDialogOpen = false;
  bool _pendingShowTruthDare = false;

  // --- ADDED: Store shuffled player colors for this game session ---
  late List<Color> _playerColors;

  Duration? _spinStartTime;
  static const Duration _minSpinDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _spinTicker = Ticker(_onSpinTick);
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    // --- ADDED: Shuffle the color palette at the start of the game ---
    _playerColors = PlayerCirclePainter.shuffleColors();
  }

  @override
  void dispose() {
    _spinTicker.dispose();
    super.dispose();
  }

  // --- Called when spin animation finishes ---
  void _onSpinComplete() {
    final double finalAngle = _currentAngle % (2 * math.pi);
    final normalizedAngle = finalAngle < 0 ? finalAngle + 2 * math.pi : finalAngle;
    final selectedIndex = _getSelectedPlayerIndex(normalizedAngle);
    setState(() {
      _currentAngle = normalizedAngle;
      _gamePhase = GamePhase.awaitingTruthDare;
      _selectedPlayerIndex = selectedIndex;
    });
    if (selectedIndex >= 0 && selectedIndex < widget.players.length) {
      final playerName = widget.players[selectedIndex];
      Future.delayed(const Duration(milliseconds: 700), () async {
        await _showTruthDareDialog(playerName);
      });
    } else {
      setState(() {
        _gamePhase = GamePhase.readyToSpin;
        _selectedPlayerIndex = null;
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
      _onTruthSelected();
    } else if (result == 'dare') {
      _onDareSelected();
    } else {
      setState(() {
        _gamePhase = GamePhase.readyToSpin;
        _selectedPlayerIndex = null;
      });
    }
  }

  // --- Calculate Selected Player ---
  int _getSelectedPlayerIndex(double finalAngle) {
    final int playerCount = widget.players.length;
    if (playerCount == 0) return -1;

    final double anglePerPlayer = (2 * math.pi) / playerCount;

    final normalizedTipAngle = finalAngle % (2 * math.pi);
    final positiveNormalizedTipAngle = normalizedTipAngle < 0
        ? normalizedTipAngle + (2 * math.pi)
        : normalizedTipAngle;

    int selectedIndex = (positiveNormalizedTipAngle / anglePerPlayer).floor();

    selectedIndex = selectedIndex % playerCount;

    // ...existing code...
    return selectedIndex;
  }

  // --- Gesture Handling --- (These are the intended current versions)
  void _onPanStart(DragStartDetails details) {
    if (_gamePhase != GamePhase.readyToSpin) return;
    _stopSpin();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset center = renderBox.size.center(Offset.zero);
    _lastPanPosition = details.localPosition;
    _dragStartAngle = math.atan2(details.localPosition.dy - center.dy, details.localPosition.dx - center.dx);
    _dragPrevAngle = _dragStartAngle;
    _dragStartTime = DateTime.now();
    _dragPrevTime = _dragStartTime;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gamePhase != GamePhase.readyToSpin || _lastPanPosition == null) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset center = renderBox.size.center(Offset.zero);
    final double prevAngle = _dragPrevAngle ?? 0.0;
    final double currentAngle = math.atan2(details.localPosition.dy - center.dy, details.localPosition.dx - center.dx);
    double deltaAngle = currentAngle - prevAngle;
    if (deltaAngle > math.pi) {
      deltaAngle -= 2 * math.pi;
    } else if (deltaAngle < -math.pi) {
      deltaAngle += 2 * math.pi;
    }
    setState(() {
      _currentAngle += deltaAngle;
    });
    _lastPanPosition = details.localPosition;
    _dragPrevAngle = currentAngle;
    _dragPrevTime = DateTime.now();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gamePhase != GamePhase.readyToSpin || _lastPanPosition == null) {
      _lastPanPosition = null;
      _dragStartAngle = null;
      _dragPrevAngle = null;
      _dragStartTime = null;
      _dragPrevTime = null;
      return;
    }
    // Calculate angular velocity based on last drag movement
    double velocity = 0.0;
    if (_dragPrevAngle != null && _dragStartAngle != null && _dragPrevTime != null && _dragStartTime != null) {
      final double angleDiff = _dragPrevAngle! - _dragStartAngle!;
      final double timeDiff = _dragPrevTime!.difference(_dragStartTime!).inMilliseconds / 1000.0;
      if (timeDiff > 0.0) {
        velocity = angleDiff / timeDiff;
      }
    }
    // Clamp velocity
    velocity = velocity.clamp(-_maxAngularVelocity, _maxAngularVelocity);
    if (velocity.abs() > 0.1) {
      _startSpin(velocity);
    }
    _lastPanPosition = null;
    _dragStartAngle = null;
    _dragPrevAngle = null;
    _dragStartTime = null;
    _dragPrevTime = null;
  }

  void _startSpin(double initialAngularVelocity) {
    if (!initialAngularVelocity.isFinite || initialAngularVelocity.abs() < 0.1) {
      setState(() {
        _gamePhase = GamePhase.readyToSpin;
      });
      return;
    }
    final random = math.Random();
    final double randomBonus = random.nextDouble() * 0.3; // Slight randomness
    final double velocityWithRandom = initialAngularVelocity.isNegative
      ? initialAngularVelocity - randomBonus
      : initialAngularVelocity + randomBonus;
    setState(() {
      _gamePhase = GamePhase.spinning;
      _selectedPlayerIndex = null;
      _isSpinning = true;
      _angularVelocity = velocityWithRandom;
      _spinStartTime = null; // Will be set on first tick
    });
    SoundManager.playBottleSound(context: context); // Start sound here
    _spinTicker.start();
  }

  void _onSpinTick(Duration elapsed) {
    if (!_isSpinning) return;
    setState(() {
      if (_spinStartTime == null) {
        _spinStartTime = elapsed;
      }
      _currentAngle += _angularVelocity;
      // Keep angle in [0, 2pi)
      if (_currentAngle < 0) {
        _currentAngle += 2 * math.pi;
      } else if (_currentAngle >= 2 * math.pi) {
        _currentAngle -= 2 * math.pi;
      }
      // Apply friction (realistic)
      _angularVelocity *= 0.98;
      // Calculate elapsed spin time
      final spinElapsed = elapsed - (_spinStartTime ?? elapsed);
      // Stop if velocity is low AND minimum duration reached
      if (_angularVelocity.abs() < _minAngularVelocity && spinElapsed >= _minSpinDuration) {
        _isSpinning = false;
        _spinTicker.stop();
        SoundManager.stopBottleSound(); // Stop sound when spin ends
        _onSpinComplete();
      } else if (_angularVelocity.abs() < _minAngularVelocity && spinElapsed < _minSpinDuration) {
        // Keep spinning slowly until min duration
        _angularVelocity = _minAngularVelocity * (_angularVelocity.isNegative ? -1 : 1);
      }
    });
  }

  // --- Truth/Dare Action Handlers ---
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

  void _onTruthSelected() async {
    if (_gamePhase != GamePhase.awaitingTruthDare ||
        _selectedPlayerIndex == null) return;
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
              _stopSpin();
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _stopSpin();
            });
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  }

  void _onDareSelected() async {
    if (_gamePhase != GamePhase.awaitingTruthDare ||
        _selectedPlayerIndex == null) return;
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
              _stopSpin();
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
              _stopSpin();
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
      barrierDismissible: true, // Allow dismiss on tap outside
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double maxCardWidth = 420;
        final double cardPadding = (screenSize.width * 0.06).clamp(16, 32);
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);
        final double iconSize = (screenSize.width * 0.14).clamp(36, 60);
        final double maxDialogHeight = (screenSize.height * 0.7).clamp(320, 600);
        final localizations = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GameCard(
            maxWidth: maxCardWidth,
            padding: EdgeInsets.all(cardPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: Stack(
                children: [
                  // Main content column (header, icon, player list)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSizeText(
                        localizations.scoreboard,
                        style: GoogleFonts.baloo2(
                          fontSize: (screenSize.width * 0.08).clamp(24, 36),
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
                      SizedBox(height: (screenSize.height * 0.03).clamp(14, 32)),
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD700),
                        size: iconSize,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      SizedBox(height: (screenSize.height * 0.03).clamp(14, 32)),
                      // Scrollable player list
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...(() {
                                final sortedPlayers = [...widget.players];
                                sortedPlayers.sort((a, b) => (_playerScores[b] ?? 0).compareTo(_playerScores[a] ?? 0));
                                return sortedPlayers.map((player) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: (screenSize.height * 0.008).clamp(4, 12)),
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
                                )).toList();
                              })(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: (screenSize.height * 0.09).clamp(40, 80)), // Space for floating button
                    ],
                  ),
                  // Floating close button at the bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (screenSize.height * 0.02).clamp(10, 24),
                        left: (screenSize.width * 0.04).clamp(8, 20),
                        right: (screenSize.width * 0.04).clamp(8, 20),
                      ),
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
                            SoundManager.playButtonSound(context: context);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: (screenSize.height * 0.022).clamp(12, 28),
                              horizontal: (screenSize.width * 0.08).clamp(18, 40),
                            ),
                            textStyle: GoogleFonts.baloo2(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
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
            _gamePhase == GamePhase.awaitingTruthDare &&
            _selectedPlayerIndex != null) {
          final playerName = widget.players[_selectedPlayerIndex!];
          _showTruthDareDialog(playerName);
        }
      });
    }
  }

  // --- Quit confirmation dialog with interruption/resume logic ---
  Future<bool> _showQuitConfirmation() async {
    if (_quitDialogOpen) return false;
    setState(() {
      _quitDialogOpen = true;
    });
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92;
    final double maxCardWidth = 420;
    final double cardPadding = (screenSize.width * 0.06).clamp(16, 32);
    final double titleFontSize = (screenSize.width * 0.08).clamp(24, 36);
    final double iconSize = (screenSize.width * 0.14).clamp(36, 60);
    final double messageFontSize = (screenSize.width * 0.05).clamp(15, 22);
    final double buttonFontSize = (screenSize.width * 0.055).clamp(16, 22);
    final double buttonSpacing = (screenSize.width * 0.045).clamp(10, 22);
    final double sectionSpacing = (screenSize.height * 0.03).clamp(14, 32);
    final double buttonRowSpacing = (screenSize.height * 0.04).clamp(18, 40);
    final double buttonVerticalPadding = (screenSize.height * 0.022).clamp(12, 28);

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quitGameTitle,
                        style: GoogleFonts.baloo2(
                          fontSize: titleFontSize,
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
                      SizedBox(height: sectionSpacing),
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white70,
                        size: iconSize,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withAlpha((0.4 * 255).round()),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),
                      Text(
                        AppLocalizations.of(context)!.quitGameMessage,
                        style: GoogleFonts.baloo2(
                          fontSize: messageFontSize,
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: buttonRowSpacing),
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
                                  SoundManager.playButtonSound(context: context);
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
                          SizedBox(width: buttonSpacing),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                SoundManager.playButtonSound(context: context);
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
    ) ??
    false;
    setState(() {
      _quitDialogOpen = false;
    });
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
            _gamePhase == GamePhase.awaitingTruthDare &&
            _selectedPlayerIndex != null) {
          final playerName = widget.players[_selectedPlayerIndex!];
          _showTruthDareDialog(playerName);
        }
      });
    }
    return result;
  }

  void _stopSpin() {
    if (_isSpinning) {
      _spinTicker.stop();
      setState(() {
        _isSpinning = false;
        _angularVelocity = 0.0;
      });
      SoundManager.stopBottleSound(); // Always stop sound
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... existing AppBar and background setup ...
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
          title: AppLocalizations.of(context)!.spinTitle,
          centerTitle: true,
          leading: CustomAppBarButton(
            icon: Icons.home_rounded,
            onPressed: () async {
              final shouldQuit = await _showQuitConfirmation();
              if (shouldQuit) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyHomePage(setLocale: widget.setLocale)),
                  (Route<dynamic> route) => false,
                );
              }
            },
            tooltip: AppLocalizations.of(context)!.homeTooltip,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight:
              (MediaQuery.of(context).size.height * 0.12).clamp(64, 120),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: backgroundGradient),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;
              final double buttonRowHorizontalPadding = screenWidth * 0.05;
              final double buttonBottomPadding = screenHeight * 0.05;
              final double wheelSize =
                  (screenWidth * 0.7).clamp(220.0, screenHeight * 0.55);
              return Stack(
                children: [
                  // Centered wheel
                  Column(
                    children: [
                      const Spacer(),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PlayerCircle(
                              players: widget.players,
                              size: wheelSize,
                              highlightedIndex:
                                  _gamePhase == GamePhase.awaitingTruthDare
                                      ? _selectedPlayerIndex
                                      : null,
                              colors: _playerColors,
                            ),
                            Positioned(
                              child: GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                behavior: (_gamePhase == GamePhase.readyToSpin)
                                    ? HitTestBehavior.deferToChild
                                    : HitTestBehavior.opaque,
                                child: Transform.rotate(
                                  angle: _currentAngle,
                                  child: Image.asset(
                                    'assets/bottle.png',
                                    height: wheelSize * 0.6,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: wheelSize * 0.6,
                                        color: Colors.red.withOpacity(0.5),
                                        child: const Center(
                                            child: Text(
                                                'Add bottle.png to assets!',
                                                style: TextStyle(
                                                    color: Colors.white))),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  // Button row pinned to bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: buttonBottomPadding,
                        left: buttonRowHorizontalPadding,
                        right: buttonRowHorizontalPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Consumer<SoundProvider>(
                            builder: (context, soundProvider, child) => _buildIconButton(
                              soundProvider.isSoundOn ? Icons.volume_up : Icons.volume_off,
                              () {
                                soundProvider.toggleSound();
                                if (widget.onHapticsChanged != null) {
                                  widget.onHapticsChanged!(soundProvider.isSoundOn);
                                }
                              },
                            ),
                          ),
                          _buildIconButton(
                            Icons.emoji_events_outlined,
                            () {
                              SoundManager.playButtonSound(context: context);
                              _showScoreboardDialog();
                            },
                          ),
                          _buildIconButton(
                            Icons.play_circle_outline,
                            () {
                              SoundManager.playButtonSound(context: context);
                              // TODO: Implement ad watching or premium feature logic
                            },
                          ),
                        ],
                      ),
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
                              SoundManager.playButtonSound(context: context);
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
                              SoundManager.playButtonSound(context: context);
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
                  SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        SoundManager.playButtonSound(context: context);
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
                ], // end children
              ), // end Column
            ), // end Container
          ), // end BackdropFilter
        ), // end ClipRRect
      ), // end Material
    ); // end Center
  }
}
