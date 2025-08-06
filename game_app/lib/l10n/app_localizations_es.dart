// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Verdad o Reto';

  @override
  String get continueBtn => '¡Continuar';

  @override
  String get gameSetup => 'Configuración del juego';

  @override
  String get gameMode => 'Modo de juego';

  @override
  String get ageGroup => 'Grupo de edad';

  @override
  String get kids => 'Niños';

  @override
  String get teen => 'Adolescentes';

  @override
  String get adult => 'Adultos';

  @override
  String get startGame => 'Comenzar juego';

  @override
  String get addTruths => 'Agregar verdades';

  @override
  String get addDares => 'Agregar retos';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get ratings => 'Calificaciones';

  @override
  String get share => 'Compartir';

  @override
  String get settings => 'Configuraciones';

  @override
  String get spinTheBottle => 'Girar la botella';

  @override
  String get autoNextTurn => 'Siguiente turno automático';

  @override
  String get randomTurn => 'Turno aleatorio';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get useTimer => 'Usar temporizador (60s)';

  @override
  String get confirmAge => 'Confirmar edad';

  @override
  String get adultModeWarning => 'El modo adulto no es apto para menores de 18 años.';

  @override
  String get areYouSure => '¿Estás seguro de que deseas continuar?';

  @override
  String get continueStr => 'Continuar';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get dareCategory => 'Reto';

  @override
  String get truthCategory => 'Verdad';

  @override
  String get allCategory => 'Todas';

  @override
  String get next => 'Siguiente';

  @override
  String get addPlayers => 'Agregar jugadores';

  @override
  String get enterPlayerName => 'Ingrese el nombre del jugador';

  @override
  String get player => 'Jugador';

  @override
  String get add => 'Agregar';

  @override
  String get remove => 'Eliminar';

  @override
  String get minPlayersWarning => 'Se requieren al menos 2 jugadores.';

  @override
  String get maxPlayersWarning => 'Se alcanzó el máximo de jugadores.';

  @override
  String get start => 'Comenzar';

  @override
  String get alreadyAdded => 'ya está agregado';

  @override
  String get spinTitle => 'Girar la botella';

  @override
  String get scoreboard => 'Marcador';

  @override
  String get close => 'Cerrar';

  @override
  String get homeTooltip => 'Home';

  @override
  String get quitGameTitle => '¿Salir del juego?';

  @override
  String get quitGameMessage => '¿Estás seguro de que quieres salir del juego?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get whoopsieTitle => '¡Ups!';

  @override
  String itsTurn(Object playerName) {
    return 'Es el turno de $playerName';
  }

  @override
  String get truthBtn => '¡Verdad!';

  @override
  String get dareBtn => '¡Reto!';

  @override
  String get restart => 'Reiniciar';

  @override
  String get allPlayersHadTurn => '¡Todos los jugadores han tenido su turno!';

  @override
  String get forfeit => 'Rendirse';

  @override
  String get done => 'Hecho';

  @override
  String playerTask(Object playerName) {
    return '$playerName, tu tarea:';
  }

  @override
  String get congratsTitle => '¡Felicidades!';

  @override
  String get challengeCompleted => '¡Completaste el desafío!';

  @override
  String get oopsTitle => '¡Ups! Perdiste esta ronda.';

  @override
  String get lostRound => 'Te rendiste en esta ronda.';

  @override
  String get timesUpTitle => '¡Se acabó el tiempo!';

  @override
  String get ranOutOfTime => 'Se te acabó el tiempo.';

  @override
  String get dontShowAgain => 'No volver a preguntar';

  @override
  String get chooseRandomBtn => 'Elegir al azar';

  @override
  String get itsStr => 'Es ';

  @override
  String get haptics => 'Hápticos';

  @override
  String get noInternetTitle => 'Sin conexión a Internet';

  @override
  String get noInternetMessage => 'Por favor, comprueba tu conexión a Internet e inténtalo de nuevo.';

  @override
  String get consentTitle => 'Consentimiento 18+';

  @override
  String get consentWarning => 'Algunas categorías seleccionadas contienen contenido para adultos. Debes confirmar que tienes más de 18 años y aceptas jugar.';

  @override
  String get consentQuestion => '¿Aceptas jugar con contenido para adultos?';

  @override
  String get retry => 'Reintentar';
}
