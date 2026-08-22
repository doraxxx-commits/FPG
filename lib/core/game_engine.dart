import '../data/world_data.dart';

import '../models/club.dart';
import '../models/fixture.dart';
import '../models/league.dart';
import '../models/match_result.dart';
import '../models/player.dart';
import '../models/player_career.dart';
import '../models/player_contract.dart';

import '../simulation/fixture_generator.dart';
import '../simulation/league_engine.dart';
import '../simulation/match_engine.dart';

import 'game_state.dart';
import 'training_engine.dart';

class GameEngine {
  final GameState state;

  late final List<League> leagues;
  late final List<Club> clubs;
  late final List<Player> players;

  late final LeagueEngine leagueEngine;
  late final MatchEngine matchEngine;

  late final List<Fixture> fixtures;

  final TrainingEngine trainingEngine = TrainingEngine();

  PlayerCareer? careerPlayer;

  // ==========================================================
  // KONSTRUKTOR
  // ==========================================================

  GameEngine({
    GameState? state,
  }) : state = state ?? GameState() {
    leagues = WorldData.leagues;
    clubs = WorldData.clubs;
    players = WorldData.players;

    final leagueClubs = clubs
        .where(
          (club) => club.leagueId == 'pol_ek',
        )
        .toList();

    leagueEngine = LeagueEngine(
      clubs: leagueClubs,
    );

    matchEngine = MatchEngine();

    fixtures =
        FixtureGenerator.generateDoubleRoundRobin(
      leagueClubs,
    );
  }

  // ==========================================================
  // TWORZENIE ZAWODNIKA
  // ==========================================================

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

  // ==========================================================
  // NASTĘPNY DZIEŃ
  // ==========================================================

  void advanceDay() {
    state.nextDay();

    recoverPlayer();

    updatePlayerForm();

    // KROK 30:
    // Trener podejmuje decyzję o statusie zawodnika.
    updateCareerPlayerMatchStatus();

    playMatchesForToday();
  }

  // ==========================================================
  // KROK 31
  // INFORMACJE O UDZIALE ZAWODNIKA W MECZU
  // ==========================================================

  // Czy zawodnik może wystąpić w meczu.
  bool get careerPlayerCanPlay {
    if (careerPlayer == null) {
      return false;
    }

    final player = careerPlayer!;

    // Bez klubu nie można grać.
    if (player.clubId == null) {
      return false;
    }

    // Aktualizacja decyzji trenera.
    player.updateMatchStatus();

    return player.canPlayMatch;
  }

  // ==========================================================
  // KROK 31
  // CZY ZAWODNIK JEST W KADRZE MECZOWEJ
  // ==========================================================

  bool get careerPlayerInMatchSquad {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.inMatchSquad;
  }

  // ==========================================================
  // KROK 31
  // CZY ZAWODNIK JEST W PODSTAWOWYM SKŁADZIE
  // ==========================================================

  bool get careerPlayerIsStarter {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.isRegularStarter;
  }

  // ==========================================================
  // KROK 31
  // STATUS MECZOWY ZAWODNIKA
  // ==========================================================

  String get careerPlayerMatchStatus {
    if (careerPlayer == null) {
      return 'Brak zawodnika';
    }

    return careerPlayer!.squadStatus;
  }

  // ==========================================================
  // MECZE
  // ==========================================================

  void playMatchesForToday() {
    for (final fixture in fixtures) {
      if (fixture.played) {
        continue;
      }

      if (fixture.year == state.year &&
          fixture.month == state.month &&
          fixture.day == state.day) {
        playFixture(fixture);
      }
    }
  }

  MatchResult playFixture(
    Fixture fixture,
  ) {
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

  // ==========================================================
  // TRENING
  // ==========================================================

  TrainingResult trainPlayer(
    TrainingType type,
  ) {
    if (careerPlayer == null) {
      throw StateError(
        'Brak aktywnego zawodnika.',
      );
    }

    final player = careerPlayer!;

    if (player.fatigue >= 90) {
      throw StateError(
        'Zawodnik jest zbyt zmęczony na kolejny trening.',
      );
    }

    final result = trainingEngine.train(
      player,
      type,
    );

    player.fatigue = (
      player.fatigue + result.fatigue
    ).clamp(0, 100);

    player.fitness = (
      player.fitness - result.fatigue
    ).clamp(0, 100);

    player.refreshOverall();

    // Dobry trening wpływa na zaufanie trenera.
    player.rewardTrainingTrust();

    return result;
  }

  // ==========================================================
  // REGENERACJA
  // ==========================================================

  void recoverPlayer() {
    if (careerPlayer == null) {
      return;
    }

    final player = careerPlayer!;

    final recovery = player.fatigue >= 70
        ? 5
        : player.fatigue >= 40
            ? 8
            : 10;

    player.fatigue = (
      player.fatigue - recovery
    ).clamp(0, 100);

    player.fitness = (
      player.fitness + recovery
    ).clamp(0, 100);
  }

  // ==========================================================
  // FORMA ZAWODNIKA
  // ==========================================================

  void updatePlayerForm() {
    if (careerPlayer == null) {
      return;
    }

    final player = careerPlayer!;

    if (player.fatigue >= 80) {
      player.form = (
        player.form - 2
      ).clamp(0, 100);
    } else if (player.fatigue >= 60) {
      player.form = (
        player.form - 1
      ).clamp(0, 100);
    } else if (player.fatigue <= 25) {
      player.form = (
        player.form + 1
      ).clamp(0, 100);
    }
  }

  // ==========================================================
  // KROK 30
  // DECYZJA TRENERA O STATUSIE ZAWODNIKA
  // ==========================================================

  void updateCareerPlayerMatchStatus() {
    if (careerPlayer == null) {
      return;
    }

    final player = careerPlayer!;

    // Jeżeli zawodnik nie ma klubu,
    // nie może być wybierany do kadry.
    if (player.clubId == null) {
      player.inMatchSquad = false;
      player.isStarter = false;
      player.squadStatus = 'Bez klubu';
      return;
    }

    // Trener aktualizuje status na podstawie:
    // - zaufania,
    // - kondycji,
    // - zmęczenia.
    player.updateMatchStatus();

    // Jeżeli zawodnik nie może zagrać,
    // nie może być podstawowym zawodnikiem.
    if (!player.canPlayMatch) {
      player.isStarter = false;
    }
  }

  // ==========================================================
  // PRZYPISANIE DO KLUBU
  // ==========================================================

  void assignPlayerToClub(
    String clubId,
  ) {
    if (careerPlayer == null) {
      throw StateError(
        'Najpierw utwórz zawodnika.',
      );
    }

    final club = clubs.firstWhere(
      (club) => club.id == clubId,
    );

    final player = careerPlayer!;

    player.clubId = clubId;

    // Numer zawodnika
    player.shirtNumber = 27;

    // Początkowe zaufanie trenera.
    player.managerRelationship = 50;

    // Początkowy status zawodnika.
    player.updateMatchStatus();

    final marketValue =
        calculateStartingMarketValue(
      player,
      club,
    );

    final salary =
        calculateStartingSalary(
      player,
      club,
    );

    player.contract = PlayerContract(
      clubId: club.id,
      yearsRemaining: 3,
      weeklySalary: salary,
      marketValue: marketValue,
      squadNumber: player.shirtNumber,
      squadStatus: player.squadStatus,
      managerTrust: player.managerRelationship,
    );
  }

  // ==========================================================
  // WARTOŚĆ POCZĄTKOWA ZAWODNIKA
  // ==========================================================

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

  // ==========================================================
  // PENSJA POCZĄTKOWA
  // ==========================================================

  double calculateStartingSalary(
    PlayerCareer player,
    Club club,
  ) {
    const baseSalary = 150.0;

    final overallFactor =
        player.overall / 50;

    final clubFactor =
        club.overall / 70;

    return baseSalary *
        overallFactor *
        clubFactor;
  }

  // ==========================================================
  // TERMINARZ
  // ==========================================================

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

  // ==========================================================
  // DATA
  // ==========================================================

  String get currentDate {
    return state.dateString;
  }

  // ==========================================================
  // SEZON
  // ==========================================================

  int get currentSeason {
    return state.season;
  }

  // ==========================================================
  // OKNO TRANSFEROWE - LATO
  // ==========================================================

  bool get summerTransferWindow {
    return state.transferWindowSummer;
  }

  // ==========================================================
  // OKNO TRANSFEROWE - ZIMA
  // ==========================================================

  bool get winterTransferWindow {
    return state.transferWindowWinter;
  }

  // ==========================================================
  // KLUBY EKSTRAKLASY
  // ==========================================================

  List<Club> get leagueClubs {
    return clubs
        .where(
          (club) => club.leagueId == 'pol_ek',
        )
        .toList();
  }

  // ==========================================================
  // KLUBY DOSTĘPNE NA START KARIERY
  // ==========================================================

  List<Club> get careerStartClubs {
    return clubs
        .where(
          (club) => club.leagueId == 'pol_ek',
        )
        .toList();
  }

  // ==========================================================
  // WYBÓR KLUBU NA START KARIERY
  // ==========================================================

  void startCareerAtClub(
    String clubId,
  ) {
    if (careerPlayer == null) {
      throw StateError(
        'Najpierw utwórz zawodnika.',
      );
    }

    assignPlayerToClub(clubId);
  }

  // ==========================================================
  // AKTUALNY KLUB ZAWODNIKA
  // ==========================================================

  Club? get careerClub {
    if (careerPlayer == null) {
      return null;
    }

    final clubId = careerPlayer!.clubId;

    if (clubId == null) {
      return null;
    }

    for (final club in clubs) {
      if (club.id == clubId) {
        return club;
      }
    }

    return null;
  }

  // ==========================================================
  // CZY ZAWODNIK MA KLUB
  // ==========================================================

  bool get hasCareerClub {
    return careerPlayer?.clubId != null;
  }
}
