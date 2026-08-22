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

  // ==========================================================
  // ZAUFANIE TRENERA / RELACJE
  // ==========================================================

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

    // Zaufanie trenera
    this.managerRelationship = 50,
    this.teamRelationship = 50,

    // Doświadczenie
    this.experience = 0,
    this.experienceToNextLevel = 100,

    // Klub
    this.clubId,
    this.shirtNumber = 1,

    // Status
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
  // ZAUFANIE TRENERA
  // ==========================================================

  void increaseManagerTrust(int amount) {
    if (amount <= 0) {
      return;
    }

    managerRelationship =
        (managerRelationship + amount).clamp(0, 100);

    _updateSquadStatusFromTrust();
  }

  void decreaseManagerTrust(int amount) {
    if (amount <= 0) {
      return;
    }

    managerRelationship =
        (managerRelationship - amount).clamp(0, 100);

    _updateSquadStatusFromTrust();
  }

  // ==========================================================
  // POZIOM ZAUFANIA TRENERA
  // ==========================================================

  String get managerTrustLevel {
    if (managerRelationship <= 20) {
      return 'Brak zaufania';
    }

    if (managerRelationship <= 40) {
      return 'Niskie zaufanie';
    }

    if (managerRelationship <= 60) {
      return 'Normalne zaufanie';
    }

    if (managerRelationship <= 80) {
      return 'Duże zaufanie';
    }

    return 'Kluczowy zawodnik';
  }

  // ==========================================================
  // STATUS ZAWODNIKA NA PODSTAWIE ZAUFANIA
  // ==========================================================

  void _updateSquadStatusFromTrust() {
    if (managerRelationship <= 20) {
      squadStatus = 'Poza planami trenera';
      inMatchSquad = false;
      isStarter = false;
      return;
    }

    if (managerRelationship <= 40) {
      squadStatus = 'Rezerwowy';
      isStarter = false;
      return;
    }

    if (managerRelationship <= 60) {
      squadStatus = 'Rotacja';
      isStarter = false;
      return;
    }

    if (managerRelationship <= 80) {
      squadStatus = 'Podstawowy zawodnik';
      return;
    }

    squadStatus = 'Kluczowy zawodnik';
    isStarter = true;
  }

  // ==========================================================
  // DODANIE GOLA DO KARIERY
  // ==========================================================

  void addCareerGoal() {
    careerGoals++;

    matchStats.addGoal();

    // Dobry wpływ na zaufanie trenera.
    increaseManagerTrust(3);
  }

  // ==========================================================
  // DODANIE ASYSTY DO KARIERY
  // ==========================================================

  void addCareerAssist() {
    careerAssists++;

    matchStats.addAssist();

    // Dobry wpływ na zaufanie trenera.
    increaseManagerTrust(2);
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

    // Występ od pierwszej minuty daje mały bonus.
    if (started) {
      increaseManagerTrust(1);
    }

    // Dobra ocena = większe zaufanie.
    if (rating >= 7.0) {
      increaseManagerTrust(2);
    }

    if (rating >= 8.0) {
      increaseManagerTrust(2);
    }

    // Bardzo słaby występ = utrata zaufania.
    if (rating < 5.5) {
      decreaseManagerTrust(2);
    }

    if (rating < 5.0) {
      decreaseManagerTrust(2);
    }
  }

  // ==========================================================
  // ZAUFANIE ZA TRENING
  // ==========================================================

  void rewardTrainingTrust() {
    increaseManagerTrust(1);
  }

  // ==========================================================
  // KARA ZA OPUSZCZENIE TRENINGU / ZŁĄ FORMĘ
  // ==========================================================

  void penalizeTrainingTrust() {
    decreaseManagerTrust(1);
  }

    // ==========================================================
  // DECYZJA TRENERA PRZED MECZEM
  // ==========================================================

  void updateMatchStatus() {
    // Bardzo niskie zaufanie.
    // Zawodnik nie znajduje się w kadrze.
    if (managerRelationship <= 20) {
      squadStatus = 'Poza planami trenera';
      inMatchSquad = false;
      isStarter = false;
      return;
    }

    // Niskie zaufanie.
    // Zawodnik jest rezerwowym.
    if (managerRelationship <= 40) {
      squadStatus = 'Rezerwowy';
      inMatchSquad = true;
      isStarter = false;
      return;
    }

    // Średnie zaufanie.
    // Zawodnik jest w rotacji.
    if (managerRelationship <= 60) {
      squadStatus = 'Rotacja';
      inMatchSquad = true;
      isStarter = false;
      return;
    }

    // Duże zaufanie.
    // Zawodnik najczęściej wychodzi w pierwszym składzie.
    if (managerRelationship <= 80) {
      squadStatus = 'Podstawowy zawodnik';
      inMatchSquad = true;
      isStarter = true;
      return;
    }

    // Bardzo duże zaufanie.
    // Zawodnik jest kluczową postacią zespołu.
    squadStatus = 'Kluczowy zawodnik';
    inMatchSquad = true;
    isStarter = true;
  }

  // ==========================================================
  // CZY ZAWODNIK MOŻE ZAGRAĆ
  // ==========================================================

  bool get canPlayMatch {
    if (!inMatchSquad) {
      return false;
    }

    if (fitness <= 20) {
      return false;
    }

    if (fatigue >= 95) {
      return false;
    }

    return true;
  }

  // ==========================================================
  // CZY ZAWODNIK JEST PODSTAWOWYM
  // ==========================================================

  bool get isRegularStarter {
    return isStarter && inMatchSquad && canPlayMatch;
  }

  // ==========================================================
  // RĘCZNE USTAWIENIE STATUSU
  // ==========================================================

  void setMatchSquadStatus({
    required bool selected,
    required bool starter,
  }) {
    inMatchSquad = selected;

    if (!selected) {
      isStarter = false;
      return;
    }

    if (starter && canPlayMatch) {
      isStarter = true;
    } else {
      isStarter = false;
    }
  }
}
