import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          lesson.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Level: ${lesson.level} • ${lesson.duration} min'),
        trailing: Icon(Icons.play_arrow),
      ),
    );
  }
}
