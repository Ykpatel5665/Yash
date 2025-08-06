// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ট্রুথ অর ডেয়ার';

  @override
  String get continueBtn => 'চালিয়ে যান';

  @override
  String get gameSetup => 'গেম সেটআপ';

  @override
  String get gameMode => 'গেম মোড';

  @override
  String get ageGroup => 'বয়সের গ্রুপ';

  @override
  String get kids => 'শিশু';

  @override
  String get teen => 'কিশোর';

  @override
  String get adult => 'প্রাপ্তবয়স্ক';

  @override
  String get startGame => 'গেম শুরু করুন';

  @override
  String get addTruths => 'সত্য প্রশ্ন যোগ করুন';

  @override
  String get addDares => 'ডেয়ার যোগ করুন';

  @override
  String get changeLanguage => 'ভাষা পরিবর্তন করুন';

  @override
  String get ratings => 'রেটিংস';

  @override
  String get share => 'শেয়ার করুন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get spinTheBottle => 'বোতল ঘোরান';

  @override
  String get autoNextTurn => 'পরবর্তী পালা স্বয়ংক্রিয়';

  @override
  String get randomTurn => 'র্যান্ডম পালা';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get useTimer => 'টাইমার ব্যবহার করুন (60s)';

  @override
  String get confirmAge => 'বয়স নিশ্চিত করুন';

  @override
  String get adultModeWarning => 'প্রাপ্তবয়স্ক মোড ১৮ বছরের কম বয়সীদের জন্য উপযুক্ত নয়।';

  @override
  String get areYouSure => 'আপনি কি সত্যিই চালিয়ে যেতে চান?';

  @override
  String get continueStr => 'চালিয়ে যান';

  @override
  String get selectCategory => 'বিভাগ নির্বাচন করুন';

  @override
  String get dareCategory => 'ডেয়ার';

  @override
  String get truthCategory => 'সত্য';

  @override
  String get allCategory => 'সব';

  @override
  String get next => 'পরবর্তী';

  @override
  String get addPlayers => 'খেলোয়াড় যোগ করুন';

  @override
  String get enterPlayerName => 'খেলোয়াড়ের নাম লিখুন';

  @override
  String get player => 'খেলোয়াড়';

  @override
  String get add => 'যোগ করুন';

  @override
  String get remove => 'অপসারণ';

  @override
  String get minPlayersWarning => 'কমপক্ষে ২ জন খেলোয়াড় প্রয়োজন।';

  @override
  String get maxPlayersWarning => 'সর্বাধিক খেলোয়াড় সংখ্যা পৌঁছেছে।';

  @override
  String get start => 'শুরু করুন';

  @override
  String get alreadyAdded => 'ইতিমধ্যে যোগ করা হয়েছে!';

  @override
  String get spinTitle => 'বোতল ঘোরান';

  @override
  String get scoreboard => 'স্কোরবোর্ড';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'গেম ছেড়ে যাবেন?';

  @override
  String get quitGameMessage => 'আপনি কি সত্যিই গেম ছেড়ে যেতে চান?';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get whoopsieTitle => 'উফ!';

  @override
  String itsTurn(Object playerName) {
    return 'এখন $playerName-এর পালা';
  }

  @override
  String get truthBtn => 'সত্য!';

  @override
  String get dareBtn => 'ডেয়ার!';

  @override
  String get restart => 'পুনরায় শুরু করুন';

  @override
  String get allPlayersHadTurn => 'সব খেলোয়াড় তাদের পালা শেষ করেছে!';

  @override
  String get forfeit => 'পরিত্যাগ';

  @override
  String get done => 'সম্পন্ন';

  @override
  String playerTask(Object playerName) {
    return '$playerName, তোমার কাজ:';
  }

  @override
  String get congratsTitle => 'অভিনন্দন!';

  @override
  String get challengeCompleted => 'তুমি চ্যালেঞ্জটি সম্পন্ন করেছ!';

  @override
  String get oopsTitle => 'উফ! তুমি এই রাউন্ডে হেরে গেছো।';

  @override
  String get lostRound => 'তুমি এই রাউন্ডটি পরিত্যাগ করেছো।';

  @override
  String get timesUpTitle => 'সময় শেষ!';

  @override
  String get ranOutOfTime => 'তোমার সময় শেষ হয়ে গেছে।';

  @override
  String get dontShowAgain => 'আর জিজ্ঞাসা করবেন না';

  @override
  String get chooseRandomBtn => 'এলোমেলোভাবে বেছে নিন';

  @override
  String get itsStr => 'এটি ';

  @override
  String get haptics => 'হ্যাপটিক্স';

  @override
  String get noInternetTitle => 'ইন্টারনেট সংযোগ নেই';

  @override
  String get noInternetMessage => 'অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।';

  @override
  String get consentTitle => '১৮+ সম্মতি';

  @override
  String get consentWarning => 'কিছু নির্বাচিত বিভাগে প্রাপ্তবয়স্কদের বিষয়বস্তু রয়েছে। আপনাকে নিশ্চিত করতে হবে যে আপনি ১৮ বছরের বেশি এবং খেলতে সম্মত।';

  @override
  String get consentQuestion => 'আপনি কি প্রাপ্তবয়স্ক বিষয়বস্তু নিয়ে খেলতে সম্মত?';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';
}
