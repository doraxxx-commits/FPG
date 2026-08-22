class PlayerMatchStats {
  int appearances = 0;
  int starts = 0;
  int substituteAppearances = 0;

  int minutes = 0;

  int goals = 0;
  int assists = 0;

  int yellowCards = 0;
  int redCards = 0;

  int shots = 0;
  int shotsOnTarget = 0;

  int keyPasses = 0;
  int successfulDribbles = 0;

  double averageRating = 0.0;

  void addAppearance({
    required int playedMinutes,
    required bool started,
    required double rating,
  }) {
    appearances++;

    if (started) {
      starts++;
    } else {
      substituteAppearances++;
    }

    minutes += playedMinutes;

    final totalRating =
        averageRating * (appearances - 1);

    averageRating =
        (totalRating + rating) / appearances;
  }
}
