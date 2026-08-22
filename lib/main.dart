import 'package:flutter/material.dart';

import 'core/game_engine.dart';
import 'models/player.dart';
import 'screens/create_player_screen.dart';

void main() {
  runApp(const FPGApp());
}

class FPGApp extends StatelessWidget {
  const FPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FPG - Football Player Game',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const FPGHomePage(),
    );
  }
}

class FPGHomePage extends StatefulWidget {
  const FPGHomePage({super.key});

  @override
  State<FPGHomePage> createState() => _FPGHomePageState();
}

class _FPGHomePageState extends State<FPGHomePage> {
  final GameEngine engine = GameEngine();

  // ============================================================
  // TESTOWY ZAWODNIK
  // ============================================================

  void createTestPlayer() {
    setState(() {
      engine.createPlayer(
        firstName: 'Dominik',
        lastName: 'Nowak',
        nationality: 'Polska',
        age: 18,
        height: 178,
        position: PlayerPosition.winger,
        pace: 82,
        shooting: 70,
        passing: 68,
        dribbling: 84,
        defending: 35,
        physical: 65,
      );
    });
  }

  // ============================================================
  // CZAS GRY
  // ============================================================

  void nextDay() {
    setState(() {
      engine.advanceDay();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final table = engine.leagueEngine.table;

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text('FPG'),
        backgroundColor: const Color(0xFF080A0F),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // ==================================================
            // LOGO
            // ==================================================

            const Text(
              'FPG',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'FOOTBALL PLAYER GAME',
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // INFORMACJE O SEZONIE
            // ==================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'SEZON ${engine.currentSeason}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      engine.currentDate,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: nextDay,

                        child: const Text(
                          'NASTĘPNY DZIEŃ',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // TESTOWY ZAWODNIK
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: createTestPlayer,

                child: const Text(
                  'STWÓRZ ZAWODNIKA TESTOWEGO',
                ),
              ),
            ),

            const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePlayerScreen(
            engine: engine,
          ),
        ),
      );
    },
    child: const Text(
      'NOWA KARIERA',
    ),
  ),
),

            // ==================================================
            // INFORMACJE O ZAWODNIKU
            // ==================================================

            if (engine.careerPlayer != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        engine.careerPlayer!.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'OVR ${engine.careerPlayer!.overall}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Wiek: ${engine.careerPlayer!.age}',
                      ),

                      Text(
                        'Wzrost: '
                        '${engine.careerPlayer!.height} cm',
                      ),

                      Text(
                        'Potencjał: '
                        '${engine.careerPlayer!.potential}',
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'PACE ${engine.careerPlayer!.pace}  •  '
                        'SHO ${engine.careerPlayer!.shooting}',
                      ),

                      Text(
                        'PAS ${engine.careerPlayer!.passing}  •  '
                        'DRI ${engine.careerPlayer!.dribbling}',
                      ),

                      Text(
                        'DEF ${engine.careerPlayer!.defending}  •  '
                        'PHY ${engine.careerPlayer!.physical}',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ==================================================
            // DZISIEJSZE MECZE
            // ==================================================

            const Text(
              'DZISIAJ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (engine.todayFixtures.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),

                  child: Text(
                    'Brak meczów zaplanowanych na dzisiaj.',
                  ),
                ),
              ),

            ...engine.todayFixtures.map((fixture) {
              final home = engine.clubs.firstWhere(
                (club) => club.id == fixture.homeClubId,
              );

              final away = engine.clubs.firstWhere(
                (club) => club.id == fixture.awayClubId,
              );

              return Card(
                child: ListTile(
                  title: Text(
                    '${home.name}  '
                    '${fixture.homeGoals ?? '-'} : '
                    '${fixture.awayGoals ?? '-'}  '
                    '${away.name}',
                  ),

                  subtitle: Text(
                    fixture.played
                        ? 'Mecz zakończony'
                        : 'Mecz zaplanowany',
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ==================================================
            // NASTĘPNE MECZE
            // ==================================================

            const Text(
              'NASTĘPNE MECZE',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...engine.upcomingFixtures.take(5).map((fixture) {
              final home = engine.clubs.firstWhere(
                (club) => club.id == fixture.homeClubId,
              );

              final away = engine.clubs.firstWhere(
                (club) => club.id == fixture.awayClubId,
              );

              return Card(
                child: ListTile(
                  title: Text(
                    '${home.name} vs ${away.name}',
                  ),

                  subtitle: Text(
                    '${fixture.day.toString().padLeft(2, '0')}.'
                    '${fixture.month.toString().padLeft(2, '0')}.'
                    '${fixture.year}',
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ==================================================
            // TABELA EKSTRAKLASY
            // ==================================================

            const Text(
              'EKSTRAKLASA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...List.generate(table.length, (index) {
              final standing = table[index];

              final club = engine.clubs.firstWhere(
                (club) => club.id == standing.clubId,
              );

              return Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 30,

                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    club.name,
                  ),

                  subtitle: Text(
                    'OVR ${club.overall}  •  '
                    '${standing.played} meczów',
                  ),

                  trailing: Text(
                    '${standing.points} pkt',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
