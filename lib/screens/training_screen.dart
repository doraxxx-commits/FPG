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
  String? lastTraining;

  void performTraining(
    TrainingType type,
  ) {
    try {
      final result =
          widget.engine.trainPlayer(type);

      setState(() {
        lastTraining =
            '${result.name}: +${result.primaryGain} główna statystyka';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.name} zakończony. '
            'Zmęczenie +${result.fatigue}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player =
        widget.engine.careerPlayer;

    if (player == null) {
      return const Scaffold(
        body: Center(
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

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            Text(
              player.fullName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'OVR ${player.overall}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'ZMĘCZENIE',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value:
                          player.fatigue / 100,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${player.fatigue}/100',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'WYBIERZ TRENING',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            _trainingButton(
              '⚡ SZYBKOŚĆ',
              'PACE + PHYSICAL',
              TrainingType.pace,
            ),

            _trainingButton(
              '🎯 WYKOŃCZENIE',
              'SHOOTING + PHYSICAL',
              TrainingType.shooting,
            ),

            _trainingButton(
              '🎯 PODANIA',
              'PASSING + DRIBBLING',
              TrainingType.passing,
            ),

            _trainingButton(
              '🔥 DRYBLING',
              'DRIBBLING + PACE',
              TrainingType.dribbling,
            ),

            _trainingButton(
              '🛡️ OBRONA',
              'DEFENDING + PHYSICAL',
              TrainingType.defending,
            ),

            _trainingButton(
              '💪 FIZYCZNOŚĆ',
              'PHYSICAL + PACE',
              TrainingType.physical,
            ),

            _trainingButton(
              '⚖️ TRENING OGÓLNY',
              'Wszystkie statystyki',
              TrainingType.balanced,
            ),

            if (lastTraining != null) ...[
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Text(
                    lastTraining!,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _trainingButton(
    String title,
    String subtitle,
    TrainingType type,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 8),

      child: ListTile(
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

        onTap: () {
          performTraining(type);
        },
      ),
    );
  }
}
