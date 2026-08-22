enum PlayerPosition {
  goalkeeper,
  defender,
  midfielder,
  winger,
  striker,
}

class Player {
  final String id;
  final String name;
  int age;
  final PlayerPosition position;
  int overall;
  int potential;

  int pace;
  int shooting;
  int passing;
  int dribbling;
  int defending;
  int physical;

  double value;
  double weeklyWage;
  String? clubId;

  int fatigue;

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
    this.clubId,
    this.fatigue = 0,
  });
}
