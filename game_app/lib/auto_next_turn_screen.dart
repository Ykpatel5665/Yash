import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'truth_dare_data.dart';
import 'truth_dare_question_screen.dart';
import 'services/question_db_service.dart';
import 'main.dart'; // For AgeGroup enum
import 'widgets/cards/game_card.dart';
import 'custom_appbar_button.dart';
import 'player_circle_painter.dart';
import 'l10n/app_localizations.dart';
import 'widgets/headers/app_header.dart';
import 'dart:math' as math; // Import math for random selection
import 'utils/sound_manager.dart'; // Import SoundManager
import 'package:provider/provider.dart';
import 'providers/sound_provider.dart';
// Platform-safe import for SmartBanner
import 'smart_banner_mobile.dart' if (dart.library.html) 'smart_banner_stub.dart';

// Shared dialog constants and helpers (copied from random_turn_screen.dart)
const double kMaxCardWidth = 420.0;
double getResponsiveCardPadding(double screenWidth) =>
    (screenWidth * 0.06).clamp(16, 32);

// Convert to StatefulWidget for turn management
class AutoNextTurnScreen extends StatefulWidget {
  final List<String> players;
  final AgeGroup ageGroup;
  final List<String> selectedCategoryIds;
  final bool useTimer;
  final bool hapticsEnabled;
  final void Function(bool)? onHapticsChanged;

  const AutoNextTurnScreen({
    super.key,
    required this.players,
    required this.ageGroup,
    required this.selectedCategoryIds,
    required this.useTimer,
    required this.hapticsEnabled,
    this.onHapticsChanged,
  });

  @override
  State<AutoNextTurnScreen> createState() => _AutoNextTurnScreenState();
}

class _AutoNextTurnScreenState extends State<AutoNextTurnScreen> {
  // Interstitial Ad logic
  InterstitialAd? _interstitialAd;
  int _roundsSinceLastAd = 0;
  bool _isInterstitialLoading = false;
  static const String _interstitialAdUnitId = 'ca-app-pub-9458331875641856/3827341528';
  int _currentIndex = 0;
  bool _lastPlayerFinished = false; // Track if last player finished
  Map<String, int> _playerScores = {};
  bool _scoreboardOpen = false;
  // Removed _pendingShowTruthDare logic: dialog only appears after Start button
  bool _quitDialogOpen = false; // Track if quit confirmation dialog is open
  bool _hasQuit = false; // Track if user has quit to prevent dialog on home

  int _pendingHighlightIndex = -1; // For transition animation
  bool _isAnimatingHighlight = false;
  late List<Color> _playerColors;
  bool _gameStarted = false; // Used for animation/transition only
  bool _autoTurnTimerActive = false; // Track if auto timer is running
  bool _pendingAutoTurn = false; // Track if auto turn is pending due to interruption

  @override
  void initState() {
    super.initState();
    for (final player in widget.players) {
      _playerScores[player] = 0;
    }
    _playerColors = PlayerCirclePainter.shuffleColors();
    _gameStarted = false;
    _loadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAutoNextTurn();
    });
  }

  void _triggerAutoNextTurn() {
    if (_lastPlayerFinished || _autoTurnTimerActive) return;
    if (_scoreboardOpen || _quitDialogOpen || _hasQuit) {
      _pendingAutoTurn = true;
      return;
    }
    setState(() {
      _gameStarted = false;
      _autoTurnTimerActive = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _lastPlayerFinished) {
        setState(() {
          _autoTurnTimerActive = false;
        });
        return;
      }
      if (_scoreboardOpen || _quitDialogOpen || _hasQuit) {
        _pendingAutoTurn = true;
        setState(() {
          _autoTurnTimerActive = false;
        });
        return;
      }
      setState(() {
        _gameStarted = true;
        _autoTurnTimerActive = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_lastPlayerFinished && !_scoreboardOpen && !_quitDialogOpen && !_hasQuit) {
          _showTruthOrDareDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    if (_isInterstitialLoading) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void _showInterstitialAdIfReady(VoidCallback onContinue) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onContinue();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onContinue();
        },
      );
      _interstitialAd!.show();
    } else {
      _loadInterstitialAd();
      onContinue();
    }
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
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted || _hasQuit) return;
        setState(() {
          _currentIndex = _pendingHighlightIndex;
          _isAnimatingHighlight = false;
          _gameStarted = false;
        });
        // After transition, trigger auto next turn for next player
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerAutoNextTurn();
        });
      });
    }
  }

  Future<Question?> _getRandomQuestionFromJson({required String type}) async {
    final language = Localizations.localeOf(context).languageCode;
    final questions = await loadQuestions(
      type: type,
      selectedCategories: widget.selectedCategoryIds,
      ageGroup: widget.ageGroup.name == 'kids'
          ? 'Kids'
          : widget.ageGroup.name == 'teen'
              ? 'Teens'
              : 'Adults',
      language: language,
    );
    if (questions.isEmpty) return null;
    questions.shuffle();
    final question = questions.first;
    // Increment attempt in DB
    try {
      final dbService = QuestionDbService();
      await dbService.incrementAttempt(question.text);
    } catch (_) {}
    return question;
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
              _roundsSinceLastAd = (_roundsSinceLastAd + 1) % 3;
            });
            if (_roundsSinceLastAd == 0) {
              _showInterstitialAdIfReady(() {
                setState(() {
                  _nextTurn();
                });
              });
            } else {
              setState(() {
                _nextTurn();
              });
            }
          },
          onForfeit: () {
            Navigator.of(context).pop();
            setState(() {
              _roundsSinceLastAd = (_roundsSinceLastAd + 1) % 3;
            });
            if (_roundsSinceLastAd == 0) {
              _showInterstitialAdIfReady(() {
                setState(() {
                  _nextTurn();
                });
              });
            } else {
              setState(() {
                _nextTurn();
              });
            }
          },
          useTimer: widget.useTimer,
        ),
      ),
    );
  // After question screen, auto next turn will be triggered by _nextTurn logic
  }

  void _showScoreboardDialog() async {
    setState(() {
      _scoreboardOpen = true;
    });
    await showDialog(
      context: context,
      barrierDismissible: true,
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
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSizeText(
                        localizations.scoreboard,
                        style: TextStyle(
                          fontFamily: 'Baloo2',
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
                                        style: TextStyle(
                                          fontFamily: 'Baloo2',
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
                                          style: TextStyle(
                                            fontFamily: 'Baloo2',
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
                      SizedBox(height: (screenSize.height * 0.09).clamp(40, 80)),
                    ],
                  ),
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
                            textStyle: TextStyle(
                              fontFamily: 'Baloo2',
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              localizations.close,
                              style: TextStyle(
                                fontFamily: 'Baloo2',
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
    // Resume auto turn if pending
    if (mounted && _pendingAutoTurn && !_scoreboardOpen && !_quitDialogOpen && !_lastPlayerFinished) {
      _pendingAutoTurn = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scoreboardOpen && !_quitDialogOpen && !_lastPlayerFinished) {
          _triggerAutoNextTurn();
        }
      });
    }
  }

  Future<bool> _showQuitConfirmation() async {
    _quitDialogOpen = true;
    final Size screenSize = MediaQuery.of(context).size;
    final result = await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (dialogContext, animation, secondaryAnimation) {
            final double cardWidth = screenSize.width * 0.92;
            final double maxCardWidth = kMaxCardWidth;
            final double cardPadding =
                getResponsiveCardPadding(screenSize.width); // Responsive
            final double titleFontSize =
                (screenSize.width * 0.08).clamp(24, 36);
            final double iconSize = (screenSize.width * 0.14).clamp(36, 60);
            final double messageFontSize =
                (screenSize.width * 0.05).clamp(15, 22);
            final double buttonFontSize =
                (screenSize.width * 0.055).clamp(16, 22);
            final double buttonSpacing =
                (screenSize.width * 0.045).clamp(10, 22);
            final double sectionSpacing =
                (screenSize.height * 0.03).clamp(14, 32);
            final double buttonRowSpacing =
                (screenSize.height * 0.04).clamp(18, 40);
            final double buttonVerticalPadding =
                (screenSize.height * 0.022).clamp(12, 28);
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                    child: Container(
                      width:
                          cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
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
                            style: TextStyle(
                              fontFamily: 'Baloo2',
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
                                color:
                                    Colors.black.withAlpha((0.4 * 255).round()),
                                offset: const Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          SizedBox(height: sectionSpacing),
                          Text(
                            AppLocalizations.of(context)!.quitGameMessage,
                            style: TextStyle(
                              fontFamily: 'Baloo2',
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: buttonVerticalPadding),
                                      minimumSize: const Size(0, 48),
                                      textStyle: TextStyle(
                                        fontFamily: 'Baloo2',
                                        fontWeight: FontWeight.w800,
                                        fontSize: buttonFontSize,
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.no,
                                      style: TextStyle(
                                        fontFamily: 'Baloo2',
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w800,
                                        fontSize: buttonFontSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: buttonSpacing),
                               // Only the new ElevatedButton for 'Yes' remains
                               Expanded(
                                 child: ElevatedButton(
                                   onPressed: () {
                                     SoundManager.playButtonSound(context: context);
                                     Navigator.of(dialogContext).pop(true);
                                   },
                                   style: ElevatedButton.styleFrom(
                                     elevation: 0,
                                     backgroundColor: Colors.transparent, // 
                                     shadowColor: Colors.transparent,
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(16),
                                     ),
                                     padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                                     minimumSize: const Size(0, 40), // Reduced height
                                     textStyle: TextStyle(
                                       fontFamily: 'Baloo2',
                                       fontWeight: FontWeight.w600,
                                       fontSize: buttonFontSize,
                                     ),
                                   ),
                                   child: Text(
                                     AppLocalizations.of(context)!.yes,
                                     style: TextStyle(
                                       fontFamily: 'Baloo2',
                                       color: Colors.white.withOpacity(0.7),
                                       fontWeight: FontWeight.w600,
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
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ) ??
        false;
    _quitDialogOpen = false;
    if (result) {
      _hasQuit = true;
    }
    // Resume auto turn if pending
    if (mounted && _pendingAutoTurn && !_scoreboardOpen && !_quitDialogOpen && !_lastPlayerFinished) {
      _pendingAutoTurn = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scoreboardOpen && !_quitDialogOpen && !_lastPlayerFinished) {
          _triggerAutoNextTurn();
        }
      });
    }
    return result ?? false;
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

  Future<void> _showTruthOrDareDialog() async {
    if (_scoreboardOpen || _quitDialogOpen || _hasQuit) {
      return; // Prevent dialog if scoreboard or quit dialog is open or user has quit
    }
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
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
    if (_hasQuit) return;
    if (result == 'truth') {
      await _showTruthOrDareScreen(true);
    } else if (result == 'dare') {
      await _showTruthOrDareScreen(false);
    }
  }

  @override
  void deactivate() {
    // Prevent dialog from showing if navigating away (e.g., Home pressed)
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldQuit = await _showQuitConfirmation();
        if (shouldQuit) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(setLocale: (locale) {})),
            (Route<dynamic> route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppHeader(
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
          toolbarHeight:
              (MediaQuery.of(context).size.height * 0.12).clamp(64, 120),
          actions: null,
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
                    final double bottomPadding = constraints.maxHeight * 0.04;
                    final double horizontalPadding = constraints.maxWidth * 0.07;
                    final double spacingLarge = (constraints.maxHeight * 0.06).clamp(24, 60);
                    final double screenWidth = constraints.maxWidth;
                    final double screenHeight = constraints.maxHeight;
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PlayerCircle(
                                  players: widget.players,
                                  size: (screenWidth * 0.7).clamp(
                                    math.min(220.0, screenHeight * 0.55),
                                    math.max(220.0, screenHeight * 0.55),
                                  ),
                                  highlightedIndex: _isAnimatingHighlight ? _pendingHighlightIndex : _currentIndex,
                                  animated: true,
                                  animationDuration: const Duration(milliseconds: 1800),
                                  previousIndex: _isAnimatingHighlight ? _currentIndex : null,
                                  colors: _playerColors,
                                ),
                                // Start button removed for auto next turn
                              ],
                            ),
                          ),
                        ),
                        if (_lastPlayerFinished) ...[
                          Padding(
                            padding: EdgeInsets.only(top: spacingLarge),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    SoundManager.playButtonSound(context: context);
                                    setState(() {
                                      _currentIndex = 0;
                                      _lastPlayerFinished = false;
                                      _playerColors = PlayerCirclePainter.shuffleColors();
                                      _hasQuit = false; // Reset quit flag on restart
                                      _gameStarted = false;
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _triggerAutoNextTurn();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (screenWidth * 0.18).clamp(32, 60),
                                      vertical: (screenHeight * 0.025).clamp(14, 28),
                                    ),
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: (screenWidth * 0.045).clamp(15, 22),
                                      color: Colors.white,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: AutoSizeText(
                                    AppLocalizations.of(context)!.restart,
                                    minFontSize: 10,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                    wrapWords: false,
                                    style: TextStyle(
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
                            ),
                          ),
                        ],
                        // Bottom buttons row
                        Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: bottomPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<SoundProvider>(
                                builder: (context, soundProvider, child) =>
                                    _buildIconButton(
                                  soundProvider.isSoundOn
                                      ? Icons.volume_up
                                      : Icons.volume_off,
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
                                  if (widget.hapticsEnabled) SoundManager.playButtonSound(context: context);
                                  _showScoreboardDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const SmartBanner(),
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
      textStyle: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
    TextStyle buttonTextStyle = TextStyle(
      fontFamily: 'Baloo2',
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
                    style: TextStyle(
                      fontFamily: 'Baloo2',
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
                    style: TextStyle(
                      fontFamily: 'Baloo2',
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
                              SoundManager.playButtonSound(context: context);
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
                        SoundManager.playButtonSound(context: context);
                        final random = math.Random();
                        final isTruth = random.nextBool();
                        Navigator.of(context).pop(isTruth ? 'truth' : 'dare');
                      },
                      child: Text(
                        AppLocalizations.of(context)!.chooseRandomBtn,
                        style: TextStyle(
                          fontFamily: 'Baloo2',
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
    ); // <-- Properly close all widgets
  }
}
