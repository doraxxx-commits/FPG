import 'dart:math';

import '../models/club.dart';
import '../models/match_result.dart';

class MatchEngine {
  final Random _random;

  MatchEngine({Random? random}) : _random = random ?? Random();

  MatchResult simulate({
    required Club home,
    required Club away,
  }) {
    final homeStrength = _calculateStrength(home, true);
    final awayStrength = _calculateStrength(away, false);

    final homeGoals = _generateGoals(homeStrength);
    final awayGoals = _generateGoals(awayStrength);

    return MatchResult(
      homeClubId: home.id,
      awayClubId: away.id,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
    );
  }

  double _calculateStrength(
    Club club,
    bool home,
  ) {
    double strength = club.overall.toDouble();

    // Przewaga własnego stadionu.
    if (home) {
      strength += 3;
    }

    // Kondycja finansowa i reputacja mają niewielki wpływ.
    strength += club.financialHealth * 0.02;
    strength += club.reputation * 0.01;

    // Losowość meczu.
    strength += _random.nextDouble() * 8 - 4;

    return strength;
  }

  int _generateGoals(double strength) {
    final normalized = ((strength - 55) / 20).clamp(0.2, 2.8);

    final chance = _random.nextDouble();

    if (chance < 0.10) {
      return 0;
    }

    if (chance < 0.35) {
      return normalized > 1.5 ? 1 : 0;
    }

    if (chance < 0.75) {
      return normalized.round().clamp(0, 3);
    }

    if (chance < 0.95) {
      return (normalized + 1).round().clamp(0, 4);
    }

    return (normalized + 2).round().clamp(0, 5);
  }
}
