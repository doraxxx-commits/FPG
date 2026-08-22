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

    for (int round = 0; round < rounds; round++) {
      for (int i = 0; i < teamCount ~/ 2; i++) {
        final home = rotatingTeams[i];
        final away = rotatingTeams[teamCount - 1 - i];

        if (home.id != 'BYE' && away.id != 'BYE') {
          final matchDay = 8 + (round * 7);

          fixtures.add(
            Fixture(
              round: round + 1,
              homeClubId: home.id,
              awayClubId: away.id,
              year: 2026,
              month: 7,
              day: matchDay,
            ),
          );
        }
      }

      final last = rotatingTeams.removeLast();
      rotatingTeams.insert(1, last);
    }

    final firstRoundFixtures = List<Fixture>.from(fixtures);

    for (final fixture in firstRoundFixtures) {
      fixtures.add(
        Fixture(
          round: fixture.round + rounds,
          homeClubId: fixture.awayClubId,
          awayClubId: fixture.homeClubId,
          year: 2026,
          month: 9,
          day: fixture.day,
        ),
      );
    }

    return fixtures;
  }
}
