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

  // ==========================================================
  // SERIALIZACJA JSON (SAVE / LOAD)
  // ==========================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'position': position.name,
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'dribbling': dribbling,
      'defending': defending,
      'physical': physical,
      'value': value,
      'weeklyWage': weeklyWage,
      'clubId': clubId,
      'morale': morale,
      'fitness': fitness,
      'form': form,
      'fatigue': fatigue,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      position: PlayerPosition.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => PlayerPosition.striker,
      ),
      pace: json['pace'] as int,
      shooting: json['shooting'] as int,
      passing: json['passing'] as int,
      dribbling: json['dribbling'] as int,
      defending: json['defending'] as int,
      physical: json['physical'] as int,
      value: json['value'] as int,
      weeklyWage: json['weeklyWage'] as int,
      clubId: json['clubId'] as String,
      morale: json['morale'] as int? ?? 75,
      fitness: json['fitness'] as int? ?? 100,
      form: json['form'] as int? ?? 70,
      fatigue: json['fatigue'] as int? ?? 0,
    );
  }
}
