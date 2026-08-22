import 'package:flutter/material.dart';

import 'core/game_engine.dart';

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

  void nextDay() {
    setState(() {
      engine.advanceDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final table = engine.leagueEngine.table;

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      appBar: AppBar(
        title: const Text('FPG'),
        backgroundColor: const Color(0xFF080A0F),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                        child: const Text('NASTĘPNY DZIEŃ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                  title: Text(club.name),
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
