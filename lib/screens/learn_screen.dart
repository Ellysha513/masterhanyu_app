import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'pinyin_menu_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  List<Lesson> get lessons => [
    Lesson(
      id: 'pinyin_intro', // ✅ stable ID
      title: 'Introduction',
      description: 'Learn Chinese pronunciation using the Pinyin system',
      progress: 0.0,
      imageAsset: 'assets/image/pinyin.png',
    ),
    Lesson(
      id: 'greetings',
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
            _header(),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];

                  return LessonCard(
                    lesson: lesson,
                    onTap: () {
                      // ✅ SAFE NAVIGATION
                      if (lesson.id == 'pinyin_intro') {
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

  Widget _header() {
    return Container(
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: const Center(
        child: Text(
          'Lesson',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
