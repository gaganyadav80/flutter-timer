extension DurationExtension on Duration {
  /// Method to convert the duration to mm:ss format.
  String formatToHHMMss() {
    final int hours = inHours.remainder(60);
    final int minutes = inMinutes.remainder(60);
    final int seconds = inSeconds.remainder(60);

    final String formattedHours = hours > 9 ? hours.toString().padLeft(2, '0') : hours.toString();
    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    final String formattedSeconds = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    }
    return '$formattedMinutes:$formattedSeconds';
  }
}
