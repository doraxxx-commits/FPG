import 'player.dart';
import 'player_contract.dart';
import 'player_match_stats.dart';

class PlayerCareer {
  final String id;

  String firstName;
  String lastName;

  String nationality;

  int age;
  int height;

  PlayerPosition position;

  int overall;
  int potential;

  int pace;
  int shooting;
  int passing;
  int dribbling;
  int defending;
  int physical;

  int stamina;
  int fitness;

  int morale;
  int happiness;

  int managerRelationship;
  int teamRelationship;

  String? clubId;

  int shirtNumber;

  PlayerContract? contract;

  // ==========================================================
  // STATYSTYKI KARIERY
  // ==========================================================

  int careerGoals;
  int careerAssists;
  int careerAppearances;

  // ==========================================================
  // STATYSTYKI MECZOWE
  // ==========================================================

  final PlayerMatchStats matchStats = PlayerMatchStats();

  // ==========================================================
  // KONSTRUKTOR
  // ==========================================================

  PlayerCareer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.age,
    required this.height,
    required this.position,
    required this.overall,
    required this.potential,
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
    this.stamina = 100,
    this.fitness = 100,
    this.morale = 75,
    this.happiness = 75,
    this.managerRelationship = 50,
    this.teamRelationship = 50,
    this.clubId,
    this.shirtNumber = 1,
    this.careerGoals = 0,
    this.careerAssists = 0,
    this.careerAppearances = 0,
  });

  // ==========================================================
  // PEŁNE IMIĘ I NAZWISKO
  // ==========================================================

  String get fullName {
    return '$firstName $lastName';
  }

  // ==========================================================
  // OVR
  // ==========================================================

  int calculateOverall() {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return (
          defending * 0.45 +
          physical * 0.20 +
          passing * 0.15 +
          pace * 0.10 +
          dribbling * 0.05 +
          shooting * 0.05
        ).round();

      case PlayerPosition.defender:
        return (
          defending * 0.45 +
          physical * 0.25 +
          pace * 0.15 +
          passing * 0.10 +
          dribbling * 0.05
        ).round();

      case PlayerPosition.midfielder:
        return (
          passing * 0.30 +
          dribbling * 0.20 +
          shooting * 0.15 +
          physical * 0.15 +
          pace * 0.10 +
          defending * 0.10
        ).round();

      case PlayerPosition.winger:
        return (
          pace * 0.30 +
          dribbling * 0.30 +
          shooting * 0.20 +
          passing * 0.10 +
          physical * 0.10
        ).round();

      case PlayerPosition.striker:
        return (
          shooting * 0.40 +
          pace * 0.20 +
          dribbling * 0.15 +
          physical * 0.15 +
          passing * 0.10
        ).round();
    }
  }

  // ==========================================================
  // ODŚWIEŻANIE OVR
  // ==========================================================

  void refreshOverall() {
    overall = calculateOverall().clamp(1, 99);
  }
}
