extension NumFormatExtension on num {
  String get inTime {
    final String secondsText = ((this ~/ 1000) % 60).toString().padLeft(2, '0');
    String minutesText = ((this ~/ 60000) % 60).toString();
    if (this >= 3600000) {
      minutesText = minutesText.padLeft(2, '0');
      final String hourText =
          ((this ~/ 3600000) % 60).toString().padLeft(2, '0');
      return '$hourText:$minutesText:$secondsText';
    }
    return '$minutesText:$secondsText';
  }
}
