import '../models/club.dart';
import '../models/fixture.dart';

class FixtureGenerator {
  static List<Fixture> generateDoubleRoundRobin(
    List<Club> clubs,
  ) {
    final fixtures = <Fixture>[];

    if (clubs.length < 2) {
      return fixtures;
    }

    final teams = List<Club>.from(clubs);

    // Przy nieparzystej liczbie drużyn dodajemy "wolny termin".
    if (teams.length.isOdd) {
      teams.add(
        Club(
          id: 'BYE',
          name: 'BYE',
          country: '',
          leagueId: '',
          overall: 0,
          budget: 0,
        ),
      );
    }

    final teamCount = teams.length;
    final rounds = teamCount - 1;

    final rotatingTeams = List<Club>.from(teams);

    // Pierwsza runda — każdy z każdym.
    for (int round = 0; round < rounds; round++) {
      for (int i = 0; i < teamCount ~/ 2; i++) {
        final home = rotatingTeams[i];
        final away = rotatingTeams[teamCount - 1 - i];

        if (home.id != 'BYE' && away.id != 'BYE') {
          fixtures.add(
            Fixture(
              round: round + 1,
              homeClubId: home.id,
              awayClubId: away.id,
            ),
          );
        }
      }

      // Obrót wszystkich drużyn poza pierwszą.
      final last = rotatingTeams.removeLast();
      rotatingTeams.insert(1, last);
    }

    // Druga runda — rewanże.
    final firstRoundFixtures = List<Fixture>.from(fixtures);

    for (final fixture in firstRoundFixtures) {
      fixtures.add(
        Fixture(
          round: fixture.round + rounds,
          homeClubId: fixture.awayClubId,
          awayClubId: fixture.homeClubId,
        ),
      );
    }

    return fixtures;
  }
}
