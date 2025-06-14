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

class Category {
  final String id;
  final String name;
  final String desc;
  const Category({required this.id, required this.name, required this.desc});
}

// Category lists by age group
const List<Category> kidsCategories = [
  Category(id: 'KIDS_FUNNY', name: 'Funny', desc: 'Jokes and silly actions'),
  Category(id: 'KIDS_FAMILY', name: 'Family', desc: 'About parents and friends'),
  Category(id: 'KIDS_SCHOOL', name: 'School', desc: 'Teachers and classmates'),
  Category(id: 'KIDS_CARTOONS', name: 'Cartoons', desc: 'Favorite shows and toys'),
  Category(id: 'KIDS_GAMES', name: 'Games', desc: 'Outdoor and video games'),
  Category(id: 'KIDS_ANIMALS', name: 'Animals', desc: 'Pets and nature'),
  Category(id: 'KIDS_FOOD', name: 'Food', desc: 'Snacks and weird combos'),
  Category(id: 'KIDS_IMAGINATION', name: 'Dream', desc: 'If you were a wizard...'),
  Category(id: 'KIDS_CHALLENGES', name: 'Challenges', desc: 'Do 10 jumping jacks'),
  Category(id: 'KIDS_HOBBIES', name: 'Hobbies', desc: 'Drawing and puzzles'),
];

const List<Category> teensCategories = [
  Category(id: 'TEENS_FRIENDS', name: 'Friends', desc: 'Crushes and besties'),
  Category(id: 'TEENS_SCHOOL', name: 'School', desc: 'Study and exams'),
  Category(id: 'TEENS_MUSIC', name: 'Music', desc: 'Favorite artists'),
  Category(id: 'TEENS_MOVIES', name: 'Movies', desc: 'Netflix and actors'),
  Category(id: 'TEENS_TECH', name: 'Tech', desc: 'Social media and memes'),
  Category(id: 'TEENS_HOBBIES', name: 'Hobbies', desc: 'Sports and art'),
  Category(id: 'TEENS_DREAMS', name: 'Dreams', desc: 'Career and college'),
  Category(id: 'TEENS_EMBARRASSING', name: 'Embarrassing', desc: 'Awkward moments'),
  Category(id: 'TEENS_STYLE', name: 'Style', desc: 'Outfits and icons'),
  Category(id: 'TEENS_ADVENTURE', name: 'Travel', desc: 'Trips and destinations'),
];

const List<Category> adultsCategories = [
  Category(id: 'ADULTS_RELATIONSHIPS', name: 'Love', desc: 'Dating and flirting'),
  Category(id: 'ADULTS_PARTY', name: 'Party', desc: 'Nightlife and dares'),
  Category(id: 'ADULTS_WORK', name: 'Work', desc: 'Office and stress'),
  Category(id: 'ADULTS_TRAVEL', name: 'Travel', desc: 'Trips and memories'),
  Category(id: 'ADULTS_DEEP', name: 'Deep', desc: 'Fears and thoughts'),
  Category(id: 'ADULTS_WILD', name: 'Wild', desc: 'Funny dares'),
  Category(id: 'ADULTS_FLIRTY', name: 'Flirty', desc: 'Teasing and romance'),
  Category(id: 'ADULTS_CHILDHOOD', name: 'Childhood', desc: 'Old stories'),
  Category(id: 'ADULTS_POPCULTURE', name: 'Pop', desc: 'Celebs and trivia'),
  Category(id: 'ADULTS_PERSONAL', name: 'Growth', desc: 'Goals and habits'),
];

class CategorySelectionScreen extends StatefulWidget {
  final GameMode gameMode;
  final AgeGroup ageGroup;
  final bool useTimer;
  final void Function(Locale) setLocale;
  final bool hapticsEnabled;
  const CategorySelectionScreen({super.key, required this.gameMode, required this.ageGroup, required this.useTimer, required this.setLocale, required this.hapticsEnabled});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final Set<String> _selectedCategoryIds = {};
  Set<String> _lastPlayedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadLastPlayedCategories();
  }

  Future<void> _loadLastPlayedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'lastPlayedCategories_${widget.ageGroup.name}';
    final ids = prefs.getStringList(key);
    if (ids != null) {
      setState(() {
        _lastPlayedCategoryIds = ids.toSet();
        _selectedCategoryIds.addAll(_lastPlayedCategoryIds); // Preselect last played
      });
    }
  }

  Future<void> _saveLastPlayedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'lastPlayedCategories_${widget.ageGroup.name}';
    await prefs.setStringList(key, _selectedCategoryIds.toList());
  }

  List<Category> get _categories {
    switch (widget.ageGroup) {
      case AgeGroup.kids:
        return kidsCategories;
      case AgeGroup.teen:
        return teensCategories;
      case AgeGroup.adult:
        return adultsCategories;
    }
  }

  // Map category IDs to Material/FontAwesome icons
  IconData getCategoryIcon(String id) {
    switch (id) {
      case 'KIDS_FUNNY':
        return Icons.emoji_emotions;
      case 'KIDS_FAMILY':
        return Icons.family_restroom;
      case 'KIDS_SCHOOL':
        return Icons.school;
      case 'KIDS_CARTOONS':
        return Icons.tv;
      case 'KIDS_GAMES':
        return Icons.sports_esports;
      case 'KIDS_ANIMALS':
        return Icons.pets;
      case 'KIDS_FOOD':
        return Icons.fastfood;
      case 'KIDS_IMAGINATION':
        return Icons.auto_awesome;
      case 'KIDS_CHALLENGES':
        return Icons.sports_kabaddi;
      case 'KIDS_HOBBIES':
        return Icons.extension;
      case 'TEENS_FRIENDS':
        return Icons.group;
      case 'TEENS_SCHOOL':
        return Icons.school;
      case 'TEENS_MUSIC':
        return Icons.music_note;
      case 'TEENS_MOVIES':
        return Icons.movie;
      case 'TEENS_TECH':
        return Icons.smartphone;
      case 'TEENS_HOBBIES':
        return Icons.palette;
      case 'TEENS_DREAMS':
        return Icons.rocket_launch;
      case 'TEENS_EMBARRASSING':
        return Icons.sentiment_very_dissatisfied;
      case 'TEENS_STYLE':
        return Icons.checkroom;
      case 'TEENS_ADVENTURE':
        return Icons.travel_explore;
      case 'ADULTS_RELATIONSHIPS':
        return Icons.favorite;
      case 'ADULTS_PARTY':
        return Icons.celebration;
      case 'ADULTS_WORK':
        return Icons.work;
      case 'ADULTS_TRAVEL':
        return Icons.flight_takeoff;
      case 'ADULTS_DEEP':
        return Icons.psychology;
      case 'ADULTS_WILD':
        return Icons.whatshot;
      case 'ADULTS_FLIRTY':
        return Icons.favorite_border;
      case 'ADULTS_CHILDHOOD':
        return Icons.child_care;
      case 'ADULTS_POPCULTURE':
        return Icons.star;
      case 'ADULTS_PERSONAL':
        return Icons.self_improvement;
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
    final Color defaultSelectedColor = const Color(0xFF5B86E5).withOpacity(0.25);
    final Color defaultUnselectedColor = Colors.white.withOpacity(0.13);
    final Color borderColor = selected ? (selectedColor ?? defaultSelectedColor) : Colors.transparent;
    final Color bgColor = selected ? (selectedColor ?? defaultSelectedColor) : (unselectedColor ?? defaultUnselectedColor);
    final Color textColor = selected ? Colors.white : Colors.white.withOpacity(0.92);
    final Color iconColor = selected ? Colors.white : Colors.white.withOpacity(0.92);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: cardWidth > maxCardWidth ? maxCardWidth : cardWidth,
      padding: EdgeInsets.symmetric(vertical: cardPadding, horizontal: cardPadding + 2),
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
                  ? const Icon(Icons.check_circle, color: Colors.white, size: 24, key: ValueKey('check'))
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
    final double appBarHeight = (size.height * 0.12).clamp(64, 120); // Responsive
    final double continueBtnHeight = (size.height * 0.08).clamp(48, 70); // Responsive
    final double bottomPadding = (size.height * 0.09).clamp(48, 90); // replaces 69
    final double continueFontSize = (size.width * 0.06).clamp(18, 28);

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
                          top: (MediaQuery.of(context).size.height * 0.012).clamp(4, 16),
                          left: (MediaQuery.of(context).size.width * 0.07).clamp(18, 36),
                          right: (MediaQuery.of(context).size.width * 0.07).clamp(18, 36),
                          // Only a little extra space so last item is visible above the button
                          bottom: bottomPadding + continueBtnHeight * 0.5,
                        ),
                        child: ListView.builder(
                          itemCount: _categories.length + 1, // Add one for the extra space
                          itemBuilder: (context, idx) {
                            if (idx == _categories.length) {
                              // Add extra space at the end
                              return const SizedBox(height: 32);
                            }
                            final cat = _categories[idx];
                            final bool selected = _selectedCategoryIds.contains(cat.id);
                            final iconData = getCategoryIcon(cat.id);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: (MediaQuery.of(context).size.height * 0.012).clamp(4, 16) / 2),
                              child: ToggleButton(
                                label: _localizedCategoryLabel(context, cat.id, cat.name),
                                selected: selected,
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategoryIds.remove(cat.id);
                                    } else {
                                      _selectedCategoryIds.add(cat.id);
                                    }
                                  });
                                },
                                icon: iconData,
                                iconSize: (MediaQuery.of(context).size.width * 0.08).clamp(26, 36),
                                fontSize: (MediaQuery.of(context).size.width * 0.06).clamp(16, 26),
                              ),
                            );
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
                              padding: EdgeInsets.only(bottom: bottomPadding), // Responsive
                              child: Center(
                                child: Container(
                                  width: (size.width * 0.75).clamp(220, 420), // Responsive
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha((0.3 * 255).round()),
                                        blurRadius: 10.0,
                                        spreadRadius: 1.0,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: _AnimatedButton(
                                    enabled: _selectedCategoryIds.isNotEmpty,
                                    onTap: _selectedCategoryIds.isEmpty
                                        ? null
                                        : () async {
                                            await _saveLastPlayedCategories();
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) => AddPlayersScreen(
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
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size((size.width * 0.75).clamp(220, 420), continueBtnHeight), // Responsive
                                        padding: EdgeInsets.symmetric(vertical: (size.height * 0.014).clamp(8, 18)), // Responsive
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        textStyle: GoogleFonts.baloo2(
                                          fontSize: continueFontSize, // Responsive
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: _selectedCategoryIds.isEmpty ? null : () async {
                                        SoundManager.playButtonSound();
                                        await _saveLastPlayedCategories();
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => AddPlayersScreen(
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
                                            alignment: Alignment.center,
                                            child: Text(
                                              AppLocalizations.of(context)!.continueBtn,
                                              style: GoogleFonts.baloo2(
                                                fontWeight: FontWeight.bold,
                                                fontSize: continueFontSize,
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

class _AnimatedCategoryCard extends StatefulWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final IconData iconData;
  const _AnimatedCategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    required this.fontSize,
    required this.iconData,
    Key? key,
  }) : super(key: key);
  @override
  State<_AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}
class _AnimatedCategoryCardState extends State<_AnimatedCategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim = Tween<double>(begin: 1, end: 1.07).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }
  @override
  void didUpdateWidget(covariant _AnimatedCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;
    final double iconSize = widget.iconSize;
    final double fontSize = widget.fontSize;
    final Color selectedBg = selected ? const Color(0xFF5B86E5).withOpacity(0.18) : Colors.white.withOpacity(0.13);
    final Color borderColor = selected ? const Color(0xFF5B86E5) : Colors.transparent;
    final Gradient? gradient = selected
        ? const LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF8F6ED5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? null : selectedBg,
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: 2.2,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: const Color(0xFF5B86E5).withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(iconSize / 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.iconData,
                  color: selected ? Colors.white : const Color(0xFF5B86E5),
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AutoSizeText(
                  _localizedCategoryLabel(context, widget.category.id, widget.category.name),
                  style: GoogleFonts.baloo2(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.black,
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
                    ? const Icon(Icons.check_circle, color: Colors.white, size: 28, key: ValueKey('check'))
                    : const SizedBox(width: 38, key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;
  const _AnimatedButton({required this.child, required this.enabled, required this.onTap, Key? key}) : super(key: key);
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}
class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 1, upperBound: 1.07);
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

// Add this mapping at the end of the file (or in a suitable place):
const Map<String, String> _categoryIdToKey = {
  'KIDS_FUNNY': 'categoryFunny',
  'KIDS_FAMILY': 'categoryFamily',
  'KIDS_SCHOOL': 'categorySchool',
  'KIDS_CARTOONS': 'categoryCartoons',
  'KIDS_GAMES': 'categoryGames',
  'KIDS_ANIMALS': 'categoryAnimals',
  'KIDS_FOOD': 'categoryFood',
  'KIDS_IMAGINATION': 'categoryImagination',
  'KIDS_CHALLENGES': 'categoryChallenges',
  'KIDS_HOBBIES': 'categoryHobbies',
  'TEENS_FRIENDS': 'categoryFriends',
  'TEENS_SCHOOL': 'categorySchool',
  'TEENS_MUSIC': 'categoryMusic',
  'TEENS_MOVIES': 'categoryMovies',
  'TEENS_TECH': 'categoryTech',
  'TEENS_HOBBIES': 'categoryHobbies',
  'TEENS_DREAMS': 'categoryDreams',
  'TEENS_EMBARRASSING': 'categoryEmbarrassing',
  'TEENS_STYLE': 'categoryStyle',
  'TEENS_ADVENTURE': 'categoryAdventure',
  'ADULTS_RELATIONSHIPS': 'categoryRelationships',
  'ADULTS_PARTY': 'categoryParty',
  'ADULTS_WORK': 'categoryWork',
  'ADULTS_TRAVEL': 'categoryTravel',
  'ADULTS_DEEP': 'categoryDeep',
  'ADULTS_WILD': 'categoryWild',
  'ADULTS_FLIRTY': 'categoryFlirty',
  'ADULTS_CHILDHOOD': 'categoryChildhood',
  'ADULTS_POPCULTURE': 'categoryPopculture',
  'ADULTS_PERSONAL': 'categoryPersonal',
};

String _localizedCategoryLabel(BuildContext context, String id, String fallback) {
  final loc = AppLocalizations.of(context)!;
  final key = _categoryIdToKey[id];
  if (key == null) return fallback;
  // Use a try/catch in case the getter is missing (e.g., not yet added to ARB)
  try {
    switch (key) {
      case 'categoryFunny': return loc.categoryFunny;
      case 'categoryFamily': return loc.categoryFamily;
      case 'categorySchool': return loc.categorySchool;
      case 'categoryCartoons': return loc.categoryCartoons;
      case 'categoryGames': return loc.categoryGames;
      case 'categoryAnimals': return loc.categoryAnimals;
      case 'categoryFood': return loc.categoryFood;
      case 'categoryImagination': return loc.categoryImagination;
      case 'categoryChallenges': return loc.categoryChallenges;
      case 'categoryHobbies': return loc.categoryHobbies;
      case 'categoryFriends': return loc.categoryFriends;
      case 'categoryMusic': return loc.categoryMusic;
      case 'categoryMovies': return loc.categoryMovies;
      case 'categoryTech': return loc.categoryTech;
      case 'categoryDreams': return loc.categoryDreams;
      case 'categoryEmbarrassing': return loc.categoryEmbarrassing;
      case 'categoryStyle': return loc.categoryStyle;
      case 'categoryAdventure': return loc.categoryAdventure;
      case 'categoryRelationships': return loc.categoryRelationships;
      case 'categoryParty': return loc.categoryParty;
      case 'categoryWork': return loc.categoryWork;
      case 'categoryTravel': return loc.categoryTravel;
      case 'categoryDeep': return loc.categoryDeep;
      case 'categoryWild': return loc.categoryWild;
      case 'categoryFlirty': return loc.categoryFlirty;
      case 'categoryChildhood': return loc.categoryChildhood;
      case 'categoryPopculture': return loc.categoryPopculture;
      case 'categoryPersonal': return loc.categoryPersonal;
      default:
        return fallback;
    }
  } catch (_) {
    return fallback;
  }
}
