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

    fixtures = FixtureGenerator.generateDoubleRoundRobin(
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

    updateCareerPlayerMatchStatus();

    playMatchesForToday();

    AITransferEngine.processAITransfers(
      clubs: clubs,
      players: players,
      isSummerWindow: summerTransferWindow,
      isWinterWindow: winterTransferWindow,
    );

    if (leagueEngine.isSeasonComplete()) {
      _advanceSeason();
    }
  }

  // ==========================================================
  // PRZEJŚCIE DO NOWEGO SEZONU
  // ==========================================================

  void _advanceSeason() {
    AgingEngine.processEndOfSeason(
      allPlayers: players,
      allClubs: clubs,
    );

    if (careerPlayer != null) {
      careerPlayer!.age += 1;
    }

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

  bool get careerPlayerInMatchSquad {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.inMatchSquad;
  }

  bool get careerPlayerIsStarter {
    if (careerPlayer == null) {
      return false;
    }

    return careerPlayer!.isRegularStarter;
  }

  String get careerPlayerMatchStatus {
    if (careerPlayer == null) {
      return 'Brak zawodnika';
    }

    return careerPlayer!.squadStatus;
  }

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

    final isCareerPlayerHome = fixture.homeClubId == player.clubId;
    final isCareerPlayerAway = fixture.awayClubId == player.clubId;

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
      final rating = _generateMatchRating(player, minutes);
      final goals = _generateGoals(player, rating);
      final assists = _generateAssists(player, rating);

      player.processMatchPerformance(
        minutes: minutes,
        started: true,
        rating: rating,
        goals: goals,
        assists: assists,
      );

      return;
    }

    final substitutionChance = _calculateSubstitutionChance(player);
    final roll = _random.nextInt(100);

    if (roll >= substitutionChance) {
      return;
    }

    final minutes = _generateSubstituteMinutes();
    final rating = _generateMatchRating(player, minutes);
    final goals = _generateGoals(player, rating);
    final assists = _generateAssists(player, rating);

    player.processMatchPerformance(
      minutes: minutes,
      started: false,
      rating: rating,
      goals: goals,
      assists: assists,
    );
  }

  int _generateStarterMinutes(PlayerCareer player) {
    int minimum = 65;
    int maximum = 95;

    if (player.fitness >= 85) {
      minimum = 80;
      maximum = 95;
    } else if (player.fitness <= 50) {
      minimum = 55;
      maximum = 80;
    }

    return minimum + _random.nextInt(maximum - minimum + 1);
  }

  int _generateSubstituteMinutes() {
    return 15 + _random.nextInt(31);
  }

  int _calculateSubstitutionChance(PlayerCareer player) {
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

  double _generateMatchRating(PlayerCareer player, int minutes) {
    double rating = 6.0;

    rating += (player.overall - 50) * 0.035;
    rating += (player.form - 50) * 0.018;
    rating += (player.fitness - 70) * 0.008;
    rating += (player.managerRelationship - 50) * 0.006;
    rating += (_random.nextDouble() * 1.8) - 0.9;

    if (minutes < 30) {
      rating += (_random.nextDouble() * 1.0) - 0.5;
    }

    return rating.clamp(4.0, 9.5);
  }

  int _generateGoals(PlayerCareer player, double rating) {
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

    chance += player.overall * 0.0008;
    chance += player.shooting * 0.0007;

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

  int _generateAssists(PlayerCareer player, double rating) {
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

    chance += player.passing * 0.0006;
    chance += player.dribbling * 0.0003;

    if (rating >= 8.0) {
      chance += 0.025;
    }

    if (_random.nextDouble() < chance) {
      return 1;
    }

    return 0;
  }

  // ==========================================================
  // TRENING & REGENERACJA
  // ==========================================================

  TrainingResult trainPlayer(TrainingType type) {
    if (careerPlayer == null) {
      throw StateError('Brak aktywnego zawodnika.');
    }

    final player = careerPlayer!;

    if (player.fatigue >= 90) {
      throw StateError('Zawodnik jest zbyt zmęczony na kolejny trening.');
    }

    final result = trainingEngine.train(player, type);

    player.fatigue = (player.fatigue + result.fatigue).clamp(0, 100);
    player.fitness = (player.fitness - result.fatigue).clamp(0, 100);

    player.refreshOverall();
    player.rewardTrainingTrust();

    return result;
  }

  void recoverPlayer() {
    if (careerPlayer == null) return;
    final player = careerPlayer!;

    final recovery = player.fatigue >= 70
        ? 5
        : player.fatigue >= 40
            ? 8
            : 10;

    player.fatigue = (player.fatigue - recovery).clamp(0, 100);
    player.fitness = (player.fitness + recovery).clamp(0, 100);
  }

  void updatePlayerForm() {
    if (careerPlayer == null) return;
    final player = careerPlayer!;

    if (player.fatigue >= 80) {
      player.form = (player.form - 2).clamp(0, 100);
    } else if (player.fatigue >= 60) {
      player.form = (player.form - 1).clamp(0, 100);
    } else if (player.fatigue <= 25) {
      player.form = (player.form + 1).clamp(0, 100);
    }
  }

  void updateCareerPlayerMatchStatus() {
    if (careerPlayer == null) return;
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

  void assignPlayerToClub(String clubId) {
    if (careerPlayer == null) {
      throw StateError('Najpierw utwórz zawodnika.');
    }

    final club = clubs.firstWhere((c) => c.id == clubId);
    final player = careerPlayer!;

    player.clubId = clubId;
    player.shirtNumber = 27;
    player.managerRelationship = 50;
    player.updateMatchStatus();

    final marketValue = calculateStartingMarketValue(player, club);
    final salary = calculateStartingSalary(player, club);

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

  double calculateStartingMarketValue(PlayerCareer player, Club club) {
    final ageFactor = player.age <= 21
        ? 1.25
        : player.age <= 25
            ? 1.10
            : 0.90;

    final potentialFactor = player.potential / 70;
    final clubFactor = club.overall / 70;

    return 250000 * player.overall * ageFactor * potentialFactor * clubFactor;
  }

  double calculateStartingSalary(PlayerCareer player, Club club) {
    const baseSalary = 150.0;
    final overallFactor = player.overall / 50;
    final clubFactor = club.overall / 70;

    return baseSalary * overallFactor * clubFactor;
  }

  // ==========================================================
  // GETTERY DANYCH
  // ==========================================================

  List<Fixture> get todayFixtures => fixtures.where(
        (f) => f.year == state.year && f.month == state.month && f.day == state.day,
      ).toList();

  List<Fixture> get playedFixtures => fixtures.where((f) => f.played).toList();
  List<Fixture> get upcomingFixtures => fixtures.where((f) => !f.played).toList();

  String get currentDate => state.dateString;
  int get currentSeason => state.season;

  bool get summerTransferWindow => state.transferWindowSummer;
  bool get winterTransferWindow => state.transferWindowWinter;

  List<Club> get leagueClubs => clubs.where((c) => c.leagueId == 'pol_ek').toList();
  List<Club> get careerStartClubs => clubs.where((c) => c.leagueId == 'pol_ek').toList();

  void startCareerAtClub(String clubId) {
    if (careerPlayer == null) {
      throw StateError('Najpierw utwórz zawodnika.');
    }
    assignPlayerToClub(clubId);
  }

  Club? get careerClub {
    if (careerPlayer == null || careerPlayer!.clubId == null) return null;
    return clubs.firstWhere((c) => c.id == careerPlayer!.clubId);
  }

  bool get hasCareerClub => careerPlayer?.clubId != null;
}
