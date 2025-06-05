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
  String get continueBtn => 'Продолжить!';

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
  String get categoryFunny => 'Смешной';

  @override
  String get categoryFamily => 'Семья';

  @override
  String get categorySchool => 'Школа';

  @override
  String get categoryCartoons => 'Мультфильмы';

  @override
  String get categoryGames => 'Игры';

  @override
  String get categoryAnimals => 'Животные';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryImagination => 'Воображение';

  @override
  String get categoryChallenges => 'Испытания';

  @override
  String get categoryHobbies => 'Хобби';

  @override
  String get categoryFriends => 'Друзья';

  @override
  String get categoryMusic => 'Музыка';

  @override
  String get categoryMovies => 'Фильмы';

  @override
  String get categoryTech => 'Технологии';

  @override
  String get categoryDreams => 'Мечты';

  @override
  String get categoryEmbarrassing => 'Смущающий';

  @override
  String get categoryStyle => 'Стиль';

  @override
  String get categoryAdventure => 'Приключение';

  @override
  String get categoryRelationships => 'Отношения';

  @override
  String get categoryParty => 'Вечеринка';

  @override
  String get categoryWork => 'Работа';

  @override
  String get categoryTravel => 'Путешествие';

  @override
  String get categoryDeep => 'Глубокий';

  @override
  String get categoryWild => 'Дикий';

  @override
  String get categoryFlirty => 'Флиртующий';

  @override
  String get categoryChildhood => 'Детство';

  @override
  String get categoryPopculture => 'Поп-культура';

  @override
  String get categoryPersonal => 'Личное';

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
    return '$playerName, ваше испытание:';
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
}
