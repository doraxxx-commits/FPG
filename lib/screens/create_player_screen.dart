import 'package:flutter/material.dart';

import '../core/game_engine.dart';
import '../models/player.dart';
import 'club_selection_screen.dart';

class CreatePlayerScreen extends StatefulWidget {
  final GameEngine engine;

  const CreatePlayerScreen({
    super.key,
    required this.engine,
  });

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final heightController = TextEditingController(text: '178');

  String nationality = 'Polska';
  int age = 18;

  PlayerPosition position = PlayerPosition.winger;

  int pace = 70;
  int shooting = 65;
  int passing = 65;
  int dribbling = 70;
  int defending = 40;
  int physical = 60;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void createPlayer() {
  final firstName = firstNameController.text.trim();
  final lastName = lastNameController.text.trim();

  final height = int.tryParse(
    heightController.text.trim(),
  );

  if (firstName.isEmpty ||
      lastName.isEmpty ||
      height == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Uzupełnij imię, nazwisko i prawidłowy wzrost.',
        ),
      ),
    );

    return;
  }

  widget.engine.createPlayer(
    firstName: firstName,
    lastName: lastName,
    nationality: nationality,
    age: age,
    height: height,
    position: position,
    pace: pace,
    shooting: shooting,
    passing: passing,
    dribbling: dribbling,
    defending: defending,
    physical: physical,
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => ClubSelectionScreen(
        engine: widget.engine,
      ),
    ),
  );
}

      return;
    }

    widget.engine.createPlayer(
      firstName: firstName,
      lastName: lastName,
      nationality: nationality,
      age: age,
      height: height,
      position: position,
      pace: pace,
      shooting: shooting,
      passing: passing,
      dribbling: dribbling,
      defending: defending,
      physical: physical,
    );

    Navigator.pop(context);
  }

  String positionName(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 'BRAMKARZ';

      case PlayerPosition.defender:
        return 'OBROŃCA';

      case PlayerPosition.midfielder:
        return 'POMOCNIK';

      case PlayerPosition.winger:
        return 'SKRZYDŁOWY';

      case PlayerPosition.striker:
        return 'NAPASTNIK';
    }
  }

  Widget statSlider({
    required String name,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            Text(
              '$value',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 99,
          value: value.toDouble(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      appBar: AppBar(
        title: const Text('NOWA KARIERA'),
        backgroundColor: const Color(0xFF080A0F),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'STWÓRZ ZAWODNIKA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Rozpocznij swoją piłkarską karierę.',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Imię',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nazwisko',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: nationality,
              decoration: const InputDecoration(
                labelText: 'Narodowość',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Polska',
                'Niemcy',
                'Hiszpania',
                'Anglia',
                'Francja',
                'Włochy',
                'Brazylia',
                'Argentyna',
              ].map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    nationality = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: age,
              decoration: const InputDecoration(
                labelText: 'Wiek',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                13,
                (index) => 16 + index,
              ).map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value lat'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    age = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Wzrost',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'POZYCJA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<PlayerPosition>(
              initialValue: position,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: PlayerPosition.values.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(positionName(value)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    position = value;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'STATYSTYKI STARTOWE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            statSlider(
              name: 'PACE',
              value: pace,
              onChanged: (value) {
                setState(() {
                  pace = value.round();
                });
              },
            ),

            statSlider(
              name: 'SHOOTING',
              value: shooting,
              onChanged: (value) {
                setState(() {
                  shooting = value.round();
                });
              },
            ),

            statSlider(
              name: 'PASSING',
              value: passing,
              onChanged: (value) {
                setState(() {
                  passing = value.round();
                });
              },
            ),

            statSlider(
              name: 'DRIBBLING',
              value: dribbling,
              onChanged: (value) {
                setState(() {
                  dribbling = value.round();
                });
              },
            ),

            statSlider(
              name: 'DEFENDING',
              value: defending,
              onChanged: (value) {
                setState(() {
                  defending = value.round();
                });
              },
            ),

            statSlider(
              name: 'PHYSICAL',
              value: physical,
              onChanged: (value) {
                setState(() {
                  physical = value.round();
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: createPlayer,
                child: const Text(
                  'UTWÓRZ ZAWODNIKA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
