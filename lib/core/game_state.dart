class GameState {
  int year;
  int month;
  int day;

  int season;

  bool transferWindowSummer;
  bool transferWindowWinter;

  GameState({
    this.year = 2026,
    this.month = 7,
    this.day = 1,
    this.season = 2026,
    this.transferWindowSummer = true,
    this.transferWindowWinter = false,
  });

  void nextDay() {
    day++;

    final daysInMonth = _daysInCurrentMonth();

    if (day > daysInMonth) {
      day = 1;
      month++;
    }

    if (month > 12) {
      month = 1;
      year++;
      season++;
    }

    _updateTransferWindows();
  }

  int _daysInCurrentMonth() {
    const days = [
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    return days[month - 1];
  }

  void _updateTransferWindows() {
    transferWindowSummer = month == 7 || month == 8;
    transferWindowWinter = month == 1;
  }

  String get dateString {
    final dayString = day.toString().padLeft(2, '0');
    final monthString = month.toString().padLeft(2, '0');

    return '$dayString.$monthString.$year';
  }
}
