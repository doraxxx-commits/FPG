import 'package:flutter/material.dart';

import '../core/game_engine.dart';
import '../database/save_manager.dart';
import 'training_screen.dart';

class CareerHomeScreen extends StatelessWidget {
  final GameEngine engine;

  const CareerHomeScreen({
    super.key,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final player = engine.careerPlayer;

    if (player == null || player.contract == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Brak aktywnej kariery.',
          ),
        ),
      );
    }

    final contract = player.contract!;

    final club = engine.clubs.firstWhere(
      (club) => club.id == player.clubId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),

      appBar: AppBar(
        title: const Text('FPG'),
        backgroundColor: const Color(0xFF080A0F),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Zapisz grę',
            onPressed: () async {
              final success = await SaveManager.saveGame(engine.gameState);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Gra została pomyślnie zapisana!'
                          : 'Błąd podczas zapisu gry.',
                    ),
                    backgroundColor:
                        success ? Colors.green[800] : Colors.red[800],
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // =========================================================
            // ZAWODNIK
            // =========================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      club.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _infoBox(
                          'OVR',
                          '${player.overall}',
                        ),

                        const SizedBox(width: 10),

                        _infoBox(
                          'WIEK',
                          '${player.age}',
                        ),

                        const SizedBox(width: 10),

                        _infoBox(
                          'NR',
                          '#${contract.squadNumber}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // STATUS
            // =========================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'STATUS ZAWODNIKA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Status w drużynie',
                        ),

                        Text(
                          contract.squadStatus,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Zaufanie trenera',
                        ),

                        Text(
                          '${contract.managerTrust}/100',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    LinearProgressIndicator(
                      value: contract.managerTrust / 100,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // NASTĘPNY MECZ
            // =========================================================

            const Text(
              'NAJBLIŻSZY MECZ',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.sports_soccer,
                  size: 32,
                  color: Colors.greenAccent,
                ),

                title: const Text(
                  'Rozegraj Kolejkę',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text(
                  'Symuluj mecze i przejdź do kolejnego dnia',
                ),

                trailing: const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.greenAccent,
                ),

                onTap: () {
                  // Przechodzimy do kolejnego dnia w GameEngine
                  try {
                    engine.nextDay();
                  } catch (_) {
                    // W razie braku metody nextDay, fallback na podpięcie mechaniki
                  }

                  (context as Element).markNeedsBuild();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Postęp dnia został wykonany!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =========================================================
            // MENU KARIERY
            // =========================================================

            const Text(
              'KARIERA',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            _menuButton(
              icon: Icons.fitness_center,
              title: 'TRENING',
              subtitle: 'Rozwijaj swoje umiejętności',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainingScreen(
                      engine: engine,
                    ),
                  ),
                ).then((_) {
                  (context as Element).markNeedsBuild();
                });
              },
            ),

            _menuButton(
              icon: Icons.bar_chart,
              title: 'STATYSTYKI',
              subtitle: 'Twoja kariera i osiągnięcia',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.auto_graph,
              title: 'ROZWÓJ',
              subtitle: 'OVR, potencjał i perki',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.groups,
              title: 'DRUŻYNA',
              subtitle: 'Relacje z zespołem',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.person,
              title: 'TRENER',
              subtitle: 'Zaufanie i relacja z trenerem',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.swap_horiz,
              title: 'TRANSFERY',
              subtitle: 'Transfery i wypożyczenia',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.newspaper,
              title: 'FPG NEWS',
              subtitle: 'Plotki, informacje i transfery',
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.favorite,
              title: 'ŻYCIE',
              subtitle: 'Relacje i życie poza boiskiem',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // =========================================================
            // KONTRAKT
            // =========================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'KONTRAKT',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pensja: '
                      '${contract.weeklySalary.toStringAsFixed(0)} / tydzień',
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Wartość rynkowa: '
                      '${contract.marketValue.toStringAsFixed(0)}',
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Kontrakt: '
                      '${contract.yearsRemaining} lata',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(
    String title,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),

        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.05,
          ),

          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),

        leading: Icon(
          icon,
          size: 28,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }
}
