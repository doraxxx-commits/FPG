import 'dart:math';
import '../models/player.dart';
import '../models/club.dart';

class AgingEngine {
  static final Random _rnd = Random();

  static const List<String> _firstNames = [
    'Mateo', 'Kacper', 'Szymon', 'Nico', 'Lucas', 'Julian', 'Marco', 'Leo', 'Jakub', 'Filip', 'Jan', 'Gabriel'
  ];

  static const List<String> _lastNames = [
    'Nowak', 'Rossi', 'Silva', 'Müller', 'Kowalski', 'Garcia', 'Weber', 'Wiśniewski', 'Zieliński', 'Dubois', 'Martins'
  ];

  /// Symulacja starzenia i rozwoju wykonywana na koniec każdego sezonu
  static void processEndOfSeason({
    required List<Player> allPlayers,
    required List<Club> allClubs,
  }) {
    final List<Player> retiredPlayers = [];

    for (final player in allPlayers) {
      // 1. Dodajemy 1 rok do wieku
      player.age += 1;

      // 2. LOGIKA ROZWOJU (Młodzi piłkarze do 26 lat)
      if (player.age <= 26 && player.overall < player.potential) {
        final gap = player.potential - player.overall;
        final growth = (gap * (0.15 + _rnd.nextDouble() * 0.15)).round().clamp(1, 4);
        
        player.pace = (player.pace + growth).clamp(1, 99);
        player.shooting = (player.shooting + growth).clamp(1, 99);
        player.passing = (player.passing + growth).clamp(1, 99);
        player.dribbling = (player.dribbling + growth).clamp(1, 99);
      }

      // 3. LOGIKA STARZENIA (Po 30. roku życia)
      if (player.age >= 31) {
        // Czym wyższy OVR zawodnika, tym wolniejszy spadek (klasa światowa wolniej traci jakość)
        final ovrFactor = (100 - player.overall) / 100.0; // np. dla OVR 97 -> 0.03 (znikomy spadek)
        final ageFactor = (player.age - 30) * 0.3;
        final totalDecline = ((ageFactor * ovrFactor) + (_rnd.nextDouble() * 0.5)).round().clamp(0, 3);

        if (totalDecline > 0) {
          player.pace = (player.pace - totalDecline).clamp(35, 99);
          player.physical = (player.physical - totalDecline).clamp(35, 99);
          player.fatigue = (player.fatigue + totalDecline).clamp(0, 100);
        }
      }

      // 4. LOGIKA EMERYTURY (Zakres 32 – 48 lat)
      if (player.age >= 32) {
        bool shouldRetire = false;

        if (player.age >= 48) {
          // Automatyczna emerytura w wieku 48 lat
          shouldRetire = true;
        } else if (player.age >= 40) {
          // Wysoka szansa na emeryturę po 40-tce
          shouldRetire = _rnd.nextDouble() < 0.40;
        } else if (player.age >= 36) {
          // Umiarkowana szansa (bramkarze i gwiazdy grają dłużej)
          final isGK = player.position == PlayerPosition.goalkeeper;
          final isStar = player.overall >= 82;
          final baseChance = (isGK || isStar) ? 0.08 : 0.20;
          shouldRetire = _rnd.nextDouble() < baseChance;
        } else if (player.age >= 32) {
          // Bardzo mała szansa (tylko w przypadku niskiego OVR < 60)
          if (player.overall < 60) {
            shouldRetire = _rnd.nextDouble() < 0.10;
          }
        }

        if (shouldRetire) {
          retiredPlayers.add(player);
        }
      }
    }

    // 5. USUWANIE EMERYTÓW I GENEROWANIE REGENÓW
    for (final retired in retiredPlayers) {
      allPlayers.remove(retired);
      final regen = _generateRegen(retired.clubId, retired.position, retired.name);
      allPlayers.add(regen);
    }
  }

  // Generowanie nowego młodego zawodnika (Regen)
  static Player _generateRegen(String clubId, PlayerPosition position, String originalName) {
    final fName = _firstNames[_rnd.nextInt(_firstNames.length)];
    final lName = _lastNames[_rnd.nextInt(_lastNames.length)];
    final baseStat = 58 + _rnd.nextInt(14); // OVR początkowe 58-72

    return Player(
      id: 'regen_${DateTime.now().millisecondsSinceEpoch}_${_rnd.nextInt(9999)}',
      name: '$fName $lName',
      age: 17 + _rnd.nextInt(3), // Wiek 17-19 lat
      position: position,
      pace: baseStat + _rnd.nextInt(8) - 4,
      shooting: baseStat + _rnd.nextInt(8) - 4,
      passing: baseStat + _rnd.nextInt(8) - 4,
      dribbling: baseStat + _rnd.nextInt(8) - 4,
      defending: baseStat + _rnd.nextInt(8) - 4,
      physical: baseStat + _rnd.nextInt(8) - 4,
      value: (baseStat * 18000),
      weeklyWage: (baseStat * 140),
      clubId: clubId,
    );
  }
}
