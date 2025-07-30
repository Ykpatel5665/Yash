// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Verdade ou Desafio';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get gameSetup => 'Configuração do jogo';

  @override
  String get gameMode => 'Modo de jogo';

  @override
  String get ageGroup => 'Faixa etária';

  @override
  String get kids => 'Crianças';

  @override
  String get teen => 'Adolescentes';

  @override
  String get adult => 'Adultos';

  @override
  String get startGame => 'Iniciar jogo';

  @override
  String get addTruths => 'Adicionar verdades';

  @override
  String get addDares => 'Adicionar desafios';

  @override
  String get changeLanguage => 'Mudar idioma';

  @override
  String get ratings => 'Avaliações';

  @override
  String get share => 'Compartilhar';

  @override
  String get settings => 'Configurações';

  @override
  String get spinTheBottle => 'Girar a garrafa';

  @override
  String get autoNextTurn => 'Próxima rodada automática';

  @override
  String get randomTurn => 'Rodada aleatória';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get useTimer => 'Usar temporizador (60s)';

  @override
  String get confirmAge => 'Confirmar idade';

  @override
  String get adultModeWarning => 'O modo adulto não é adequado para menores de 18 anos.';

  @override
  String get areYouSure => 'Tem certeza de que deseja continuar?';

  @override
  String get continueStr => 'Continuar';

  @override
  String get selectCategory => 'Selecionar categoria';

  @override
  String get dareCategory => 'Desafio';

  @override
  String get truthCategory => 'Verdade';

  @override
  String get allCategory => 'Todas';

  @override
  String get next => 'Próximo';

  @override
  String get addPlayers => 'Adicionar jogadores';

  @override
  String get enterPlayerName => 'Digite o nome do jogador';

  @override
  String get player => 'Jogador';

  @override
  String get add => 'Adicionar';

  @override
  String get remove => 'Remover';

  @override
  String get minPlayersWarning => 'Pelo menos 2 jogadores são necessários.';

  @override
  String get maxPlayersWarning => 'Número máximo de jogadores atingido.';

  @override
  String get start => 'Iniciar';

  @override
  String get alreadyAdded => 'já foi adicionado!';

  @override
  String get spinTitle => 'Girar a garrafa';

  @override
  String get scoreboard => 'Placar';

  @override
  String get close => 'Fechar';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => 'Sair do jogo?';

  @override
  String get quitGameMessage => 'Tem certeza de que deseja sair do jogo?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get whoopsieTitle => 'Ops!';

  @override
  String itsTurn(Object playerName) {
    return 'É a vez de $playerName';
  }

  @override
  String get truthBtn => 'Verdade!';

  @override
  String get dareBtn => 'Desafio!';

  @override
  String get restart => 'Reiniciar';

  @override
  String get allPlayersHadTurn => 'Todos os jogadores tiveram sua vez!';

  @override
  String get forfeit => 'Desistir';

  @override
  String get done => 'Concluído';

  @override
  String playerTask(Object playerName) {
    return '$playerName, sua tarefa:';
  }

  @override
  String get congratsTitle => 'Parabéns!';

  @override
  String get challengeCompleted => 'Você completou o desafio!';

  @override
  String get oopsTitle => 'Ops! Você perdeu esta rodada.';

  @override
  String get lostRound => 'Você desistiu desta rodada.';

  @override
  String get timesUpTitle => 'O tempo acabou!';

  @override
  String get ranOutOfTime => 'O tempo acabou para você.';

  @override
  String get dontShowAgain => 'Não perguntar novamente';

  @override
  String get chooseRandomBtn => 'Escolher aleatoriamente';

  @override
  String get itsStr => 'É ';

  @override
  String get haptics => 'Háptica';
}
