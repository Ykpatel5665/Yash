// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Правда или действие';

  @override
  String get continueBtn => 'Продолжить';

  @override
  String get gameSetup => 'Настройка игры';

  @override
  String get gameMode => 'Режим игры';

  @override
  String get ageGroup => 'Возрастная группа';

  @override
  String get kids => 'Дети';

  @override
  String get teen => 'Подростки';

  @override
  String get adult => 'Взрослые';

  @override
  String get startGame => 'Начать игру';

  @override
  String get addTruths => 'Добавить вопросы правды';

  @override
  String get addDares => 'Добавить задания';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get ratings => 'Оценки';

  @override
  String get share => 'Поделиться';

  @override
  String get settings => 'Настройки';

  @override
  String get spinTheBottle => 'Крутить бутылку';

  @override
  String get autoNextTurn => 'Следующий ход автоматически';

  @override
  String get randomTurn => 'Случайный ход';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get useTimer => 'Использовать таймер (60с)';

  @override
  String get confirmAge => 'Подтвердить возраст';

  @override
  String get adultModeWarning => 'Взрослый режим не подходит для лиц младше 18 лет.';

  @override
  String get areYouSure => 'Вы уверены, что хотите продолжить?';

  @override
  String get continueStr => 'Продолжить';

  @override
  String get selectCategory => 'Выбрать категорию';

  @override
  String get dareCategory => 'Действие';

  @override
  String get truthCategory => 'Правда';

  @override
  String get allCategory => 'Все';

  @override
  String get next => 'Далее';

  @override
  String get addPlayers => 'Добавить игроков';

  @override
  String get enterPlayerName => 'Введите имя игрока';

  @override
  String get player => 'Игрок';

  @override
  String get add => 'Добавить';

  @override
  String get remove => 'Удалить';

  @override
  String get minPlayersWarning => 'Требуется как минимум 2 игрока.';

  @override
  String get maxPlayersWarning => 'Достигнуто максимальное количество игроков.';

  @override
  String get start => 'Начать';

  @override
  String get alreadyAdded => 'уже добавлен!';

  @override
  String get spinTitle => 'Крутить бутылку';

  @override
  String get scoreboard => 'Таблица результатов';

  @override
  String get close => 'Закрыть';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'Выйти из игры?';

  @override
  String get quitGameMessage => 'Вы уверены, что хотите выйти из игры?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get whoopsieTitle => 'Упс!';

  @override
  String itsTurn(Object playerName) {
    return 'Ход игрока $playerName';
  }

  @override
  String get truthBtn => 'Правда!';

  @override
  String get dareBtn => 'Действие!';

  @override
  String get restart => 'Сначала';

  @override
  String get allPlayersHadTurn => 'Все игроки сделали свой ход!';

  @override
  String get forfeit => 'Сдаться';

  @override
  String get done => 'Готово';

  @override
  String playerTask(Object playerName) {
    return '$playerName, ваше задание:';
  }

  @override
  String get congratsTitle => 'Поздравляем!';

  @override
  String get challengeCompleted => 'Вы выполнили задание!';

  @override
  String get oopsTitle => 'Упс! Вы проиграли этот раунд.';

  @override
  String get lostRound => 'Вы сдались в этом раунде.';

  @override
  String get timesUpTitle => 'Время вышло!';

  @override
  String get ranOutOfTime => 'У вас закончилось время.';

  @override
  String get dontShowAgain => 'Больше не спрашивать';

  @override
  String get chooseRandomBtn => 'Выбрать случайно';

  @override
  String get itsStr => 'Это ';

  @override
  String get haptics => 'Гаптика';
}
