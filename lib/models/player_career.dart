import 'player.dart';
import 'player_contract.dart';

class PlayerCareer extends Player {
  final String firstName;
  final String lastName;
  final String nationality;
  final int height;

  int shirtNumber;

  int careerAppearances;
  int careerGoals;
  int careerAssists;
  double averageRating;

  int managerRelationship;
  bool inMatchSquad;
  bool isStarter;
  bool isRegularStarter;
  String squadStatus;

  int fitness;
  int form;

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
    this.inMatchSquad = true,
    this.isStarter = true,
    this.isRegularStarter = true,
    this.squadStatus = 'Wicekapitan / Podstawowy',
    this.fitness = 100,
    this.form = 70,
    this.contract,
  }) : super(
          name: '$firstName $lastName',
        );

  String get fullName => '$firstName $lastName';

  bool get canPlayMatch => fitness > 20;

  void refreshOverall() {
    int total = pace + shooting + passing + dribbling + defending + physical;
    overall = (total / 6).round();
  }

  void updateMatchStatus() {
    if (managerRelationship >= 70 && fitness >= 60) {
      isStarter = true;
      inMatchSquad = true;
      squadStatus = 'Podstawowy skład';
    } else if (managerRelationship >= 40 && fitness >= 40) {
      isStarter = false;
      inMatchSquad = true;
      squadStatus = 'Ławka rezerwowych';
    } else {
      isStarter = false;
      inMatchSquad = false;
      squadStatus = 'Poza kadrą';
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
      averageRating = ((averageRating * (careerAppearances - 1)) + rating) / careerAppearances;
    }
  }

  void addCareerGoal() {
    careerGoals++;
  }

  void addCareerAssist() {
    careerAssists++;
  }

  void processMatchPerformance({
    required int minutes,
    required bool started,
    required double rating,
    required int goals,
    required int assists,
  }) {
    addCareerAppearance(minutes: minutes, started: started, rating: rating);
    for (int i = 0; i < goals; i++) {
      addCareerGoal();
    }
    for (int i = 0; i < assists; i++) {
      addCareerAssist();
    }
  }

  void rewardTrainingTrust() {
    managerRelationship = (managerRelationship + 2).clamp(0, 100);
  }
}
