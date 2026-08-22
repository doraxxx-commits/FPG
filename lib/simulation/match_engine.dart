import 'dart:math';

import '../models/club.dart';
import '../models/match_result.dart';

class MatchEngine {
  final Random _random;

  MatchEngine({
    Random? random,
  }) : _random = random ?? Random();

  // ==========================================================
  // SYMULACJA MECZU
  // ==========================================================

  MatchResult simulate({
    required Club home,
    required Club away,
  }) {
    final homeStrength =
        _calculateStrength(home, true);

    final awayStrength =
        _calculateStrength(away, false);

    final homeGoals =
        _generateGoals(homeStrength);

    final awayGoals =
        _generateGoals(awayStrength);

    return MatchResult(
      homeClubId: home.id,
      awayClubId: away.id,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
    );
  }

  // ==========================================================
  // SIŁA DRUŻYNY
  // ==========================================================

  double _calculateStrength(
    Club club,
    bool home,
  ) {
    double strength =
        club.overall.toDouble();

    // ----------------------------------------------------------
    // PRZEWAGA WŁASNEGO STADIONU
    // ----------------------------------------------------------

    if (home) {
      strength += 3;
    }

    // ----------------------------------------------------------
    // FINANSE I REPUTACJA
    // ----------------------------------------------------------

    strength +=
        club.financialHealth * 0.02;

    strength +=
        club.reputation * 0.01;

    // ----------------------------------------------------------
    // LOSOWOŚĆ MECZU
    // ----------------------------------------------------------

    strength +=
        _random.nextDouble() * 8 - 4;

    return strength;
  }

  // ==========================================================
  // GENEROWANIE GOLI
  // ==========================================================

  int _generateGoals(
    double strength,
  ) {
    final normalized =
        ((strength - 55) / 20)
            .clamp(0.2, 2.8);

    final chance =
        _random.nextDouble();

    // ----------------------------------------------------------
    // 0 GOLI
    // ----------------------------------------------------------

    if (chance < 0.10) {
      return 0;
    }

    // ----------------------------------------------------------
    // 0-1 GOLA
    // ----------------------------------------------------------

    if (chance < 0.35) {
      return normalized > 1.5 ? 1 : 0;
    }

    // ----------------------------------------------------------
    // 0-3 GOLE
    // ----------------------------------------------------------

    if (chance < 0.75) {
      return normalized
          .round()
          .clamp(0, 3);
    }

    // ----------------------------------------------------------
    // 0-4 GOLE
    // ----------------------------------------------------------

    if (chance < 0.95) {
      return (normalized + 1)
          .round()
          .clamp(0, 4);
    }

    // ----------------------------------------------------------
    // 0-5 GOLE
    // ----------------------------------------------------------

    return (normalized + 2)
        .round()
        .clamp(0, 5);
  }

  // ==========================================================
  // LOSOWA LICZBA
  // ==========================================================

  int randomInt(
    int min,
    int max,
  ) {
    if (max < min) {
      throw ArgumentError(
        'max nie może być mniejsze od min.',
      );
    }

    return min +
        _random.nextInt(
          max - min + 1,
        );
  }

  // ==========================================================
  // LOSOWA LICZBA ZMIENNOPRZECINKOWA
  // ==========================================================

  double randomDouble(
    double min,
    double max,
  ) {
    if (max < min) {
      throw ArgumentError(
        'max nie może być mniejsze od min.',
      );
    }

    return min +
        _random.nextDouble() *
            (max - min);
  }
}
