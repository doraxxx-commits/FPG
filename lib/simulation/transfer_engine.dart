import 'dart:math';
import '../models/club.dart';
import '../models/player.dart';

class AITransferEngine {
  static final Random _rnd = Random();

  /// Przeprowadza losowe ruchy transferowe pomiędzy klubami AI w oknach transferowych
  static List<String> processAITransfers({
    required List<Club> clubs,
    required List<Player> players,
    required bool isSummerWindow,
    required bool isWinterWindow,
  }) {
    final List<String> transferLogs = [];

    // Transfery zachodzą tylko podczas aktywnych okienek transferowych
    if (!isSummerWindow && !isWinterWindow) {
      return transferLogs;
    }

    // Szansa na przeprowadzenie transferu AI w danym dniu okienka (ok. 15%)
    if (_rnd.nextDouble() > 0.15) {
      return transferLogs;
    }

    if (clubs.length < 2 || players.isEmpty) {
      return transferLogs;
    }

    // Wybieramy klub kupujący i sprzedający
    final sellerClub = clubs[_rnd.nextInt(clubs.length)];
    final buyerClub = clubs.firstWhere(
      (c) => c.id != sellerClub.id,
      orElse: () => clubs.first,
    );

    if (buyerClub.id == sellerClub.id) return transferLogs;

    // Szukamy zawodnika ze składu sprzedającego
    final availablePlayers = players.where((p) => p.clubId == sellerClub.id).toList();
    if (availablePlayers.isEmpty) return transferLogs;

    final targetPlayer = availablePlayers[_rnd.nextInt(availablePlayers.length)];

    // Zmiana klubu w bazy danych zawodników
    targetPlayer.clubId = buyerClub.id;

    final fee = (targetPlayer.value > 0 ? targetPlayer.value : 150000) * (0.85 + _rnd.nextDouble() * 0.4);
    final logMessage = '🔄 TRANSFER AI: ${targetPlayer.name} przeszedł z ${sellerClub.name} do ${buyerClub.name} za ${fee.toStringAsFixed(0)} €!';

    transferLogs.add(logMessage);
    return transferLogs;
  }
}
