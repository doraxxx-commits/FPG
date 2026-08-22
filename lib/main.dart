import 'package:flutter/material.dart';

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

class FPGHomePage extends StatelessWidget {
  const FPGHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FPG',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'FOOTBALL PLAYER GAME',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'by mEmmor',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
