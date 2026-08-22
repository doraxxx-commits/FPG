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
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      appBar: AppBar(
        title: const Text('FPG'),
        backgroundColor: const Color(0xFF080A0F),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FPG',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'SEZON ${engine.currentSeason}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              engine.currentDate,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: nextDay,
              child: const Text('NASTĘPNY DZIEŃ'),
            ),
          ],
        ),
      ),
    );
  }
}
