import '../models/club.dart';
import '../models/standing.dart';

class LeagueEngine {
  final List<Club> clubs;
  final Map<String, Standing> standings = {};

  LeagueEngine({
    required this.clubs,
  }) {
    _initialize();
  }

  // ==========================================================
  // INICJALIZACJA TABELI
  // ==========================================================

  void _initialize() {
    standings.clear();

    for (final club in clubs) {
      standings[club.id] = Standing(
        clubId: club.id,
      );
    }
  }

  // ==========================================================
  // TABELA LIGOWA
  // ==========================================================

  List<Standing> get table {
    final result = standings.values.toList();

    result.sort((a, b) {
      // 1. Punkty
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }

      // 2. Bilans bramkowy
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // 3. Bramki strzelone
      if (a.goalsFor != b.goalsFor) {
        return b.goalsFor.compareTo(a.goalsFor);
      }

      // 4. Liczba zwycięstw
      return b.wins.compareTo(a.wins);
    });

    return result;
  }

  // ==========================================================
  // DODANIE WYNIKU MECZU
  // ==========================================================

  void recordMatch({
    required String homeClubId,
    required String awayClubId,
    required int homeGoals,
    required int awayGoals,
  }) {
    final home = standings[homeClubId];
    final away = standings[awayClubId];

    if (home == null || away == null) {
      return;
    }

    // Mecze rozegrane
    home.played++;
    away.played++;

    // Bramki
    home.goalsFor += homeGoals;
    home.goalsAgainst += awayGoals;

    away.goalsFor += awayGoals;
    away.goalsAgainst += homeGoals;

    // Wynik
    if (homeGoals > awayGoals) {
      home.wins++;
      away.losses++;
    } else if (homeGoals < awayGoals) {
      away.wins++;
      home.losses++;
    } else {
      home.draws++;
      away.draws++;
    }
  }

  // ==========================================================
  // SPRAWDZENIE KOŃCA SEZONU
  // ==========================================================

  bool isSeasonComplete() {
    if (clubs.isEmpty) {
      return false;
    }

    // Dla ligi każdy klub powinien rozegrać:
    // (liczba klubów - 1) * 2 meczów.
    final requiredMatches = (clubs.length - 1) * 2;

    for (final club in clubs) {
      final standing = standings[club.id];

      if (standing == null) {
        return false;
      }

      if (standing.played < requiredMatches) {
        return false;
      }
    }

    return true;
  }

  // ==========================================================
  // RESET SEZONU
  // ==========================================================

  void resetSeason() {
    _initialize();
  }
}
