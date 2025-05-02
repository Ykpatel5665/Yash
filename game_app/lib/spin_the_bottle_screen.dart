import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation
import 'package:flutter/physics.dart'; // Import for physics simulation

import 'main.dart'; // For AgeGroup enum
import 'player_circle_painter.dart'; // Import the player circle widget

// Define Game States
enum GamePhase { readyToSpin, spinning, awaitingTruthDare }

// Convert to StatefulWidget
class SpinTheBottleScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;

  const SpinTheBottleScreen({
    super.key,
    required this.players,
    required this.ageGroup,
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
      velocity / 700, // Adjust velocity scaling (previously / 1000)
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
  void _onTruthSelected() {
    if (_gamePhase != GamePhase.awaitingTruthDare || _selectedPlayerIndex == null) return;
    print("Player ${widget.players[_selectedPlayerIndex!]} chose TRUTH!");
    // TODO: Implement actual Truth logic (e.g., show question)
    setState(() {
      _gamePhase = GamePhase.readyToSpin; // Reset for next turn
      _selectedPlayerIndex = null;
    });
  }

  void _onDareSelected() {
    if (_gamePhase != GamePhase.awaitingTruthDare || _selectedPlayerIndex == null) return;
    print("Player ${widget.players[_selectedPlayerIndex!]} chose DARE!");
    // TODO: Implement actual Dare logic (e.g., show challenge)
    setState(() {
      _gamePhase = GamePhase.readyToSpin; // Reset for next turn
      _selectedPlayerIndex = null;
    });
  }

  // Helper function to build styled icon buttons (similar to home screen)
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
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
          backgroundColor: Colors.transparent, // Make button transparent
          foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(15),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(60, 60), // Square button
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: 30.0,
        ),
      ),
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

    return Scaffold(
      // ... existing AppBar ...
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 15, bottom: 15),
          child: GestureDetector(
            // Change onTap to navigate to home screen and clear stack
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (Route<dynamic> route) => false, // Remove all previous routes
            ),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 0, 0, 0), size: 20),
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
      body: Container(
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push elements apart
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

                  // --- Conditional Button Area ---
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: availableHeight * 0.03),
                    child: _buildInteractionArea(selectedPlayerName), // Use helper for buttons
                  ),
                  // --- End Conditional Button Area ---

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
                          () {
                            print("Scoreboard pressed");
                            // TODO: Navigate to Scoreboard screen or show dialog
                          },
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
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper widget to build the Spin or Truth/Dare buttons
  Widget _buildInteractionArea(String selectedPlayerName) {
    if (_gamePhase == GamePhase.awaitingTruthDare) {
      // Show Truth/Dare buttons
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$selectedPlayerName's Turn!",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                onPressed: _onTruthSelected,
                child: const Text('TRUTH'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
                onPressed: _onDareSelected,
                child: const Text('DARE'),
              ),
            ],
          ),
        ],
      );
    } else {
      // Show Spin button (only enable when ready)
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        // Disable button if not ready to spin
        onPressed: (_gamePhase == GamePhase.readyToSpin)
            ? () {
                // Add some randomness to the spin velocity
                final randomVelocity = 5000.0 + math.Random().nextDouble() * 5000.0;
                _startSpin(randomVelocity);
              }
            : null, // Disable onPressed if not ready
        child: (_gamePhase == GamePhase.spinning)
            ? const SizedBox( // Show spinner while spinning
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black54),
              )
            : const Text('SPIN'),
      );
    }
  }
}

// Ensure PlayerCircle accepts highlightedIndex
// (Need to check/update player_circle_painter.dart if necessary)
