import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_players_screen.dart';
import 'main.dart';
import 'dart:ui';

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
  const CategorySelectionScreen({super.key, required this.gameMode, required this.ageGroup});

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
              child: Text(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
    final double appBarHeight = 100;
    final double continueBtnHeight = 62;
    final double safePadding = MediaQuery.of(context).padding.top;
    final int categoryCount = _categories.length;
    // Responsive min/max
    const double minCardHeight = 38;
    const double maxCardHeight = 90;
    const double minSpacing = 6;
    const double maxSpacing = 18;
    final double baseSpacing = (size.height * 0.018).clamp(minSpacing, maxSpacing);
    final double buttonFontSize = (size.width * 0.05).clamp(16, 26);
    final double cardFont = (size.width < 500) ? 15 : 20;
    final double iconSize = (size.width < 500) ? 28 : 36;
    final double cardRadius = 24;
    final Color glowBlue = const Color(0xFF3B82F6);
    final Color dark1 = const Color(0xFF1E1E1E);
    final Color dark2 = const Color(0xFF2A2A2A);
    final Color frostedOverlay = Colors.white.withOpacity(0.08);

    // Calculate available height for all category buttons (excluding appbar, spacing, continue button)
    final double availableHeight = size.height - safePadding - appBarHeight - continueBtnHeight - baseSpacing * 2 - 32;
    // Start with max card height and spacing
    double cardHeight = maxCardHeight;
    double spacing = maxSpacing;
    // Calculate total required height
    double totalRequired = categoryCount * cardHeight + (categoryCount - 1) * spacing;
    // If overflow, shrink spacing and card height proportionally
    if (totalRequired > availableHeight) {
      // Try reducing spacing to min
      spacing = minSpacing;
      cardHeight = ((availableHeight - (categoryCount - 1) * spacing) / categoryCount).clamp(minCardHeight, maxCardHeight);
      totalRequired = categoryCount * cardHeight + (categoryCount - 1) * spacing;
      // If still overflow, reduce cardHeight to min
      if (totalRequired > availableHeight) {
        cardHeight = minCardHeight;
        spacing = ((availableHeight - categoryCount * cardHeight) / (categoryCount - 1)).clamp(minSpacing, maxSpacing);
        if (spacing.isNaN || spacing < minSpacing) spacing = minSpacing;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 15, bottom: 15),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    offset: const Offset(-3, -3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Select Categories',
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withAlpha((0.5 * 255).round()),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: appBarHeight,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Lighter Premium Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF23243A), // Lighter navy
                  Color(0xFF4B3C6A), // Lighter purple
                  Color(0xFFD1BFA3), // Lighter gold accent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glassmorphism overlay for the whole screen
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28), // slightly lighter overlay
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Color(0xFFD1BFA3).withOpacity(0.18), // lighter gold border
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1BFA3).withOpacity(0.08),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: baseSpacing),
                      // One category button per row, all fit in screen, no scroll
                      ..._categories.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cat = entry.value;
                        final bool selected = _selectedCategoryIds.contains(cat.id);
                        final iconData = getCategoryIcon(cat.id);
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 18,
                            right: 18,
                            bottom: idx == _categories.length - 1 ? 0 : spacing,
                          ),
                          child: SizedBox(
                            height: cardHeight,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2C2D3F).withOpacity(0.72), // lighter, more transparent
                                    Color(0xFF3E4060).withOpacity(0.68)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: [
                                  if (selected)
                                    BoxShadow(
                                      color: glowBlue.withOpacity(0.38),
                                      blurRadius: 18,
                                      spreadRadius: 1.5,
                                      offset: const Offset(0, 2),
                                    ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.13),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: selected ? glowBlue.withOpacity(0.55) : Colors.transparent,
                                  width: selected ? 2.2 : 1.1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(cardRadius),
                                  onTap: () {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategoryIds.remove(cat.id);
                                      } else {
                                        _selectedCategoryIds.add(cat.id);
                                      }
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      if (selected)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                            child: Container(
                                              color: frostedOverlay,
                                            ),
                                          ),
                                        ),
                                      // Fix: Use Align to center Row vertically in the button
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 35, right: 15), // Add left space from border, right space before text
                                              child: Icon(
                                                iconData,
                                                color: selected ? Colors.white : Colors.white.withOpacity(0.78),
                                                size: iconSize,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                cat.name,
                                                style: GoogleFonts.baloo2(
                                                  fontSize: cardFont,
                                                  fontWeight: FontWeight.bold,
                                                  color: selected ? Colors.white : Colors.white.withOpacity(0.82),
                                                  letterSpacing: 0.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 180),
                                              child: selected
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(left: 15, right: 30), // Add right space from border
                                                      child: Icon(Icons.check_circle, color: Colors.white, size: 28, key: ValueKey('check')),
                                                    )
                                                  : const SizedBox(width: 28, key: ValueKey('empty')),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(cardRadius),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: glowBlue.withOpacity(0.18),
                                                    blurRadius: 18,
                                                    spreadRadius: -8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
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
                      }),
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, baseSpacing, 18, baseSpacing + 8),
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
                          child: Container(
                            width: double.infinity,
                            height: continueBtnHeight,
                            decoration: BoxDecoration(
                              color: _selectedCategoryIds.isEmpty ? Colors.grey[400] : const Color(0xFF5E81F4),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5E81F4).withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Continue",
                              style: GoogleFonts.poppins(
                                fontSize: buttonFontSize + 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.1,
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
                child: Text(
                  widget.category.name,
                  style: GoogleFonts.baloo2(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.black,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
