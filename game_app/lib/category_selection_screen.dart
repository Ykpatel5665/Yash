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
import 'services/category_api_service.dart';
import 'services/category_db_service.dart';

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
  final Set<String> _selectedCategoryIds = {};
  Set<String> _lastPlayedCategoryIds = {};
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLastPlayedCategories();
    _fetchCategories();
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Try DB first
      List<CategoryModel> dbCats =
          await CategoryDbService.getCategoriesByAgeGroup(widget.ageGroup.name);
      // ...existing code...
      if (dbCats.isNotEmpty) {
        setState(() {
          _categories = dbCats;
          _loading = false;
        });
        return;
      }
      // Only fetch from API if DB is empty
      List<CategoryModel> apiCats = await CategoryApiService.fetchCategories();
      // ...existing code...
      // Store all categories in DB (no filter, no delete)
      await CategoryDbService.insertCategories(apiCats);
      // ...existing code...
      // Map enum to API age group string
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
      // Now filter for current age group
      final filtered = apiCats.where((c) => c.ageGroup == apiAgeGroup).toList();
      // ...existing code...
      setState(() {
        _categories = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Map category key to icon (simple mapping, fallback to default)
  IconData getCategoryIcon(String key) {
    switch (key) {
      case 'Funny & Silly':
        return Icons.emoji_emotions;
      case 'Cartoons & Characters':
        return Icons.animation;
      case 'Animals & Sounds':
        return Icons.pets;
      case 'Superheroes & Powers':
        return Icons.flash_on;
      case 'Sing & Dance':
        return Icons.music_video;
      case 'School & Friends':
        return Icons.school;
      case 'Food & Snacks':
        return Icons.fastfood;
      case 'Family Time':
        return Icons.family_restroom;
      case 'Make Believe':
        return Icons.auto_fix_high;
      case 'Adventure & Travel':
        return Icons.travel_explore;
      case 'Love & Crushes':
        return Icons.favorite;
      case 'School Life':
        return Icons.menu_book;
      case 'Embarrassing Moments':
        return Icons.sentiment_very_dissatisfied;
      case 'Phone & Social Media':
        return Icons.phone_iphone;
      case 'Friends & Drama':
        return Icons.groups;
      case 'Family & Home':
        return Icons.home;
      case 'Dreams & Goals':
        return Icons.auto_awesome;
      case 'Music & Movies':
        return Icons.movie;
      case 'Random Fun':
        return Icons.casino;
      case 'Quick Challenges':
        return Icons.flash_auto;
      case 'Dating & Flirting':
        return Icons.favorite_border;
      case 'Work & Office':
        return Icons.work;
      case 'Embarrassing Stories':
        return Icons.mood_bad;
      case 'Secrets & Lies':
        return Icons.lock;
      case 'Relationships':
        return Icons.volunteer_activism;
      case 'Deep Thoughts':
        return Icons.psychology;
      case 'Life Experiences':
        return Icons.public;
      case 'Wild Dares':
        return Icons.whatshot;
      case 'Party Mode':
        return Icons.celebration;
      case 'Spicy & Flirty':
        return Icons.local_fire_department;
      case 'Adult Confessions':
        return Icons.wine_bar;
      case 'Bedroom Secrets':
        return Icons.bed;
      case 'Naughty Dares':
        return Icons.mood;
      case 'Drunken Shenanigans':
        return Icons.sports_bar;
      default:
        return Icons.category;
    }
  }

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

    // Helper to map category key to ARB key
    String? _categoryKeyToArbKey(String key) {
      switch (key) {
        case 'Funny & Silly':
          return 'categoryFunnySilly';
        case 'Cartoons & Characters':
          return 'categoryCartoonsCharacters';
        case 'Animals & Sounds':
          return 'categoryAnimalsSounds';
        case 'Superheroes & Powers':
          return 'categorySuperheroesPowers';
        case 'Sing & Dance':
          return 'categorySingDance';
        case 'School & Friends':
          return 'categorySchoolFriends';
        case 'Food & Snacks':
          return 'categoryFoodSnacks';
        case 'Family Time':
          return 'categoryFamilyTime';
        case 'Make Believe':
          return 'categoryMakeBelieve';
        case 'Adventure & Travel':
          return 'categoryAdventureTravel';
        case 'Love & Crushes':
          return 'categoryLoveCrushes';
        case 'School Life':
          return 'categorySchoolLife';
        case 'Embarrassing Moments':
          return 'categoryEmbarrassingMoments';
        case 'Phone & Social Media':
          return 'categoryPhoneSocialMedia';
        case 'Friends & Drama':
          return 'categoryFriendsDrama';
        case 'Family & Home':
          return 'categoryFamilyHome';
        case 'Dreams & Goals':
          return 'categoryDreamsGoals';
        case 'Music & Movies':
          return 'categoryMusicMovies';
        case 'Random Fun':
          return 'categoryRandomFun';
        case 'Quick Challenges':
          return 'categoryQuickChallenges';
        case 'Dating & Flirting':
          return 'categoryDatingFlirting';
        case 'Work & Office':
          return 'categoryWorkOffice';
        case 'Embarrassing Stories':
          return 'categoryEmbarrassingStories';
        case 'Secrets & Lies':
          return 'categorySecretsLies';
        case 'Relationships':
          return 'categoryRelationships';
        case 'Deep Thoughts':
          return 'categoryDeepThoughts';
        case 'Life Experiences':
          return 'categoryLifeExperiences';
        case 'Wild Dares':
          return 'categoryWildDares';
        case 'Party Mode':
          return 'categoryPartyMode';
        case 'Spicy & Flirty':
          return 'categorySpicyFlirty';
        case 'Adult Confessions':
          return 'categoryAdultConfessions';
        case 'Bedroom Secrets':
          return 'categoryBedroomSecrets';
        case 'Naughty Dares':
          return 'categoryNaughtyDares';
        case 'Drunken Shenanigans':
          return 'categoryDrunkenShenanigans';
        default:
          return null;
      }
    }

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
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(child: Text('Error: \\$_error'))
                          : LayoutBuilder(
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
                                      final iconData = getCategoryIcon(cat.key);
                                      // Use localized label from ARB if available, else fallback to current locale, else English, else key
                                      String? localizedLabel;
                                      final localeCode =
                                          Localizations.localeOf(context)
                                              .languageCode;
                                      final arbKey =
                                          _categoryKeyToArbKey(cat.key);
                                      if (arbKey != null) {
                                        final loc =
                                            AppLocalizations.of(context)!;
                                        // Use a safer approach: check if the property exists
                                        try {
                                          final value =
                                              (loc as dynamic).toJson()[arbKey];
                                          if (value is String)
                                            localizedLabel = value;
                                        } catch (_) {}
                                      }
                                      localizedLabel ??=
                                          cat.labels[localeCode] ??
                                              cat.labels['en'] ??
                                              cat.key;
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: (MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.012)
                                                    .clamp(4, 16) /
                                                2),
                                        child: ToggleButton(
                                          label: localizedLabel,
                                          selected: selected,
                                          onTap: () {
                                            setState(() {
                                              if (selected) {
                                                _selectedCategoryIds
                                                    .remove(cat.key);
                                              } else {
                                                _selectedCategoryIds
                                                    .add(cat.key);
                                              }
                                            });
                                          },
                                          icon: iconData,
                                          iconSize: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.08)
                                              .clamp(26, 36),
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
                                              onTap: _selectedCategoryIds
                                                      .isEmpty
                                                  ? null
                                                  : () async {
                                                      await _saveLastPlayedCategories();
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
                                                onPressed: _selectedCategoryIds
                                                        .isEmpty
                                                    ? null
                                                    : () async {
                                                        SoundManager
                                                            .playButtonSound(
                                                                context:
                                                                    context);
                                                        await _saveLastPlayedCategories();
                                                        Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context,
                                                                    animation,
                                                                    secondaryAnimation) =>
                                                                AddPlayersScreen(
                                                              gameMode: widget
                                                                  .gameMode,
                                                              ageGroup: widget
                                                                  .ageGroup,
                                                              selectedCategoryIds:
                                                                  _selectedCategoryIds
                                                                      .toList(),
                                                              useTimer: widget
                                                                  .useTimer,
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
                                                                  animation
                                                                      .drive(
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


