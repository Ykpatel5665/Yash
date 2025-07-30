// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Action ou Vérité';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get gameSetup => 'Configuration du jeu';

  @override
  String get gameMode => 'Mode de jeu';

  @override
  String get ageGroup => 'Groupe d\'âge';

  @override
  String get kids => 'Enfants';

  @override
  String get teen => 'Adolescents';

  @override
  String get adult => 'Adultes';

  @override
  String get startGame => 'Démarrer le jeu';

  @override
  String get addTruths => 'Ajouter des vérités';

  @override
  String get addDares => 'Ajouter des défis';

  @override
  String get changeLanguage => 'Changer de langue';

  @override
  String get ratings => 'Évaluations';

  @override
  String get share => 'Partager';

  @override
  String get settings => 'Paramètres';

  @override
  String get spinTheBottle => 'Tourner la bouteille';

  @override
  String get autoNextTurn => 'Tour suivant automatique';

  @override
  String get randomTurn => 'Tour aléatoire';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get useTimer => 'Utiliser le minuteur (60s)';

  @override
  String get confirmAge => 'Confirmer l\'âge';

  @override
  String get adultModeWarning => 'Le mode adulte ne convient pas aux moins de 18 ans.';

  @override
  String get areYouSure => 'Êtes-vous sûr de vouloir continuer ?';

  @override
  String get continueStr => 'Continuer';

  @override
  String get selectCategory => 'Sélectionner une catégorie';

  @override
  String get dareCategory => 'Défi';

  @override
  String get truthCategory => 'Vérité';

  @override
  String get allCategory => 'Toutes';

  @override
  String get next => 'Suivant';

  @override
  String get addPlayers => 'Ajouter des joueurs';

  @override
  String get enterPlayerName => 'Entrez le nom du joueur';

  @override
  String get player => 'Joueur';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Supprimer';

  @override
  String get minPlayersWarning => 'Au moins 2 joueurs requis.';

  @override
  String get maxPlayersWarning => 'Nombre maximum de joueurs atteint.';

  @override
  String get start => 'Démarrer';

  @override
  String get alreadyAdded => 'est déjà ajouté !';

  @override
  String get spinTitle => 'Tourner la bouteille';

  @override
  String get scoreboard => 'Tableau des scores';

  @override
  String get close => 'Fermer';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'Quitter le jeu ?';

  @override
  String get quitGameMessage => 'Êtes-vous sûr de vouloir quitter le jeu ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get whoopsieTitle => 'Oups!';

  @override
  String itsTurn(Object playerName) {
    return 'C\'est le tour de $playerName';
  }

  @override
  String get truthBtn => 'Vérité!';

  @override
  String get dareBtn => 'Défi!';

  @override
  String get restart => 'Redémarrer';

  @override
  String get allPlayersHadTurn => 'Tous les joueurs ont eu leur tour!';

  @override
  String get forfeit => 'Abandonner';

  @override
  String get done => 'Terminé';

  @override
  String playerTask(Object playerName) {
    return '$playerName, votre tâche :';
  }

  @override
  String get congratsTitle => 'Félicitations !';

  @override
  String get challengeCompleted => 'Vous avez relevé le défi !';

  @override
  String get oopsTitle => 'Oups ! Vous avez perdu cette manche.';

  @override
  String get lostRound => 'Vous avez abandonné cette manche.';

  @override
  String get timesUpTitle => 'Temps écoulé !';

  @override
  String get ranOutOfTime => 'Vous avez manqué de temps.';

  @override
  String get dontShowAgain => 'Ne plus demander';

  @override
  String get chooseRandomBtn => 'Choisir au hasard';

  @override
  String get itsStr => 'C\'est ';

  @override
  String get haptics => 'Haptique';
}
