import 'package:flutter/material.dart';
import '../core/game_engine.dart';
import '../models/match_result.dart';

class MatchScreen extends StatefulWidget {
  final GameEngine engine;

  const MatchScreen({
    super.key,
    required this.engine,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  bool _isFinished = false;
  MatchResult? _result;

  void _runMatch() async {
    // Symulacja dnia i pobranie wyników
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      widget.engine.nextDay();
    } catch (_) {}

    setState(() {
      _isFinished = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _runMatch();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.engine.careerPlayer;

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      appBar: AppBar(
        title: const Text('Dzień Meczowy'),
        backgroundColor: const Color(0xFF080A0F),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isFinished) ...[
                const CircularProgressIndicator(color: Colors.greenAccent),
                const SizedBox(height: 24),
                const Text(
                  'Mecz w trakcie...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trwa symulacja wyników ligowych',
                  style: TextStyle(color: Colors.white38),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kolejka Zakończona!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFF1E2638),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          player?.fullName ?? 'Zawodnik',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Twoja drużyna rozegrała swój mecz. Sprawdź pozycję w tabeli ligowej!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'POWRÓT DO KARIERY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
