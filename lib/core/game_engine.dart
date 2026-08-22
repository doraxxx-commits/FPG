import 'game_state.dart';

class GameEngine {
  final GameState state;

  GameEngine({
    GameState? state,
  }) : state = state ?? GameState();

  void advanceDay() {
    state.nextDay();
  }

  String get currentDate {
    return state.dateString;
  }

  int get currentSeason {
    return state.season;
  }

  bool get summerTransferWindow {
    return state.transferWindowSummer;
  }

  bool get winterTransferWindow {
    return state.transferWindowWinter;
  }
}
