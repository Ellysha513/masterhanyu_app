class Lesson {
  final String id; // 🔑 stable identifier
  final String title;
  final String description;
  final double progress;
  final String imageAsset;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.imageAsset,
  });
}
