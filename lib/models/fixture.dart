class Fixture {
  final int round;
  final String homeClubId;
  final String awayClubId;

  bool played;
  int? homeGoals;
  int? awayGoals;

  Fixture({
    required this.round,
    required this.homeClubId,
    required this.awayClubId,
    this.played = false,
    this.homeGoals,
    this.awayGoals,
  });
}
