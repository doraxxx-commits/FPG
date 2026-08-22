import 'package:flutter/material.dart';

import '../core/game_engine.dart';
import '../core/training_engine.dart';

class TrainingScreen extends StatefulWidget {
  final GameEngine engine;

  const TrainingScreen({
    super.key,
    required this.engine,
  });

  @override
  State<TrainingScreen> createState() =>
      _TrainingScreenState();
}

class _TrainingScreenState
    extends State<TrainingScreen> {
  String? message;

  void train(TrainingType type) {
    try {
      final result =
          widget.engine.trainPlayer(type);

      setState(() {
        message =
            '${result.message} '
            '+${result.improvement} OVR/statystyka';
      });
    } catch (e) {
      setState(() {
        message = e
            .toString()
            .replaceFirst(
              'Bad state: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player =
        widget.engine.careerPlayer;

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TRENING'),
        ),
        body: const Center(
          child: Text(
            'Brak aktywnego zawodnika.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFF080A0F),

      appBar: AppBar(
        title: const Text('TRENING'),
        backgroundColor:
            const Color(0xFF080A0F),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          // ==================================================
          // ZAWODNIK
          // ==================================================

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    player.fullName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'OVR ${player.overall}',
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _statBar(
                    'FITNESS',
                    player.fitness,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _statBar(
                    'ZMĘCZENIE',
                    player.fatigue,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _statBar(
                    'FORMA',
                    player.form,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'POTENCJAŁ ${player.potential}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ==================================================
          // TRENING
          // ==================================================

          const Text(
            'WYBIERZ TRENING',
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          _trainingButton(
            title: 'SZYBKOŚĆ',
            subtitle:
                'Rozwój tempa',
            icon: Icons.bolt,
            onPressed: () {
              train(
                TrainingType.pace,
              );
            },
          ),

          _trainingButton(
            title: 'STRZAŁY',
            subtitle:
                'Rozwój wykończenia',
            icon:
                Icons.sports_soccer,
            onPressed: () {
              train(
                TrainingType.shooting,
              );
            },
          ),

          _trainingButton(
            title: 'PODANIA',
            subtitle:
                'Rozwój podań',
            icon:
                Icons.assistant_direction,
            onPressed: () {
              train(
                TrainingType.passing,
              );
            },
          ),

          _trainingButton(
            title: 'DRYBLING',
            subtitle:
                'Rozwój techniki',
            icon:
                Icons.directions_run,
            onPressed: () {
              train(
                TrainingType.dribbling,
              );
            },
          ),

          _trainingButton(
            title: 'OBRONA',
            subtitle:
                'Rozwój gry defensywnej',
            icon:
                Icons.shield,
            onPressed: () {
              train(
                TrainingType.defending,
              );
            },
          ),

          _trainingButton(
            title: 'FIZYCZNOŚĆ',
            subtitle:
                'Rozwój siły i kondycji',
            icon:
                Icons.fitness_center,
            onPressed: () {
              train(
                TrainingType.physical,
              );
            },
          ),

          const SizedBox(
            height: 20,
          ),

          // ==================================================
          // KOMUNIKAT
          // ==================================================

          if (message != null)
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Text(
                  message!,
                  style:
                      const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statBar(
    String name,
    int value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text('$value / 100'),
          ],
        ),

        const SizedBox(
          height: 5,
        ),

        LinearProgressIndicator(
          value: value / 100,
        ),
      ],
    );
  }

  Widget _trainingButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: ListTile(
        leading: Icon(icon),

        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle:
            Text(subtitle),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: onPressed,
      ),
    );
  }
}
