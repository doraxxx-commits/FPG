class GameState {
  int year;
  int month;
  int day;
  int season;

  GameState({
    this.year = 2026,
    this.month = 7,
    this.day = 1,
    this.season = 1,
  });

  void nextDay() {
    day++;
    if (day > 30) {
      day = 1;
      month++;
      if (month > 12) {
        month = 1;
        year++;
        season++;
      }
    }
  }

  String get dateString => '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';

  bool get transferWindowSummer => month == 7 || month == 8;
  bool get transferWindowWinter => month == 1;
}
