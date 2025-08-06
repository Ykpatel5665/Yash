// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لعبة الصراحة أو التحدي';

  @override
  String get continueBtn => 'استمر';

  @override
  String get gameSetup => 'إعداد اللعبة';

  @override
  String get gameMode => 'وضع اللعبة';

  @override
  String get ageGroup => 'الفئة العمرية';

  @override
  String get kids => 'أطفال';

  @override
  String get teen => 'مراهقون';

  @override
  String get adult => 'بالغون';

  @override
  String get startGame => 'ابدأ اللعبة';

  @override
  String get addTruths => 'أضف أسئلة الصراحة';

  @override
  String get addDares => 'أضف تحديات';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get ratings => 'التقييمات';

  @override
  String get share => 'مشاركة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get spinTheBottle => 'تدوير الزجاجة';

  @override
  String get autoNextTurn => 'الدور التالي تلقائيًا';

  @override
  String get randomTurn => 'دور عشوائي';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get useTimer => 'استخدم المؤقت (60 ثانية)';

  @override
  String get confirmAge => 'تأكيد العمر';

  @override
  String get adultModeWarning => 'وضع البالغين غير مناسب لمن هم دون 18 عامًا.';

  @override
  String get areYouSure => 'هل أنت متأكد أنك تريد المتابعة؟';

  @override
  String get continueStr => 'استمر';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get dareCategory => 'تحدي';

  @override
  String get truthCategory => 'صراحة';

  @override
  String get allCategory => 'الكل';

  @override
  String get next => 'التالي';

  @override
  String get addPlayers => 'إضافة لاعبين';

  @override
  String get enterPlayerName => 'أدخل اسم اللاعب';

  @override
  String get player => 'لاعب';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get minPlayersWarning => 'مطلوب لاعبين على الأقل.';

  @override
  String get maxPlayersWarning => 'تم الوصول إلى الحد الأقصى للاعبين.';

  @override
  String get start => 'ابدأ';

  @override
  String get alreadyAdded => 'تمت الإضافة بالفعل!';

  @override
  String get spinTitle => 'تدوير الزجاجة';

  @override
  String get scoreboard => 'لوحة النتائج';

  @override
  String get close => 'إغلاق';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'هل تريد الخروج من اللعبة؟';

  @override
  String get quitGameMessage => 'هل أنت متأكد أنك تريد الخروج من اللعبة؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get whoopsieTitle => 'عفوًا!';

  @override
  String itsTurn(Object playerName) {
    return 'إنه دور $playerName';
  }

  @override
  String get truthBtn => 'صراحة!';

  @override
  String get dareBtn => 'تحدي!';

  @override
  String get restart => 'إعادة البدء';

  @override
  String get allPlayersHadTurn => 'جميع اللاعبين أنهوا دورهم!';

  @override
  String get forfeit => 'انسحب';

  @override
  String get done => 'تم';

  @override
  String playerTask(Object playerName) {
    return '$playerName، مهمتك:';
  }

  @override
  String get congratsTitle => 'تهانينا!';

  @override
  String get challengeCompleted => 'لقد أكملت التحدي!';

  @override
  String get oopsTitle => 'عفوًا! لقد خسرت هذه الجولة.';

  @override
  String get lostRound => 'لقد انسحبت من هذه الجولة.';

  @override
  String get timesUpTitle => 'انتهى الوقت!';

  @override
  String get ranOutOfTime => 'لقد نفد وقتك.';

  @override
  String get dontShowAgain => 'لا تسأل مرة أخرى';

  @override
  String get chooseRandomBtn => 'اختر عشوائياً';

  @override
  String get itsStr => 'إنها ';

  @override
  String get haptics => 'اللمسات اللمسية';

  @override
  String get noInternetTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetMessage => 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get consentTitle => 'موافقة 18+';

  @override
  String get consentWarning => 'بعض الفئات المختارة تحتوي على محتوى للبالغين. يجب أن تؤكد أنك فوق 18 عامًا وتوافق على اللعب.';

  @override
  String get consentQuestion => 'هل توافق على اللعب بمحتوى للبالغين؟';

  @override
  String get retry => 'إعادة المحاولة';
}
