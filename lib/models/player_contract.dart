class PlayerContract {
  String clubId;

  int yearsRemaining;

  double weeklySalary;

  double marketValue;

  int squadNumber;

  String squadStatus;

  int managerTrust;

  PlayerContract({
    required this.clubId,
    required this.yearsRemaining,
    required this.weeklySalary,
    required this.marketValue,
    required this.squadNumber,
    this.squadStatus = 'Młody zawodnik',
    this.managerTrust = 50,
  });
}

import 'squad_status.dart';

class PlayerContract {
  String clubId;

  int yearsRemaining;
  double weeklySalary;
  double marketValue;

  int squadNumber;

  SquadStatus squadStatus;

  int managerTrust;

  PlayerContract({
    required this.clubId,
    required this.yearsRemaining,
    required this.weeklySalary,
    required this.marketValue,
    required this.squadNumber,
    this.squadStatus = SquadStatus.reserves,
    this.managerTrust = 50,
  });
}
