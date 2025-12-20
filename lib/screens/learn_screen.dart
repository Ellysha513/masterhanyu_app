import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  List<Lesson> get lessons => [
        Lesson(
          category: 'Basics',
          title: 'Greetings',
          description:
              'Learn essential Chinese greetings for daily conversations',
          words: 6,
          level: 'Beginner',
          progress: 0.0,
          imageUrl:
              'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
        ),
        Lesson(
          category: 'Basics',
          title: 'Numbers 1-10',
          description: 'Master basic Chinese numbers from one to ten',
          words: 10,
          level: 'Beginner',
          progress: 0.0,
          imageUrl:
              'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 160, 160, 248),
                    Color.fromARGB(255, 204, 134, 231),
                    Color.fromARGB(255, 248, 151, 240),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // OUTLINE
                    Text(
                      'Lesson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = const Color.fromARGB(255, 122, 8, 216).withValues(alpha: 0.4),
                      ),
                    ),
                    // FILL
                    const Text(
                      'Lesson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose a Lesson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a topic to start learning',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ...lessons.map(
                      (lesson) => LessonCard(lesson: lesson),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
