import 'dart:math';

import '../data/world_data.dart';

import '../models/club.dart';
import '../models/fixture.dart';
import '../models/league.dart';
import '../models/match_result.dart';
import '../models/player.dart';
import '../models/player_career.dart';
import '../models/player_contract.dart';

import '../simulation/aging_engine.dart';
import '../simulation/fixture_generator.dart';
import '../simulation/league_engine.dart';
import '../simulation/match_engine.dart';
import '../simulation/transfer_engine.dart';

import 'game_state.dart';
import 'training_engine.dart';

class GameEngine {
  final GameState state;

  late final List<League> leagues;
  late final List<Club> clubs;
  late final List<Player> players;

  late final LeagueEngine leagueEngine;
  late final MatchEngine matchEngine;

  late List<Fixture> fixtures;

  final TrainingEngine trainingEngine = TrainingEngine();

  final Random _random = Random();

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
  // NASTĘPNY DZIEŃ / UI ALIAS
  // ==========================================================

  void nextDay() {
    advanceDay();
  }

  void advanceDay() {
    state.nextDay();

    recoverPlayer();

    updatePlayerForm();

    // Trener podejmuje decyzję o statusie zawodnika.
    updateCareerPlayerMatchStatus();

    playMatchesForToday();

    // Symulacja autonomicznych transferów AI w trakcie okienek
    AITransferEngine.processAITransfers(
      clubs: clubs,
      players: players,
      isSummerWindow: summerTransferWindow,
      isWinterWindow: winterTransferWindow,
    );

    // Sprawdzenie zakończenia sezonu
    if (leagueEngine.isSeasonComplete()) {
      _advanceSeason();
    }
  }

  // ==========================================================
  // PRZEJŚCIE DO NOWEGO SEZONU
  // ==========================================================

  void _advanceSeason() {
    // 1. Uruchomienie silnika starzenia, rozwoju i regenów
    AgingEngine.processEndOfSeason(
      allPlayers: players,
      allClubs: clubs,
    );

    // 2. Starzenie gracza kariery
    if (careerPlayer != null) {
      careerPlayer!.age += 1;
    }

    // 3. Reset tabeli i wygenerowanie nowego terminarza
    final leagueClubs = clubs
        .where(
          (club) => club.leagueId == 'pol_ek',
        )
        .toList();

    fixtures = FixtureGenerator.generateDoubleRoundRobin(leagueClubs);
    leagueEngine.resetSeason();
  }

  // ==========================================================
  // INFORMACJE O UDZIALE ZAWODNIKA W MECZU
  // ==========================================================

  bool get careerPlayerCanPlay {
    if (careerPlayer == null) {
      return false;
    }

    final player = careerPlayer!;

    if (player.clubId == null) {
      return false;
    }

    player.updateMatchStatus();

    return player.canPlayMatch;
  }

  // ==========================================================
  // CZY ZAWODNIK JEST W KADRZE MECZOWEJ
  // ==========================================================

  bool get careerPlayerInMatchSquad {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.inMatchSquad;
  }

  // ==========================================================
  // CZY ZAWODNIK JEST W PODSTAWOWYM SKŁADZIE
  // ==========================================================

  bool get careerPlayerIsStarter {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.isRegularStarter;
  }

  // ==========================================================
  // STATUS MECZOWY ZAWODNIKA
  // ==========================================================

  String get careerPlayerMatchStatus {
    if (careerPlayer == null) {
      return 'Brak zawodnika';
    }

    return careerPlayer!.squadStatus;
  }

  // ==========================================================
  // OSTATNI WYNIK WYSTĘPU ZAWODNIKA
  // ==========================================================

  String get careerPlayerLastMatchSummary {
    if (careerPlayer == null) {
      return 'Brak danych';
    }

    final player = careerPlayer!;

    if (player.careerAppearances <= 0) {
      return 'Brak rozegranych meczów';
    }

    return 'Występy: ${player.careerAppearances} | '
        'Gole: ${player.careerGoals} | '
        'Asysty: ${player.careerAssists}';
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

  // ==========================================================
  // ROZGRYWANIE MECZU
  // ==========================================================

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

    _processCareerPlayerMatch(
      fixture,
    );

    return result;
  }

  // ==========================================================
  // OBSŁUGA WYSTĘPU ZAWODNIKA
  // ==========================================================

  void _processCareerPlayerMatch(
    Fixture fixture,
  ) {
    if (careerPlayer == null) {
      return;
    }

    final player = careerPlayer!;

    if (player.clubId == null) {
      return;
    }

    final isCareerPlayerHome =
        fixture.homeClubId == player.clubId;

    final isCareerPlayerAway =
        fixture.awayClubId == player.clubId;

    if (!isCareerPlayerHome && !isCareerPlayerAway) {
      return;
    }

    player.updateMatchStatus();

    if (!player.inMatchSquad) {
      return;
    }

    if (!player.canPlayMatch) {
      player.isStarter = false;
      return;
    }

    if (player.isStarter) {
      final minutes = _generateStarterMinutes(player);

      final rating = _generateMatchRating(
        player,
        minutes,
      );

      final goals = _generateGoals(player, rating);

      final assists = _generateAssists(
        player,
        rating,
      );

      player.processMatchPerformance(
        minutes: minutes,
        started: true,
        rating: rating,
        goals: goals,
        assists: assists,
      );

      return;
    }

    final substitutionChance =
        _calculateSubstitutionChance(player);

    final roll = _random.nextInt(100);

    if (roll >= substitutionChance) {
      return;
    }

    final minutes = _generateSubstituteMinutes();

    final rating = _generateMatchRating(
      player,
      minutes,
    );

    final goals = _generateGoals(
      player,
      rating,
    );

    final assists = _generateAssists(
      player,
      rating,
    );

    player.processMatchPerformance(
      minutes: minutes,
      started: false,
      rating: rating,
      goals: goals,
      assists: assists,
    );
  }

  // ==========================================================
  // MINUTY DLA PODSTAWOWEGO
  // ==========================================================

  int _generateStarterMinutes(
    PlayerCareer player,
  ) {
    int minimum = 65;
    int maximum = 95;

    if (player.fitness >= 85) {
      minimum = 80;
      maximum = 95;
    } else if (player.fitness <= 50) {
      minimum = 55;
      maximum = 80;
    }

    return minimum +
        _random.nextInt(
          maximum - minimum + 1,
        );
  }

  // ==========================================================
  // MINUTY DLA REZERWOWEGO
  // ==========================================================

  int _generateSubstituteMinutes() {
    return 15 +
        _random.nextInt(31);
  }

  // ==========================================================
  // SZANSA WEJŚCIA Z ŁAWKI
  // ==========================================================

  int _calculateSubstitutionChance(
    PlayerCareer player,
  ) {
    int chance;

    if (player.managerRelationship <= 30) {
      chance = 10;
    } else if (player.managerRelationship <= 40) {
      chance = 20;
    } else if (player.managerRelationship <= 50) {
      chance = 30;
    } else if (player.managerRelationship <= 60) {
      chance = 40;
    } else if (player.managerRelationship <= 70) {
      chance = 55;
    } else {
      chance = 70;
    }

    if (player.fitness >= 85) {
      chance += 10;
    } else if (player.fitness <= 40) {
      chance -= 15;
    }

    if (player.fatigue >= 70) {
      chance -= 15;
    }

    return chance.clamp(5, 90);
  }

  // ==========================================================
  // OCENA MECZOWA
  // ==========================================================

  double _generateMatchRating(
    PlayerCareer player,
    int minutes,
  ) {
    double rating = 6.0;

    rating +=
        (player.overall - 50) * 0.035;

    rating +=
        (player.form - 50) * 0.018;

    rating +=
        (player.fitness - 70) * 0.008;

    rating +=
        (player.managerRelationship - 50) * 0.006;

    rating +=
        (_random.nextDouble() * 1.8) - 0.9;

    if (minutes < 30) {
      rating +=
          (_random.nextDouble() * 1.0) - 0.5;
    }

    return rating.clamp(4.0, 9.5);
  }

  // ==========================================================
  // GOLE
  // ==========================================================

  int _generateGoals(
    PlayerCareer player,
    double rating,
  ) {
    double chance;

    switch (player.position) {
      case PlayerPosition.goalkeeper:
        chance = 0.003;
        break;

      case PlayerPosition.defender:
        chance = 0.015;
        break;

      case PlayerPosition.midfielder:
        chance = 0.035;
        break;

      case PlayerPosition.winger:
        chance = 0.055;
        break;

      case PlayerPosition.striker:
        chance = 0.080;
        break;
    }

    chance +=
        player.overall * 0.0008;

    chance +=
        player.shooting * 0.0007;

    if (rating >= 8.0) {
      chance += 0.025;
    }

    final roll = _random.nextDouble();

    if (roll < chance) {
      if (_random.nextDouble() < 0.15) {
        return 2;
      }

      return 1;
    }

    return 0;
  }

  // ==========================================================
  // ASYSTY
  // ==========================================================

  int _generateAssists(
    PlayerCareer player,
    double rating,
  ) {
    double chance;

    switch (player.position) {
      case PlayerPosition.goalkeeper:
        chance = 0.002;
        break;

      case PlayerPosition.defender:
        chance = 0.015;
        break;

      case PlayerPosition.midfielder:
        chance = 0.050;
        break;

      case PlayerPosition.winger:
        chance = 0.060;
        break;

      case PlayerPosition.striker:
        chance = 0.035;
        break;
    }

    chance +=
        player.passing * 0.0006;

    chance +=
        player.dribbling * 0.0003;

    if (rating >= 8.0) {
      chance += 0.025;
    }

    if (_random.nextDouble() < chance) {
      return 1;
    }

    return 0;
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
  // DECYZJA TRENERA O STATUSIE ZAWODNIKA
  // ==========================================================

  void updateCareerPlayerMatchStatus() {
    if (careerPlayer == null) {
      return;
    }

    final player = careerPlayer!;

    if (player.clubId == null) {
      player.inMatchSquad = false;
      player.isStarter = false;
      player.squadStatus = 'Bez klubu';
      return;
    }

    player.updateMatchStatus();

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

    player.shirtNumber = 27;

    player.managerRelationship = 50;

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
