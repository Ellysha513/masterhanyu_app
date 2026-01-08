/// Format minutes into human-readable time string
/// Examples:
/// - 4 → "4 min"
/// - 60 → "1h"
/// - 90 → "1h 30m"
/// - 150 → "2h 30m"
String formatMinutes(int minutes) {
  if (minutes < 60) {
    return "$minutes min";
  }

  final hours = minutes ~/ 60;
  final mins = minutes % 60;

  if (mins == 0) {
    return "${hours}h";
  }

  return "${hours}h ${mins}m";
}
