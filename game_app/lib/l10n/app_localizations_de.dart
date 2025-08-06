// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Wahrheit oder Pflicht';

  @override
  String get continueBtn => 'Weiter';

  @override
  String get gameSetup => 'Spiel einrichten';

  @override
  String get gameMode => 'Spielmodus';

  @override
  String get ageGroup => 'Altersgruppe';

  @override
  String get kids => 'Kinder';

  @override
  String get teen => 'Teenager';

  @override
  String get adult => 'Erwachsene';

  @override
  String get startGame => 'Spiel starten';

  @override
  String get addTruths => 'Wahrheiten hinzufügen';

  @override
  String get addDares => 'Pflichten hinzufügen';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get ratings => 'Bewertungen';

  @override
  String get share => 'Teilen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get spinTheBottle => 'Flasche drehen';

  @override
  String get autoNextTurn => 'Nächste Runde automatisch';

  @override
  String get randomTurn => 'Zufällige Runde';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get useTimer => 'Timer verwenden (60s)';

  @override
  String get confirmAge => 'Alter bestätigen';

  @override
  String get adultModeWarning => 'Der Erwachsenenmodus ist für Personen unter 18 Jahren nicht geeignet.';

  @override
  String get areYouSure => 'Sind Sie sicher, dass Sie fortfahren möchten?';

  @override
  String get continueStr => 'Fortfahren';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get dareCategory => 'Pflicht';

  @override
  String get truthCategory => 'Wahrheit';

  @override
  String get allCategory => 'Alle';

  @override
  String get next => 'Weiter';

  @override
  String get addPlayers => 'Spieler hinzufügen';

  @override
  String get enterPlayerName => 'Spielernamen eingeben';

  @override
  String get player => 'Spieler';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get minPlayersWarning => 'Mindestens 2 Spieler erforderlich.';

  @override
  String get maxPlayersWarning => 'Maximale Spieleranzahl erreicht.';

  @override
  String get start => 'Starten';

  @override
  String get alreadyAdded => 'ist bereits hinzugefügt!';

  @override
  String get spinTitle => 'Flasche drehen';

  @override
  String get scoreboard => 'Punktestand';

  @override
  String get close => 'Schließen';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'Spiel beenden?';

  @override
  String get quitGameMessage => 'Möchten Sie das Spiel wirklich beenden?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get whoopsieTitle => 'Hoppla!';

  @override
  String itsTurn(Object playerName) {
    return '$playerName ist dran';
  }

  @override
  String get truthBtn => 'Wahrheit!';

  @override
  String get dareBtn => 'Pflicht!';

  @override
  String get restart => 'Neustart';

  @override
  String get allPlayersHadTurn => 'Alle Spieler hatten ihren Zug!';

  @override
  String get forfeit => 'Aufgeben';

  @override
  String get done => 'Fertig';

  @override
  String playerTask(Object playerName) {
    return '$playerName, deine Aufgabe:';
  }

  @override
  String get congratsTitle => 'Glückwunsch!';

  @override
  String get challengeCompleted => 'Du hast die Herausforderung geschafft!';

  @override
  String get oopsTitle => 'Ups! Du hast diese Runde verloren.';

  @override
  String get lostRound => 'Du hast diese Runde aufgegeben.';

  @override
  String get timesUpTitle => 'Zeit ist um!';

  @override
  String get ranOutOfTime => 'Deine Zeit ist abgelaufen.';

  @override
  String get dontShowAgain => 'Nicht mehr fragen';

  @override
  String get chooseRandomBtn => 'Zufällig wählen';

  @override
  String get itsStr => 'Es ist ';

  @override
  String get haptics => 'Haptik';

  @override
  String get noInternetTitle => 'Keine Internetverbindung';

  @override
  String get noInternetMessage => 'Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get consentTitle => '18+ Zustimmung';

  @override
  String get consentWarning => 'Einige ausgewählte Kategorien enthalten Inhalte für Erwachsene. Du musst bestätigen, dass du über 18 bist und zustimmst zu spielen.';

  @override
  String get consentQuestion => 'Stimmst du zu, mit Inhalten für Erwachsene zu spielen?';

  @override
  String get retry => 'Wiederholen';
}
