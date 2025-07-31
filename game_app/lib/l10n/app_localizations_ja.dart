// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '真実か挑戦か';

  @override
  String get continueBtn => '続ける';

  @override
  String get gameSetup => 'ゲーム設定';

  @override
  String get gameMode => 'ゲームモード';

  @override
  String get ageGroup => '年齢層';

  @override
  String get kids => '子供';

  @override
  String get teen => 'ティーン';

  @override
  String get adult => '大人';

  @override
  String get startGame => 'ゲーム開始';

  @override
  String get addTruths => '真実を追加';

  @override
  String get addDares => '挑戦を追加';

  @override
  String get changeLanguage => '言語を変更';

  @override
  String get ratings => '評価';

  @override
  String get share => '共有';

  @override
  String get settings => '設定';

  @override
  String get spinTheBottle => 'ボトルを回す';

  @override
  String get autoNextTurn => '自動で次のターン';

  @override
  String get randomTurn => 'ランダムターン';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get useTimer => 'タイマーを使う (60秒)';

  @override
  String get confirmAge => '年齢を確認';

  @override
  String get adultModeWarning => 'アダルトモードは18歳未満には適していません。';

  @override
  String get areYouSure => '本当に続行しますか？';

  @override
  String get continueStr => '続ける';

  @override
  String get selectCategory => 'カテゴリを選択';

  @override
  String get dareCategory => '挑戦';

  @override
  String get truthCategory => '真実';

  @override
  String get allCategory => 'すべて';

  @override
  String get next => '次へ';

  @override
  String get addPlayers => 'プレイヤーを追加';

  @override
  String get enterPlayerName => 'プレイヤー名を入力';

  @override
  String get player => 'プレイヤー';

  @override
  String get add => '追加';

  @override
  String get remove => '削除';

  @override
  String get minPlayersWarning => '少なくとも2人のプレイヤーが必要です。';

  @override
  String get maxPlayersWarning => '最大プレイヤー数に達しました。';

  @override
  String get start => '開始';

  @override
  String get alreadyAdded => 'はすでに追加されています！';

  @override
  String get spinTitle => 'ボトルを回す';

  @override
  String get scoreboard => 'スコアボード';

  @override
  String get close => '閉じる';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'ゲームを終了しますか？';

  @override
  String get quitGameMessage => '本当にゲームを終了しますか？';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get whoopsieTitle => 'おっと!';

  @override
  String itsTurn(Object playerName) {
    return '$playerNameの番です';
  }

  @override
  String get truthBtn => '真実!';

  @override
  String get dareBtn => '挑戦!';

  @override
  String get restart => 'リスタート';

  @override
  String get allPlayersHadTurn => '全員の順番が終わりました！';

  @override
  String get forfeit => 'ギブアップ';

  @override
  String get done => '完了';

  @override
  String playerTask(Object playerName) {
    return '$playerNameさん、あなたの課題：';
  }

  @override
  String get congratsTitle => 'おめでとう！';

  @override
  String get challengeCompleted => 'チャレンジを達成しました！';

  @override
  String get oopsTitle => '残念！このラウンドは失敗しました。';

  @override
  String get lostRound => 'このラウンドを棄権しました。';

  @override
  String get timesUpTitle => '時間切れ！';

  @override
  String get ranOutOfTime => '時間がなくなりました。';

  @override
  String get dontShowAgain => '今後は尋ねない';

  @override
  String get chooseRandomBtn => 'ランダムに選ぶ';

  @override
  String get itsStr => 'さて、';

  @override
  String get haptics => 'ハプティクス';

  @override
  String get consentTitle => '18歳以上の同意が必要です';

  @override
  String get consentWarning => '選択したカテゴリの中には大人向けの内容が含まれています。18歳以上であることを確認し、プレイに同意してください。';

  @override
  String get consentQuestion => '大人向けの内容でプレイすることに同意しますか？';
}
