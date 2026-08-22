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

  int overall;
  int potential;

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

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.overall,
    required this.potential,
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
  });
}
