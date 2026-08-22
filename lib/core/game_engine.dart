import '../data/world_data.dart';
import '../models/club.dart';
import '../models/fixture.dart';
import '../models/league.dart';
import '../models/match_result.dart';
import '../models/player.dart';
import '../simulation/fixture_generator.dart';
import '../simulation/league_engine.dart';
import '../simulation/match_engine.dart';
import 'game_state.dart';
import '../models/player_career.dart';
import 'training_engine.dart';

class GameEngine {
  final GameState state;

  late final List<League> leagues;
  late final List<Club> clubs;
  late final List<Player> players;

  late final LeagueEngine leagueEngine;
  late final MatchEngine matchEngine;

  late final List<Fixture> fixtures;

  late final List<Fixture> fixtures;
  
  PlayerCareer? careerPlayer;

  void createPlayer({
  required String firstName,
  required String lastName,
  required String nationality,
  required int age,
  required int height,
  required PlayerPosition position,
  required int pace,
  required int shooting,
  required int passing,
  required int dribbling,
  required int defending,
  required int physical,
}) {
  final player = PlayerCareer(
    id: 'career_player_001',
    firstName: firstName,
    lastName: lastName,
    nationality: nationality,
    age: age,
    height: height,
    position: position,
    overall: 1,
    potential: 85,
    pace: pace,
    shooting: shooting,
    passing: passing,
    dribbling: dribbling,
    defending: defending,
    physical: physical,
  );

  player.refreshOverall();

  careerPlayer = player;
}
  
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

    matchEngine = MatchEngine();

    fixtures = FixtureGenerator.generateDoubleRoundRobin(
      leagueClubs,
    );
  }

  void advanceDay() {
    state.nextDay();

    playMatchesForToday();
  }

  void playMatchesForToday() {
    for (final fixture in fixtures) {
      if (fixture.played) {
        continue;
      }

      if (fixture.year == state.year &&
          fixture.month == state.month &&
          fixture.day == state.day) {
        playFixture(fixture);
     
      final TrainingEngine trainingEngine =
    TrainingEngine();

        TrainingResult trainPlayer(
  TrainingType type,
) {
  if (careerPlayer == null) {
    throw StateError(
      'Brak aktywnego zawodnika.',
    );
  }

  final player = careerPlayer!;

  final result = trainingEngine.train(
    player,
    type,
  );

  player.fatigue = (
    player.fatigue +
    result.fatigue
  ).clamp(0, 100);

  return result;

      }
    }
  }

  void assignPlayerToClub(String clubId) {
  if (careerPlayer == null) {
    return;
  }

  final club = clubs.firstWhere(
    (club) => club.id == clubId,
  );

  careerPlayer!.clubId = clubId;

  final marketValue = calculateStartingMarketValue(
    careerPlayer!,
    club,
  );

  final salary = calculateStartingSalary(
    careerPlayer!,
    club,
  );

  careerPlayer!.contract = PlayerContract(
    clubId: club.id,
    yearsRemaining: 3,
    weeklySalary: salary,
    marketValue: marketValue,
    squadNumber: 27,
    squadStatus: 'Młody zawodnik',
    managerTrust: 50,
  );
}

  double calculateStartingMarketValue(
  PlayerCareer player,
  Club club,
) {
  final ageFactor = player.age <= 21
      ? 1.25
      : player.age <= 25
          ? 1.10
          : 0.90;

  final potentialFactor =
      player.potential / 70;

  final clubFactor =
      club.overall / 70;

  return 250000 *
      player.overall *
      ageFactor *
      potentialFactor *
      clubFactor;
}

  double calculateStartingSalary(
  PlayerCareer player,
  Club club,
) {
  final baseSalary = 150.0;

  final overallFactor =
      player.overall / 50;

  final clubFactor =
      club.overall / 70;

  return baseSalary *
      overallFactor *
      clubFactor;
}

  
  careerPlayer!.clubId = clubId;
}

  MatchResult playFixture(Fixture fixture) {
    final home = clubs.firstWhere(
      (club) => club.id == fixture.homeClubId,
    );

    final away = clubs.firstWhere(
      (club) => club.id == fixture.awayClubId,
    );

    final result = matchEngine.simulate(
      home: home,
      away: away,
    );

    fixture.played = true;
    fixture.homeGoals = result.homeGoals;
    fixture.awayGoals = result.awayGoals;

    leagueEngine.recordMatch(
      homeClubId: result.homeClubId,
      awayClubId: result.awayClubId,
      homeGoals: result.homeGoals,
      awayGoals: result.awayGoals,
    );

    return result;
  }

  List<Fixture> get todayFixtures {
    return fixtures.where(
      (fixture) =>
          fixture.year == state.year &&
          fixture.month == state.month &&
          fixture.day == state.day,
    ).toList();
  }

  List<Fixture> get playedFixtures {
    return fixtures.where(
      (fixture) => fixture.played,
    ).toList();
  }

  List<Fixture> get upcomingFixtures {
    return fixtures.where(
      (fixture) => !fixture.played,
    ).toList();
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
}
