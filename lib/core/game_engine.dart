import '../data/world_data.dart';
import '../models/club.dart';
import '../models/fixture.dart';
import '../models/league.dart';
import '../models/player.dart';
import '../simulation/fixture_generator.dart';
import '../simulation/league_engine.dart';
import 'game_state.dart';

class GameEngine {
  final GameState state;

  late final List<League> leagues;
  late final List<Club> clubs;
  late final List<Player> players;

  late final LeagueEngine leagueEngine;

  late final List<Fixture> fixtures;

  GameEngine({
    GameState? state,
  }) : state = state ?? GameState() {
    leagues = WorldData.leagues;
    clubs = WorldData.clubs;
    players = WorldData.players;

    final leagueClubs = clubs.where(
      (club) => club.leagueId == 'pol_ek',
    ).toList();

    leagueEngine = LeagueEngine(
      clubs: leagueClubs,
    );

    fixtures = FixtureGenerator.generateDoubleRoundRobin(
      leagueClubs,
    );
  }

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

  List<Club> get leagueClubs {
    return clubs.where(
      (club) => club.leagueId == 'pol_ek',
    ).toList();
  }

  List<Fixture> get roundOneFixtures {
    return fixtures.where(
      (fixture) => fixture.round == 1,
    ).toList();
  }
}
