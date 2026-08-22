class Club {
  final String id;
  String name;
  String country;
  String leagueId;

  int overall;
  int budget;

  int reputation;
  int financialHealth;

  Club({
    required this.id,
    required this.name,
    required this.country,
    required this.leagueId,
    required this.overall,
    required this.budget,
    this.reputation = 50,
    this.financialHealth = 75,
  });
}
