import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation
import 'package:flutter/physics.dart'; // Import for physics simulation
import 'main.dart'; // For AgeGroup enum
import 'player_circle_painter.dart'; // Import the player circle widget
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'truth_dare_data.dart'; // Import for question logic
import 'truth_dare_question_screen.dart';

// Define Game States
enum GamePhase { readyToSpin, spinning, awaitingTruthDare }

// Convert to StatefulWidget
class SpinTheBottleScreen extends StatefulWidget {
  final List<String> players;
  final List<Color> playerColors;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;

  const SpinTheBottleScreen({
    super.key,
    required this.players,
    required this.playerColors,
    required this.ageGroup,
    required this.selectedCategoryIds,
  });

  @override
  State<SpinTheBottleScreen> createState() => _SpinTheBottleScreenState();
}

class _SpinTheBottleScreenState extends State<SpinTheBottleScreen>
    with SingleTickerProviderStateMixin { // Add TickerProviderStateMixin

  double _currentAngle = 0.0; // Angle for the bottle's rotation
  late AnimationController _controller; // Controller for spin animation
  Animation<double>? _animation; // Animation object
  bool _isMuted = false; // State for volume button

  // Game State Management
  GamePhase _gamePhase = GamePhase.readyToSpin;
  int? _selectedPlayerIndex; // Index of the player the bottle points to

  // Variables for gesture handling
  Offset? _startDragPos;
  double _startAngle = 0.0;
  // Removed _velocity state variable, rely on DragEndDetails.primaryVelocity

  Map<String, int> _playerScores = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Default duration, will be adjusted by velocity
      lowerBound: -double.infinity, // Allow indefinite spinning
      upperBound: double.infinity,
    )..addListener(() {
        // Only update angle if spinning or during manual drag
        if (_gamePhase == GamePhase.spinning || _startDragPos != null) {
          setState(() {
            _currentAngle = _animation?.value ?? _currentAngle;
          });
        }
      })..addStatusListener((status) {
         // Handle animation completion
         if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
           if (_gamePhase == GamePhase.spinning) {
             _onSpinComplete();
           }
         }
       });
    // Initialize scores
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Spin Logic ---
  void _startSpin(double velocity) {
    if (_gamePhase != GamePhase.readyToSpin) return; // Prevent spinning if not ready

    setState(() {
      _gamePhase = GamePhase.spinning;
      _selectedPlayerIndex = null; // Clear previous selection
    });

    _controller.stop();

    // Adjust friction and velocity scaling for smoother spin
    final simulation = FrictionSimulation(
      0.3, // Lower friction for longer spin (previously 0.6)
      _currentAngle,
      velocity / 1000, // Adjust velocity scaling (previously / 1000)
    );

    _animation = _controller.drive(Tween<double>(begin: _currentAngle, end: simulation.finalX));

    // Use animateWith for physics-based animation
    _controller.animateWith(simulation);
    // Completion is now handled by the status listener
  }

  // --- Called when spin animation finishes ---
  void _onSpinComplete() {
    // Normalize angle to be within 0 to 2*PI
    final double finalAngle = _currentAngle % (2 * math.pi);
    final normalizedAngle = finalAngle < 0 ? finalAngle + 2 * math.pi : finalAngle;

    // Calculate selected player
    final selectedIndex = _getSelectedPlayerIndex(normalizedAngle);

    setState(() {
      _currentAngle = normalizedAngle; // Snap to the final normalized angle
      _gamePhase = GamePhase.awaitingTruthDare;
      _selectedPlayerIndex = selectedIndex;
    });

    // Optional: Add haptic feedback or sound effect here
    print("Spin complete. Final Angle: $normalizedAngle, Selected Player Index: $selectedIndex");

    // Show Truth or Dare selection as a popup dialog
    if (selectedIndex >= 0 && selectedIndex < widget.players.length) {
      final playerName = widget.players[selectedIndex];
      Future.delayed(const Duration(milliseconds: 700), () async {
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
        }
      });
    }
  }

  // --- Calculate Selected Player ---
  int _getSelectedPlayerIndex(double finalAngle) {
    final int playerCount = widget.players.length;
    if (playerCount == 0) return -1;

    final double anglePerPlayer = (2 * math.pi) / playerCount;

    // Normalize the final angle (bottle tip) to be within [0, 2*pi)
    // *** CRITICAL ASSUMPTION: angle = 0 means the bottle tip points UP ***
    final normalizedTipAngle = finalAngle % (2 * math.pi);
    final positiveNormalizedTipAngle = normalizedTipAngle < 0 ? normalizedTipAngle + (2 * math.pi) : normalizedTipAngle;

    // --- Select player based on the TIP's angle --- 
    // Since the painter starts Player 0 at UP (0 in this relative frame),
    // we can directly use the tip's angle.
    int selectedIndex = (positiveNormalizedTipAngle / anglePerPlayer).floor();

    // Ensure index is within bounds
    selectedIndex = selectedIndex % playerCount;

    print(
        "Final Angle (Tip rel UP): $positiveNormalizedTipAngle, Selected Index (by Tip): $selectedIndex");

    return selectedIndex;
  }

  // --- Gesture Handling ---
  void _onPanStart(DragStartDetails details) {
    // Allow dragging only when ready to spin
    if (_gamePhase != GamePhase.readyToSpin) return;
    _controller.stop();
    _startDragPos = details.localPosition;
    _startAngle = _currentAngle;
    // No need to reset _velocity here
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startDragPos == null || _gamePhase != GamePhase.readyToSpin) return;

    // Calculate center relative to the Stack
    final RenderBox box = context.findRenderObject() as RenderBox;
    final center = box.size.center(Offset.zero);

    final currentDragPos = details.localPosition;
    final angleStart = math.atan2(_startDragPos!.dy - center.dy, _startDragPos!.dx - center.dx);
    final angleUpdate = math.atan2(currentDragPos.dy - center.dy, currentDragPos.dx - center.dx);
    final angleDelta = angleUpdate - angleStart;

    // Directly update angle during drag without calculating intermediate velocity
    setState(() {
      _currentAngle = _startAngle + angleDelta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startDragPos == null || _gamePhase != GamePhase.readyToSpin) return;

    // Use the primary velocity from the gesture detector
    // This is often more reliable, especially for flicks
    final double flickVelocity = details.primaryVelocity ?? 0.0;

    // Start the spin animation with the final velocity
    // Only start if there was some velocity, otherwise just stop dragging
    if (flickVelocity.abs() > 50) { // Threshold to prevent accidental spins
       _startSpin(flickVelocity);
    } else {
       // If no significant flick, remain in readyToSpin state
       // Optionally, add a slight animation back to a resting position if needed
    }
    _startDragPos = null; // Reset drag start position
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
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
            });
          },
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
            });
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _gamePhase = GamePhase.readyToSpin;
              _selectedPlayerIndex = null;
            });
          },
        ),
      ),
    );
  }

  // Helper function to build styled icon buttons (similar to home screen)
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

  void _showScoreboardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        final double cardWidth = screenSize.width * 0.92;
        final double maxCardWidth = 420;
        final double cardPadding = 24.0;
        final double fontSize = (screenSize.width * 0.045).clamp(16, 26);
        final double buttonFontSize = (screenSize.width * 0.035).clamp(13, 18);
        final double iconSize = (screenSize.width * 0.08).clamp(22, 36);

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
                        Text(
                          'Scoreboard',
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
                                  Text(
                                    player,
                                    style: GoogleFonts.baloo2(
                                      fontSize: fontSize,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                'Close',
                                style: buttonTextStyle,
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
  }

  @override
  Widget build(BuildContext context) {
    // ... existing AppBar and background setup ...
    final AppBarTheme appBarTheme = Theme.of(context).appBarTheme;
    const Color baseColor = Color.fromARGB(255, 255, 255, 255);
    final Color shadowDark = Colors.black.withOpacity(0.3);
    final Color shadowLight = Colors.white.withOpacity(0.4);
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 252, 118, 84),
        Color.fromARGB(255, 245, 64, 100),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final double circleSize = MediaQuery.of(context).size.width * 0.8;
    final double bottleHeight = circleSize * 0.6; // Example bottle size relative to circle

    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await _showQuitConfirmation();
        return shouldQuit;
      },
      child: Scaffold(
        // ... existing AppBar ...
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 15, bottom: 15),
            child: GestureDetector(
              // Change onTap to navigate to home screen and clear stack
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
                // ... existing container decoration ...
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: shadowDark, offset: const Offset(3, 3), blurRadius: 6),
                    BoxShadow(color: shadowLight, offset: const Offset(-3, -3), blurRadius: 6),
                  ],
                ),
                // Changed icon to home
                child: const Icon(Icons.home_rounded, color: Color.fromARGB(255, 0, 0, 0), size: 24),
              ),
            ),
          ),
          // ... rest of AppBar properties ...
          title: Text('Spin the Bottle', style: appBarTheme.titleTextStyle),
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
                      final double bottleHeight = circleDiameter * 0.7; // Increased multiplier from 0.6

                      // Calculate spacing in pixels
                      final double topSpacing = availableHeight * topSpacingPercent;
                      final double bottomSpacing = availableHeight * bottomSpacingPercent;
                      final double buttonBottomPadding = availableHeight * buttonBottomPaddingPercent;
                      final double buttonRowHorizontalPadding = availableWidth * 0.05;

                      // Determine selected player name for display
                      String selectedPlayerName = "";
                      if (_gamePhase == GamePhase.awaitingTruthDare && _selectedPlayerIndex != null && _selectedPlayerIndex! < widget.players.length) {
                        selectedPlayerName = widget.players[_selectedPlayerIndex!];
                      }

                      // Use Column for vertical spacing control
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
                                      colors: widget.playerColors,
                                      size: circleDiameter,
                                      // Highlight the selected player
                                      highlightedIndex: _gamePhase == GamePhase.awaitingTruthDare ? _selectedPlayerIndex : null,
                                    ),

                                    // Spinning Bottle with responsive size
                                    Positioned(
                                      child: GestureDetector(
                                        onTap: (_gamePhase == GamePhase.readyToSpin)
                                            ? () {
                                                final randomVelocity = 5000.0 + math.Random().nextDouble() * 5000.0;
                                                _startSpin(randomVelocity);
                                              }
                                            : null,
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
                                            height: bottleHeight,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: bottleHeight,
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
    final double iconSize = (screenSize.width * 0.08).clamp(22, 36);
    final double fontSize = (screenSize.width * 0.035).clamp(13, 18);

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
                    'Whoopsie!',
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
                    "It's $playerName's turn",
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
                                "Truth!",
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
                                "Dare!",
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
