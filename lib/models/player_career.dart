import 'player.dart';
import 'player_contract.dart';

/// Statystyki występów zawodnika.
class MatchStats {
  int appearances;
  int starts;
  int substituteAppearances;
  int minutes;
  int goals;
  int assists;
  int yellowCards;
  int redCards;
  int shots;
  int shotsOnTarget;
  int keyPasses;
  int successfulDribbles;
  double averageRating;

  MatchStats({
    this.appearances = 0,
    this.starts = 0,
    this.substituteAppearances = 0,
    this.minutes = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.shots = 0,
    this.shotsOnTarget = 0,
    this.keyPasses = 0,
    this.successfulDribbles = 0,
    this.averageRating = 6.0,
  });

  void addAppearance({
    required int minutes,
    required bool started,
    required double rating,
    required int goals,
    required int assists,
  }) {
    appearances++;

    if (started) {
      starts++;
    } else {
      substituteAppearances++;
    }

    this.minutes += minutes;
    this.goals += goals;
    this.assists += assists;

    if (appearances == 1) {
      averageRating = rating;
    } else {
      averageRating =
          ((averageRating * (appearances - 1)) + rating) / appearances;
    }

    // Proste generowanie dodatkowych statystyk meczowych.
    shots += goals > 0 ? goals + 1 : 1;

    if (rating >= 7.0) {
      shotsOnTarget++;
    }

    if (rating >= 7.5) {
      keyPasses++;
    }

    if (rating >= 7.0) {
      successfulDribbles++;
    }
  }

  void resetSeason() {
    appearances = 0;
    starts = 0;
    substituteAppearances = 0;
    minutes = 0;
    goals = 0;
    assists = 0;
    yellowCards = 0;
    redCards = 0;
    shots = 0;
    shotsOnTarget = 0;
    keyPasses = 0;
    successfulDribbles = 0;
    averageRating = 6.0;
  }
}

class PlayerCareer extends Player {
  final String firstName;
  final String lastName;
  final String nationality;
  final int height;

  int shirtNumber;

  // ==========================================================
  // KARIERA
  // ==========================================================

  int careerAppearances;
  int careerGoals;
  int careerAssists;
  double averageRating;

  // ==========================================================
  // RELACJE / MORALE
  // ==========================================================

  int managerRelationship;
  int morale;
  int happiness;
  int teamRelationship;

  // ==========================================================
  // STATUS W DRUŻYNIE
  // ==========================================================

  bool inMatchSquad;
  bool isStarter;
  bool isRegularStarter;
  String squadStatus;

  // ==========================================================
  // FORMA / KONDYCJA
  // ==========================================================

  int fitness;
  int form;
  int fatigue;

  // ==========================================================
  // STATYSTYKI MECZOWE
  // ==========================================================

  final MatchStats matchStats;

  // ==========================================================
  // KONTRAKT
  // ==========================================================

  PlayerContract? contract;

  PlayerCareer({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required super.age,
    required this.height,
    required super.position,
    required super.overall,
    required super.potential,
    required super.pace,
    required super.shooting,
    required super.passing,
    required super.dribbling,
    required super.defending,
    required super.physical,

    super.value = 250000.0,
    super.weeklyWage = 500.0,
    super.clubId,

    this.shirtNumber = 10,

    this.careerAppearances = 0,
    this.careerGoals = 0,
    this.careerAssists = 0,
    this.averageRating = 6.0,

    this.managerRelationship = 50,
    this.morale = 70,
    this.happiness = 70,
    this.teamRelationship = 50,

    this.inMatchSquad = true,
    this.isStarter = true,
    this.isRegularStarter = true,
    this.squadStatus = 'Podstawowy',

    this.fitness = 100,
    this.form = 70,
    this.fatigue = 0,

    MatchStats? matchStats,

    this.contract,
  })  : matchStats = matchStats ?? MatchStats(),
        super(
          name: '$firstName $lastName',
        );

  // ==========================================================
  // PODSTAWOWE GETTERY
  // ==========================================================

  String get fullName => '$firstName $lastName';

  bool get canPlayMatch => fitness > 20;

  // ==========================================================
  // ODŚWIEŻENIE OVR
  // ==========================================================

  void refreshOverall() {
    final total =
        pace +
        shooting +
        passing +
        dribbling +
        defending +
        physical;

    overall = (total / 6).round();
  }

  // ==========================================================
  // STATUS MECZOWY
  // ==========================================================

  void updateMatchStatus() {
    if (managerRelationship >= 70 && fitness >= 60) {
      isStarter = true;
      isRegularStarter = true;
      inMatchSquad = true;
      squadStatus = 'Podstawowy skład';
    } else if (managerRelationship >= 40 && fitness >= 40) {
      isStarter = false;
      isRegularStarter = false;
      inMatchSquad = true;
      squadStatus = 'Ławka rezerwowych';
    } else {
      isStarter = false;
      isRegularStarter = false;
      inMatchSquad = false;
      squadStatus = 'Poza kadrą';
    }
  }

  // ==========================================================
  // WYSTĘP W MECZU
  // ==========================================================

  void processMatchPerformance({
    required int minutes,
    required bool started,
    required double rating,
    required int goals,
    required int assists,
  }) {
    addCareerAppearance(
      minutes: minutes,
      started: started,
      rating: rating,
    );

    for (int i = 0; i < goals; i++) {
      addCareerGoal();
    }

    for (int i = 0; i < assists; i++) {
      addCareerAssist();
    }

    // Wpływ występu na formę i morale.
    if (rating >= 7.5) {
      form = (form + 2).clamp(0, 100);
      morale = (morale + 2).clamp(0, 100);
      happiness = (happiness + 2).clamp(0, 100);
    } else if (rating < 5.5) {
      form = (form - 2).clamp(0, 100);
      morale = (morale - 1).clamp(0, 100);
      happiness = (happiness - 1).clamp(0, 100);
    }
  }

  void addCareerAppearance({
    required int minutes,
    required bool started,
    required double rating,
  }) {
    careerAppearances++;

    if (careerAppearances == 1) {
      averageRating = rating;
    } else {
      averageRating =
          ((averageRating * (careerAppearances - 1)) + rating) /
          careerAppearances;
    }

    matchStats.addAppearance(
      minutes: minutes,
      started: started,
      rating: rating,
      goals: 0,
      assists: 0,
    );
  }

  void addCareerGoal() {
    careerGoals++;
    matchStats.goals++;
  }

  void addCareerAssist() {
    careerAssists++;
    matchStats.assists++;
  }

  // ==========================================================
  // TRENING
  // ==========================================================

  void rewardTrainingTrust() {
    managerRelationship =
        (managerRelationship + 2).clamp(0, 100);

    teamRelationship =
        (teamRelationship + 1).clamp(0, 100);

    morale =
        (morale + 1).clamp(0, 100);
  }

  // ==========================================================
  // NOWY SEZON
  // ==========================================================

  void resetSeasonMatchStats() {
    matchStats.resetSeason();
  }
}
