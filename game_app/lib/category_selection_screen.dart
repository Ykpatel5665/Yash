import 'services/question_db_service.dart';
import 'services/question_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'add_players_screen.dart';
import 'main.dart';
import 'dart:ui';
import 'widgets/buttons/toggle_button.dart';
import 'custom_appbar_button.dart';
import 'l10n/app_localizations.dart';
import 'widgets/headers/app_header.dart';
import 'utils/sound_manager.dart';
import 'models/category_model.dart';
// import 'services/category_api_service.dart';
import 'services/category_db_service.dart';
import 'utils/connectivity_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Static Category lists hatai didha, have dynamic fetch thase

class CategorySelectionScreen extends StatefulWidget {
  final GameMode gameMode;
  final AgeGroup ageGroup;
  final bool useTimer;
  final void Function(Locale) setLocale;
  final bool hapticsEnabled;
  const CategorySelectionScreen(
      {super.key,
      required this.gameMode,
      required this.ageGroup,
      required this.useTimer,
      required this.setLocale,
      required this.hapticsEnabled});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  Future<bool> _showNoInternetDialogForQuestions() async {
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogPadding = screenSize.width * 0.05;
    final BoxDecoration dialogDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 103, 58, 183),
          Color.fromARGB(255, 233, 30, 99),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.8),
        width: 3.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 6.0,
          spreadRadius: 1.0,
          offset: const Offset(0, 4),
        ),
      ],
    );
    final TextStyle titleStyle = TextStyle(
      fontFamily: 'Baloo2',
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withAlpha(60),
          offset: const Offset(1.0, 1.0),
        ),
      ],
    );
    final TextStyle contentStyle = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: 16,
      color: Colors.white.withOpacity(0.9),
    );
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Container(
              padding: EdgeInsets.all(dialogPadding),
              decoration: dialogDecoration,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Icon(Icons.wifi_off_rounded,
                          color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        'No Internet Connection',
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please check your internet connection and try again.',
                      style: contentStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.18),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: TextStyle(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result == true;
  }
  // List of adult category keys that require consent
  static const Set<String> _consentRequiredAdultCategories = {
    'Spicy & Flirty',
    'Adult Confessions',
    'Bedroom Secrets',
    'Naughty Dares',
    'Drunken Shenanigans',
  };

  bool _consentGiven = false;

  Future<bool> _showConsentDialog() async {
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogPadding = screenSize.width * 0.05;
    final BoxDecoration dialogDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 103, 58, 183), // Deep Purple
          Color.fromARGB(255, 233, 30, 99), // Pink
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.8),
        width: 3.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 6.0,
          spreadRadius: 1.0,
          offset: const Offset(0, 4),
        ),
      ],
    );
    final TextStyle titleStyle = GoogleFonts.baloo2(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withAlpha(60),
          offset: const Offset(1.0, 1.0),
        ),
      ],
    );
    final TextStyle contentStyle = GoogleFonts.baloo2(
      fontSize: 16,
      color: Colors.white.withOpacity(0.9),
    );
    final localizations = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext confirmDialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            padding: EdgeInsets.all(dialogPadding),
            decoration: dialogDecoration,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Text(
                      localizations.consentTitle, // Consent dialog title
                      style: titleStyle,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    localizations.consentWarning, // Consent warning
                    style: contentStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    localizations.consentQuestion, // Consent question
                    style: contentStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: Text(
                          localizations.cancel,
                          style: GoogleFonts.baloo2(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          Navigator.of(confirmDialogContext).pop(false);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 103, 58, 183),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          localizations.continueStr,
                          style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(confirmDialogContext).pop(true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }

  final Set<String> _selectedCategoryIds = {};
  Set<String> _lastPlayedCategoryIds = {};
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  /// Prefetches truth and dare questions for selected categories if not already in DB, using parallel API calls.
  Future<void> _prefetchQuestionsForSelectedCategories() async {
    while (true) {
      // Check for internet connection before fetching questions
      bool hasConnection = await ConnectivityHelper.hasInternetConnection();
      if (!hasConnection) {
        bool retry = await _showNoInternetDialogForQuestions();
        if (!retry) return;
        // If retry, loop and check again
        continue;
      }
      final dbService = QuestionDbService();
      final language = Localizations.localeOf(context).languageCode;
      // Map AgeGroup enum to correct API string
      String apiAgeGroup;
      switch (widget.ageGroup) {
        case AgeGroup.kids:
          apiAgeGroup = 'Kids';
          break;
        case AgeGroup.teen:
          apiAgeGroup = 'Teens';
          break;
        case AgeGroup.adult:
          apiAgeGroup = 'Adults';
          break;
      }

      List<Future<void>> futures = [];
      for (final catId in _selectedCategoryIds) {
        futures.add(
            _fetchAndInsertIfNeeded(dbService, apiAgeGroup, language, catId));
      }
      if (futures.isNotEmpty) {
        Fluttertoast.showToast(
          msg: 'Syncing...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        await Future.wait(futures);
      }
      break;
    }
  }

  Future<void> _fetchAndInsertIfNeeded(QuestionDbService dbService,
      String apiAgeGroup, String language, String catId) async {
    // Check for Truth questions
    final truthQuestions = await dbService.getQuestions(
      type: 'truth',
      selectedCategories: [catId],
      ageGroup: apiAgeGroup,
      language: language,
    );
    if (truthQuestions.isEmpty) {
      final truths = await QuestionApiService.fetchQuestions(
        ageGroup: apiAgeGroup,
        category: catId,
        language: language,
        type: 'truth',
      );
      if (truths.isNotEmpty) {
        await dbService.insertQuestions(truths);
      }
    }
    // Check for Dare questions
    final dareQuestions = await dbService.getQuestions(
      type: 'dare',
      selectedCategories: [catId],
      ageGroup: apiAgeGroup,
      language: language,
    );
    if (dareQuestions.isEmpty) {
      final dares = await QuestionApiService.fetchQuestions(
        ageGroup: apiAgeGroup,
        category: catId,
        language: language,
        type: 'dare',
      );
      if (dares.isNotEmpty) {
        await dbService.insertQuestions(dares);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // On first frame, check DB. If empty, check internet and fetch from API (show dialog if no internet). If not empty, just load from DB.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('[initState] CategorySelectionScreen loaded');
      setState(() { _isLoading = true; });
      await _loadLastPlayedCategories();
      await _fetchCategories();
      setState(() { _isLoading = false; });
      print('[initState] Done loading categories.');
    });
  }

  Future<void> _loadLastPlayedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'lastPlayedCategories_${widget.ageGroup.name}';
    final ids = prefs.getStringList(key);
    if (ids != null) {
      setState(() {
        _lastPlayedCategoryIds = ids.toSet();
        _selectedCategoryIds
            .addAll(_lastPlayedCategoryIds); // Preselect last played
      });
    }
  }

  Future<void> _saveLastPlayedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'lastPlayedCategories_${widget.ageGroup.name}';
    await prefs.setStringList(key, _selectedCategoryIds.toList());
  }

  Future<void> _fetchCategories() async {
    // Only fetch from DB, DB is always up-to-date from main.dart
    List<CategoryModel> dbCats = await CategoryDbService.getCategoriesByAgeGroup(widget.ageGroup.name);
    setState(() {
      _categories = dbCats;
    });
  }

  // Use emoji from API for category icon

  // --- Game Setup Dialog Style Toggle Button (copied from main.dart) ---
  Widget buildCategoryToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
    Color? selectedColor,
    Color? unselectedColor,
    double? iconSize,
    double? fontSize,
  }) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.92 / 2.2;
    final double maxCardWidth = 420 / 2.2;
    final double cardPadding = 14.0;
    final double effectiveIconSize = iconSize ?? 32;
    final double effectiveFontSize = fontSize ?? 18;
    final Color defaultSelectedColor =
        const Color(0xFF5B86E5).withOpacity(0.25);
    final Color defaultUnselectedColor = Colors.white.withOpacity(0.13);
    final Color borderColor =
        selected ? (selectedColor ?? defaultSelectedColor) : Colors.transparent;
    final Color bgColor = selected
        ? (selectedColor ?? defaultSelectedColor)
        : (unselectedColor ?? defaultUnselectedColor);
    final Color textColor =
        selected ? Colors.white : Colors.white.withOpacity(0.92);
    final Color iconColor =
        selected ? Colors.white : Colors.white.withOpacity(0.92);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
      padding: EdgeInsets.symmetric(
          vertical: cardPadding, horizontal: cardPadding + 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: selected ? 2.2 : 1.2,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: (selectedColor ?? defaultSelectedColor).withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: effectiveIconSize),
            const SizedBox(width: 14),
            Expanded(
              child: AutoSizeText(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
                minFontSize: 8,
                maxLines: 2,
                overflow: TextOverflow.visible,
                stepGranularity: 0.5,
                wrapWords: true,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? const Icon(Icons.check_circle,
                      color: Colors.white, size: 24, key: ValueKey('check'))
                  : const SizedBox(width: 24, key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double appBarHeight =
        (size.height * 0.12).clamp(64, 120); // Responsive
    final double continueBtnHeight =
        (size.height * 0.08).clamp(48, 70); // Responsive
    final double bottomPadding =
        (size.height * 0.09).clamp(48, 90); // replaces 69
    final double continueFontSize = (size.width * 0.06).clamp(18, 28);

    // Removed _categoryKeyToArbKey: no longer needed after switching to API labels only

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(
        title: AppLocalizations.of(context)!.selectCategory,
        centerTitle: true,
        leading: CustomAppBarButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: appBarHeight,
      ),
      body: Stack(
        children: [
          // Bold, high-energy sunset background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 252, 118, 84), // Sunset Coral
                  Color.fromARGB(255, 245, 64, 100), // Reddish Pink
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Glassmorphism overlay (keep, but lighter if needed)
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  boxShadow: [],
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                              builder: (context, constraints) {
                                Widget categoryList = Padding(
                                  padding: EdgeInsets.only(
                                    top: (MediaQuery.of(context).size.height *
                                            0.012)
                                        .clamp(4, 16),
                                    left: (MediaQuery.of(context).size.width *
                                            0.07)
                                        .clamp(18, 36),
                                    right: (MediaQuery.of(context).size.width *
                                            0.07)
                                        .clamp(18, 36),
                                    // Only a little extra space so last item is visible above the button
                                    bottom:
                                        bottomPadding + continueBtnHeight * 0.5,
                                  ),
                                  child: ListView.builder(
                                    itemCount: _categories.length +
                                        1, // Add one for the extra space
                                    itemBuilder: (context, idx) {
                                      if (idx == _categories.length) {
                                        // Add extra space at the end
                                        return const SizedBox(height: 32);
                                      }
                                      final cat = _categories[idx];
                                      final bool selected = _selectedCategoryIds
                                          .contains(cat.key);
                                      // Use only API's labels and emoji for multilingual support
                                      final localeCode = Localizations.localeOf(context).languageCode;
                                      final label = cat.labels[localeCode] ?? cat.labels['en'] ?? cat.key;
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: (MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.012)
                                                    .clamp(4, 16) /
                                                2),
                                        child: ToggleButton(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(cat.emoji, style: TextStyle(fontSize: (MediaQuery.of(context).size.width * 0.06).clamp(16, 26))),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: Text(label,
                                                    overflow: TextOverflow.visible,
                                                    style: GoogleFonts.baloo2(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: (MediaQuery.of(context).size.width * 0.06).clamp(16, 26),
                                                      color: selected ? Colors.white : Colors.white.withOpacity(0.92),
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                            ],
                                          ),
                                          selected: selected,
                                          onTap: () {
                                            setState(() {
                                              if (selected) {
                                                _selectedCategoryIds.remove(cat.key);
                                              } else {
                                                _selectedCategoryIds.add(cat.key);
                                              }
                                            });
                                          },
                                          icon: null,
                                          iconSize: 0,
                                          fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06)
                                              .clamp(16, 26),
                                        ),
                                      );
// ...existing code...
                                    },
                                  ),
                                );
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: categoryList,
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                bottomPadding), // Responsive
                                        child: Center(
                                          child: Container(
                                            width: (size.width * 0.75)
                                                .clamp(220, 420), // Responsive
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                      (0.3 * 255).round()),
                                                  blurRadius: 10.0,
                                                  spreadRadius: 1.0,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: _AnimatedButton(
                                              enabled: _selectedCategoryIds
                                                  .isNotEmpty,
                                              onTap: _selectedCategoryIds.isEmpty
                                                  ? null
                                                  : () async {
                                                      // Check if any selected category requires consent
                                                      final needsConsent = _selectedCategoryIds.any((id) => _consentRequiredAdultCategories.contains(id));
                                                      if (needsConsent && !_consentGiven) {
                                                        final consent = await _showConsentDialog();
                                                        if (!consent) return;
                                                        setState(() {
                                                          _consentGiven = true;
                                                        });
                                                      }
                                                      await _saveLastPlayedCategories();
                                                      await _prefetchQuestionsForSelectedCategories();
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation,
                                                                  secondaryAnimation) =>
                                                              AddPlayersScreen(
                                                            gameMode:
                                                                widget.gameMode,
                                                            ageGroup:
                                                                widget.ageGroup,
                                                            selectedCategoryIds:
                                                                _selectedCategoryIds
                                                                    .toList(),
                                                            useTimer:
                                                                widget.useTimer,
                                                            setLocale: widget
                                                                .setLocale,
                                                            hapticsEnabled: widget
                                                                .hapticsEnabled,
                                                          ),
                                                          transitionsBuilder:
                                                              (context,
                                                                  animation,
                                                                  secondaryAnimation,
                                                                  child) {
                                                            const begin =
                                                                Offset(
                                                                    1.0, 0.0);
                                                            const end =
                                                                Offset.zero;
                                                            const curve = Curves
                                                                .easeOutCubic;
                                                            final tween = Tween(
                                                                    begin:
                                                                        begin,
                                                                    end: end)
                                                                .chain(CurveTween(
                                                                    curve:
                                                                        curve));
                                                            final offsetAnimation =
                                                                animation.drive(
                                                                    tween);
                                                            return SlideTransition(
                                                              position:
                                                                  offsetAnimation,
                                                              child: child,
                                                            );
                                                          },
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      400),
                                                        ),
                                                      );
                                                    },
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                  minimumSize: Size(
                                                      (size.width * 0.75)
                                                          .clamp(220, 420),
                                                      continueBtnHeight), // Responsive
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: (size.height *
                                                              0.014)
                                                          .clamp(8,
                                                              18)), // Responsive
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  elevation: 0,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  textStyle: GoogleFonts.baloo2(
                                                    fontSize:
                                                        continueFontSize, // Responsive
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: _selectedCategoryIds.isEmpty
                                                    ? null
                                                    : () async {
                                                        // Check if any selected category requires consent
                                                        final needsConsent = _selectedCategoryIds.any((id) => _consentRequiredAdultCategories.contains(id));
                                                        if (needsConsent && !_consentGiven) {
                                                          final consent = await _showConsentDialog();
                                                          if (!consent) return;
                                                          setState(() {
                                                            _consentGiven = true;
                                                          });
                                                        }
                                                        SoundManager.playButtonSound(context: context);
                                                        await _saveLastPlayedCategories();
                                                        await _prefetchQuestionsForSelectedCategories();
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                AddPlayersScreen(
                                                              gameMode: widget.gameMode,
                                                              ageGroup: widget.ageGroup,
                                                              selectedCategoryIds: _selectedCategoryIds.toList(),
                                                              useTimer: widget.useTimer,
                                                              setLocale: widget.setLocale,
                                                              hapticsEnabled: widget.hapticsEnabled,
                                                            ),
                                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                              const begin = Offset(1.0, 0.0);
                                                              const end = Offset.zero;
                                                              const curve = Curves.easeOutCubic;
                                                              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                              final offsetAnimation = animation.drive(tween);
                                                              return SlideTransition(
                                                                position: offsetAnimation,
                                                                child: child,
                                                              );
                                                            },
                                                            transitionDuration: const Duration(milliseconds: 400),
                                                          ),
                                                        );
                                                      },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .continueBtn,
                                                        style:
                                                            GoogleFonts.baloo2(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              continueFontSize,
                                                          color: Colors.white,
                                                          shadows: [
                                                            Shadow(
                                                              blurRadius: 8,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.25),
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
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
                                    ),
                                  ],
                                );
                              },
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _AnimatedCategoryCard: Old Category type removed. Use CategoryModel if needed in future.

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;
  const _AnimatedButton(
      {required this.child,
      required this.enabled,
      required this.onTap,
      Key? key})
      : super(key: key);
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 1,
        upperBound: 1.07);
    _scaleAnim = _controller.drive(Tween(begin: 1.0, end: 1.07));
  }

  void _onTapDown(_) {
    if (widget.enabled) _controller.forward();
  }

  void _onTapUp(_) {
    if (widget.enabled) _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.child,
      ),
    );
  }
}
