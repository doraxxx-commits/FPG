import 'player.dart';
import 'player_contract.dart';
import 'player_match_stats.dart';

class PlayerCareer {
  // ==========================================================
  // PODSTAWOWE INFORMACJE
  // ==========================================================

  final String id;

  String firstName;
  String lastName;
  String nationality;

  int age;
  int height;

  PlayerPosition position;

  // ==========================================================
  // UMIEJĘTNOŚCI
  // ==========================================================

  int overall;
  int potential;

  int pace;
  int shooting;
  int passing;
  int dribbling;
  int defending;
  int physical;

  // ==========================================================
  // FORMA / KONDYCJA
  // ==========================================================

  int stamina;
  int fitness;
  int fatigue;
  int form;

  // ==========================================================
  // PSYCHOLOGIA
  // ==========================================================

  int morale;
  int happiness;

  int managerRelationship;
  int teamRelationship;

  // ==========================================================
  // DOŚWIADCZENIE
  // ==========================================================

  int experience;
  int experienceToNextLevel;

  // ==========================================================
  // KLUB / KONTRAKT
  // ==========================================================

  String? clubId;

  int shirtNumber;

  // ==========================================================
  // STATUS W KADRZE
  // ==========================================================

  String squadStatus;

  // Czy zawodnik znajduje się w kadrze meczowej
  bool inMatchSquad;

  // Czy zawodnik jest aktualnie podstawowym zawodnikiem
  bool isStarter;

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

  final PlayerMatchStats matchStats;

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

    // Forma / kondycja
    this.stamina = 100,
    this.fitness = 100,
    this.fatigue = 0,
    this.form = 70,

    // Psychologia
    this.morale = 75,
    this.happiness = 75,

    // Relacje
    this.managerRelationship = 50,
    this.teamRelationship = 50,

    // Doświadczenie
    this.experience = 0,
    this.experienceToNextLevel = 100,

    // Klub
    this.clubId,
    this.shirtNumber = 1,

    // Status w kadrze
    this.squadStatus = 'Młody zawodnik',
    this.inMatchSquad = false,
    this.isStarter = false,

    // Kontrakt
    this.contract,

    // Statystyki kariery
    this.careerGoals = 0,
    this.careerAssists = 0,
    this.careerAppearances = 0,

    // Statystyki meczowe
    PlayerMatchStats? matchStats,
  }) : matchStats = matchStats ?? PlayerMatchStats();

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

  // ==========================================================
  // DODANIE GOLA DO KARIERY
  // ==========================================================

  void addCareerGoal() {
    careerGoals++;

    matchStats.addGoal();
  }

  // ==========================================================
  // DODANIE ASYSTY DO KARIERY
  // ==========================================================

  void addCareerAssist() {
    careerAssists++;

    matchStats.addAssist();
  }

  // ==========================================================
  // DODANIE WYSTĘPU
  // ==========================================================

  void addCareerAppearance({
    required int minutes,
    required bool started,
    required double rating,
  }) {
    careerAppearances++;

    matchStats.addAppearance(
      playedMinutes: minutes,
      started: started,
      rating: rating,
    );
  }
}
