import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'pinyin_menu_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  List<Lesson> get lessons => [
    Lesson(
      title: 'Introduction to Pinyin',
      description: 'Learn Chinese pronunciation using the Pinyin system',
      progress: 0.0,
      imageAsset: 'assets/image/pinyin.png',
    ),
    Lesson(
      title: 'Greetings',
      description: 'Master basic Chinese greetings for daily conversations',
      progress: 0.0,
      imageAsset: 'assets/image/greetings.png',
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
                    Text(
                      'Lesson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        foreground:
                            Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = const Color.fromARGB(
                                255,
                                122,
                                8,
                                216,
                              ).withValues(alpha: 0.4),
                      ),
                    ),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];

                  return LessonCard(
                    lesson: lesson,
                    onTap: () {
                      // ✅ NAVIGATION LOGIC
                      if (lesson.title == 'Introduction to Pinyin') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PinyinMenuScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lesson coming soon 👀'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
