extension DurationExtension on Duration {
  /// Method to convert the duration to mm:ss format.
  String formatToMMss() {
    final int minutes = inMinutes.remainder(60);
    final int seconds = inSeconds.remainder(60);
    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    final String formattedSeconds = seconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }
}
