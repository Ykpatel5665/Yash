import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Truth or Dare'**
  String get appTitle;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue!'**
  String get continueBtn;

  /// No description provided for @gameSetup.
  ///
  /// In en, this message translates to:
  /// **'Game Setup'**
  String get gameSetup;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @teen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get teen;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @addTruths.
  ///
  /// In en, this message translates to:
  /// **'Add Truths'**
  String get addTruths;

  /// No description provided for @addDares.
  ///
  /// In en, this message translates to:
  /// **'Add Dares'**
  String get addDares;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @spinTheBottle.
  ///
  /// In en, this message translates to:
  /// **'Spin the bottle'**
  String get spinTheBottle;

  /// No description provided for @autoNextTurn.
  ///
  /// In en, this message translates to:
  /// **'Auto next turn'**
  String get autoNextTurn;

  /// No description provided for @randomTurn.
  ///
  /// In en, this message translates to:
  /// **'Random turn'**
  String get randomTurn;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @useTimer.
  ///
  /// In en, this message translates to:
  /// **'Use Timer (60s)'**
  String get useTimer;

  /// No description provided for @confirmAge.
  ///
  /// In en, this message translates to:
  /// **'Confirm Age'**
  String get confirmAge;

  /// No description provided for @adultModeWarning.
  ///
  /// In en, this message translates to:
  /// **'Adult mode is not suitable for anyone under 18.'**
  String get adultModeWarning;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to continue?'**
  String get areYouSure;

  /// No description provided for @continueStr.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueStr;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @dareCategory.
  ///
  /// In en, this message translates to:
  /// **'Dare'**
  String get dareCategory;

  /// No description provided for @truthCategory.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get truthCategory;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @addPlayers.
  ///
  /// In en, this message translates to:
  /// **'Add Players'**
  String get addPlayers;

  /// No description provided for @enterPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Enter player name'**
  String get enterPlayerName;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @minPlayersWarning.
  ///
  /// In en, this message translates to:
  /// **'At least 2 players required.'**
  String get minPlayersWarning;

  /// No description provided for @maxPlayersWarning.
  ///
  /// In en, this message translates to:
  /// **'Maximum players reached.'**
  String get maxPlayersWarning;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'is already added!'**
  String get alreadyAdded;

  /// No description provided for @categoryFunny.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get categoryFunny;

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryCartoons.
  ///
  /// In en, this message translates to:
  /// **'Cartoons'**
  String get categoryCartoons;

  /// No description provided for @categoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get categoryGames;

  /// No description provided for @categoryAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get categoryAnimals;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryImagination.
  ///
  /// In en, this message translates to:
  /// **'Imagination'**
  String get categoryImagination;

  /// No description provided for @categoryChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get categoryChallenges;

  /// No description provided for @categoryHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get categoryHobbies;

  /// No description provided for @categoryFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get categoryFriends;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get categoryMovies;

  /// No description provided for @categoryTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get categoryTech;

  /// No description provided for @categoryDreams.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get categoryDreams;

  /// No description provided for @categoryEmbarrassing.
  ///
  /// In en, this message translates to:
  /// **'Embarrassing'**
  String get categoryEmbarrassing;

  /// No description provided for @categoryStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get categoryStyle;

  /// No description provided for @categoryAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get categoryAdventure;

  /// No description provided for @categoryRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get categoryRelationships;

  /// No description provided for @categoryParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get categoryParty;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get categoryDeep;

  /// No description provided for @categoryWild.
  ///
  /// In en, this message translates to:
  /// **'Wild'**
  String get categoryWild;

  /// No description provided for @categoryFlirty.
  ///
  /// In en, this message translates to:
  /// **'Flirty'**
  String get categoryFlirty;

  /// No description provided for @categoryChildhood.
  ///
  /// In en, this message translates to:
  /// **'Childhood'**
  String get categoryChildhood;

  /// No description provided for @categoryPopculture.
  ///
  /// In en, this message translates to:
  /// **'Pop Culture'**
  String get categoryPopculture;

  /// No description provided for @categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// No description provided for @spinTitle.
  ///
  /// In en, this message translates to:
  /// **'Spin the Bottle'**
  String get spinTitle;

  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @homeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTooltip;

  /// No description provided for @quitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Game?'**
  String get quitGameTitle;

  /// No description provided for @quitGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit the game?'**
  String get quitGameMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @whoopsieTitle.
  ///
  /// In en, this message translates to:
  /// **'Whoopsie!'**
  String get whoopsieTitle;

  /// No description provided for @itsTurn.
  ///
  /// In en, this message translates to:
  /// **'It\'s {playerName}\'s turn'**
  String itsTurn(Object playerName);

  /// No description provided for @truthBtn.
  ///
  /// In en, this message translates to:
  /// **'Truth!'**
  String get truthBtn;

  /// No description provided for @dareBtn.
  ///
  /// In en, this message translates to:
  /// **'Dare!'**
  String get dareBtn;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @allPlayersHadTurn.
  ///
  /// In en, this message translates to:
  /// **'All players had their turn!'**
  String get allPlayersHadTurn;

  /// No description provided for @forfeit.
  ///
  /// In en, this message translates to:
  /// **'Forfeit'**
  String get forfeit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @playerTask.
  ///
  /// In en, this message translates to:
  /// **'{playerName}, your task:'**
  String playerTask(Object playerName);

  /// No description provided for @congratsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congrats!'**
  String get congratsTitle;

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed the challenge!'**
  String get challengeCompleted;

  /// No description provided for @oopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops! You lost this round.'**
  String get oopsTitle;

  /// No description provided for @lostRound.
  ///
  /// In en, this message translates to:
  /// **'You forfeited this round.'**
  String get lostRound;

  /// No description provided for @timesUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time’s up!'**
  String get timesUpTitle;

  /// No description provided for @ranOutOfTime.
  ///
  /// In en, this message translates to:
  /// **'You ran out of time.'**
  String get ranOutOfTime;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get dontShowAgain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'de', 'en', 'es', 'fr', 'hi', 'ja', 'ko', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
