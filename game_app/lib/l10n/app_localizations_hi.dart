// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'सच या साहस';

  @override
  String get continueBtn => 'जारी रखें';

  @override
  String get gameSetup => 'गेम सेटअप';

  @override
  String get gameMode => 'गेम मोड';

  @override
  String get ageGroup => 'आयु वर्ग';

  @override
  String get kids => 'बच्चे';

  @override
  String get teen => 'किशोर';

  @override
  String get adult => 'वयस्क';

  @override
  String get startGame => 'खेल शुरू करें';

  @override
  String get addTruths => 'सच जोड़ें';

  @override
  String get addDares => 'साहस जोड़ें';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get ratings => 'रेटिंग्स';

  @override
  String get share => 'साझा करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get spinTheBottle => 'बोतल घुमाएं';

  @override
  String get autoNextTurn => 'अगला टर्न स्वचालित';

  @override
  String get randomTurn => 'रैंडम टर्न';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get useTimer => 'टाइमर का उपयोग करें (60s)';

  @override
  String get confirmAge => 'आयु की पुष्टि करें';

  @override
  String get adultModeWarning => 'एडल्ट मोड 18 वर्ष से कम के लिए उपयुक्त नहीं है।';

  @override
  String get areYouSure => 'क्या आप वाकई जारी रखना चाहते हैं?';

  @override
  String get continueStr => 'जारी रखें';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get dareCategory => 'साहस';

  @override
  String get truthCategory => 'सच';

  @override
  String get allCategory => 'सभी';

  @override
  String get next => 'आगे';

  @override
  String get addPlayers => 'खिलाड़ी जोड़ें';

  @override
  String get enterPlayerName => 'खिलाड़ी का नाम दर्ज करें';

  @override
  String get player => 'खिलाड़ी';

  @override
  String get add => 'जोड़ें';

  @override
  String get remove => 'हटाएं';

  @override
  String get minPlayersWarning => 'कम से कम 2 खिलाड़ी आवश्यक हैं।';

  @override
  String get maxPlayersWarning => 'अधिकतम खिलाड़ी सीमा पहुँच गई है।';

  @override
  String get start => 'शुरू करें';

  @override
  String get alreadyAdded => 'पहले से जोड़ा गया है!';

  @override
  String get spinTitle => 'बोतल घुमाएँ';

  @override
  String get scoreboard => 'स्कोरबोर्ड';

  @override
  String get close => 'बंद करें';

  @override
  String get homeTooltip => 'होम';

  @override
  String get quitGameTitle => 'खेल छोड़ें?';

  @override
  String get quitGameMessage => 'क्या आप वाकई खेल छोड़ना चाहते हैं?';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get whoopsieTitle => 'अरे!';

  @override
  String itsTurn(Object playerName) {
    return 'अब $playerName की बारी है';
  }

  @override
  String get truthBtn => 'सच!';

  @override
  String get dareBtn => 'साहस!';

  @override
  String get restart => 'फिर से शुरू करें';

  @override
  String get allPlayersHadTurn => 'सभी खिलाड़ियों की बारी हो गई!';

  @override
  String get forfeit => 'हार मानना';

  @override
  String get done => 'पूर्ण';

  @override
  String playerTask(Object playerName) {
    return '$playerName, आपका कार्य:';
  }

  @override
  String get congratsTitle => 'बधाई हो!';

  @override
  String get challengeCompleted => 'आपने चुनौती पूरी कर ली है!';

  @override
  String get oopsTitle => 'अरे! आप यह राउंड हार गए।';

  @override
  String get lostRound => 'आपने यह राउंड छोड़ दिया।';

  @override
  String get timesUpTitle => 'समय समाप्त!';

  @override
  String get ranOutOfTime => 'आपका समय समाप्त हो गया।';

  @override
  String get dontShowAgain => 'फिर से न पूछें';

  @override
  String get chooseRandomBtn => 'यादृच्छिक चुनें';

  @override
  String get itsStr => 'यह ';

  @override
  String get haptics => 'हैप्टिक्स';

  @override
  String get noInternetTitle => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String get noInternetMessage => 'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get consentTitle => '18+ सहमति';

  @override
  String get consentWarning => 'कुछ चयनित श्रेणियों में वयस्क सामग्री है। आपको पुष्टि करनी होगी कि आप 18 वर्ष से अधिक हैं और खेलने के लिए सहमत हैं।';

  @override
  String get consentQuestion => 'क्या आप वयस्क सामग्री के साथ खेलने के लिए सहमत हैं?';

  @override
  String get retry => 'पुनः प्रयास करें';
}
