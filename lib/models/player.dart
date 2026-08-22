enum PlayerPosition {
  goalkeeper,
  defender,
  midfielder,
  winger,
  striker,
}

class Player {
  final String id;
  String name;

  int age;
  PlayerPosition position;

  int pace;
  int shooting;
  int passing;
  int dribbling;
  int defending;
  int physical;

  int value;
  int weeklyWage;

  String clubId;

  int morale;
  int fitness;
  int form;

  // ZMĘCZENIE ZAWODNIKA
  int fatigue;

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.position,

    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,

    required this.value,
    required this.weeklyWage,

    required this.clubId,

    this.morale = 75,
    this.fitness = 100,
    this.form = 70,
    this.fatigue = 0,
  });

  // ==========================================================
  // OVR
  // ==========================================================

  int get overall {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return (
          physical * 0.30 +
          defending * 0.30 +
          passing * 0.20 +
          dribbling * 0.20
        ).round();

      case PlayerPosition.defender:
        return (
          defending * 0.40 +
          physical * 0.25 +
          passing * 0.20 +
          pace * 0.15
        ).round();

      case PlayerPosition.midfielder:
        return (
          passing * 0.30 +
          dribbling * 0.25 +
          shooting * 0.20 +
          physical * 0.15 +
          pace * 0.10
        ).round();

      case PlayerPosition.winger:
        return (
          dribbling * 0.30 +
          pace * 0.25 +
          shooting * 0.20 +
          passing * 0.15 +
          physical * 0.10
        ).round();

      case PlayerPosition.striker:
        return (
          shooting * 0.40 +
          dribbling * 0.25 +
          physical * 0.20 +
          pace * 0.15
        ).round();
    }
  }

  // ==========================================================
  // POTENCJAŁ
  // ==========================================================

  int get potential {
    final basePotential = overall + 10;

    if (age <= 18) {
      return basePotential.clamp(60, 94);
    }

    if (age <= 21) {
      return basePotential.clamp(60, 92);
    }

    if (age <= 24) {
      return basePotential.clamp(60, 90);
    }

    return basePotential.clamp(
      overall,
      88,
    );
  }
}
