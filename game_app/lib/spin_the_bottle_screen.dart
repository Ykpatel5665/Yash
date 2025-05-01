import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation
import 'package:flutter/physics.dart'; // Import for physics simulation

import 'main.dart'; // For AgeGroup enum
import 'player_circle_painter.dart'; // Import the player circle widget

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
        setState(() {
          _currentAngle = _animation?.value ?? _currentAngle;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Spin Logic ---
  void _startSpin(double velocity) {
    _controller.stop();

    // Adjust friction and velocity scaling for smoother spin
    final simulation = FrictionSimulation(
      0.3, // Lower friction for longer spin (previously 0.6)
      _currentAngle,
      velocity / 700, // Adjust velocity scaling (previously / 1000)
    );

    _animation = _controller.drive(Tween<double>(begin: _currentAngle, end: simulation.finalX));

    _controller.animateWith(simulation).whenCompleteOrCancel(() {
      // Optional: Snap to a final position or determine winner here
    });
  }

  // --- Gesture Handling ---
  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _startDragPos = details.localPosition;
    _startAngle = _currentAngle;
    // No need to reset _velocity here
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startDragPos == null) return;

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
    if (_startDragPos == null) return;

    // Use the primary velocity from the gesture detector
    // This is often more reliable, especially for flicks
    final double flickVelocity = details.primaryVelocity ?? 0.0;

    // Start the spin animation with the final velocity
    _startSpin(flickVelocity);
    _startDragPos = null; // Reset drag start position
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
              final double bottleHeight = circleDiameter * 0.6;

              // Calculate spacing in pixels
              final double topSpacing = availableHeight * topSpacingPercent;
              final double bottomSpacing = availableHeight * bottomSpacingPercent;
              final double buttonBottomPadding = availableHeight * buttonBottomPaddingPercent;
              final double buttonRowHorizontalPadding = availableWidth * 0.05;

              // Use Column for vertical spacing control
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push elements apart
                children: [
                  SizedBox(height: topSpacing), // Space below AppBar

                  // Wheel Stack (not centered anymore, positioned by Column)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Player Circle with responsive size
                      PlayerCircle(
                        players: widget.players,
                        size: circleDiameter,
                      ),

                      // Spinning Bottle with responsive size
                      Positioned(
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
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

                  // Spin Button
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: availableHeight * 0.03), // Add some vertical padding
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Match bottom bar button background
                        foregroundColor: Colors.black, // Match bottom bar button foreground
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.4),
                      ),
                      onPressed: () {
                        // Add some randomness to the spin velocity
                        final randomVelocity = 5000.0 + math.Random().nextDouble() * 5000.0;
                        _startSpin(randomVelocity);
                      },
                      child: const Text('SPIN'),
                    ),
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
}
