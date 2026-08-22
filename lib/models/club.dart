class Club {
  // ==========================================================
  // PODSTAWOWE INFORMACJE
  // ==========================================================

  final String id;

  String name;
  String country;
  String leagueId;

  // ==========================================================
  // SIŁA KLUBU
  // ==========================================================

  int overall;
  int budget;

  int reputation;
  int financialHealth;

  // ==========================================================
  // KADRA ZAWODNIKÓW
  // ==========================================================
  //
  // Lista ID zawodników należących do klubu.
  //
  // Dzięki temu później MatchEngine będzie mógł:
  //
  // klub
  //   ↓
  // jego zawodnicy
  //   ↓
  // występ zawodników
  //   ↓
  // PlayerMatchPerformance
  //
  // Domyślnie lista jest pusta, dzięki czemu wszystkie
  // dotychczasowe dane WorldData nadal będą działać.
  // ==========================================================

  final List<String> playerIds;

  // ==========================================================
  // KONSTRUKTOR
  // ==========================================================

  Club({
    required this.id,
    required this.name,
    required this.country,
    required this.leagueId,
    required this.overall,
    required this.budget,
    this.reputation = 50,
    this.financialHealth = 75,
    List<String>? playerIds,
  }) : playerIds = playerIds ?? [];

  // ==========================================================
  // DODANIE ZAWODNIKA DO KLUBU
  // ==========================================================

  void addPlayer(
    String playerId,
  ) {
    if (playerId.isEmpty) {
      return;
    }

    if (playerIds.contains(playerId)) {
      return;
    }

    playerIds.add(playerId);
  }

  // ==========================================================
  // USUNIĘCIE ZAWODNIKA Z KLUBU
  // ==========================================================

  void removePlayer(
    String playerId,
  ) {
    playerIds.remove(playerId);
  }

  // ==========================================================
  // CZY KLUB POSIADA ZAWODNIKA
  // ==========================================================

  bool hasPlayer(
    String playerId,
  ) {
    return playerIds.contains(playerId);
  }

  // ==========================================================
  // LICZBA ZAWODNIKÓW
  // ==========================================================

  int get squadSize {
    return playerIds.length;
  }

  // ==========================================================
  // CZY KLUB MA KADRĘ
  // ==========================================================

  bool get hasSquad {
    return playerIds.isNotEmpty;
  }
}
