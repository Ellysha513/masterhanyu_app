import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'pinyin_menu_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  double pinyinProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final intro = prefs.getDouble('pinyin_intro_progress_$userId') ?? 0.0;
    final syllables =
        prefs.getDouble('learn_syllables_progress_$userId') ?? 0.0;
    final tones = prefs.getDouble('tones_quiz_progress_$userId') ?? 0.0;

    final total = (intro + syllables + tones).clamp(0.0, 1.0);

    // Check if lesson was just completed (progress reached 100%)
    if (total >= 1.0 && pinyinProgress < 1.0) {
      try {
        final key = 'lessons_completed_$userId';
        final count = prefs.getInt(key) ?? 0;
        await prefs.setInt(key, count + 1);
      } catch (_) {}
    }

    setState(() {
      // Each sub-lesson contributes 25%; intro + syllables + tones + intro_quiz = 100%
      pinyinProgress = total;
    });
  }

  List<Lesson> get lessons => [
    Lesson(
      id: 'pinyin_intro',
      title: 'Introduction',
      description: 'Learn Chinese pronunciation using the Pinyin system',
      progress: pinyinProgress,
      imageAsset: 'assets/image/pinyin.png',
    ),
    Lesson(
      id: 'greetings',
      title: 'Greetings',
      description: 'Learn basic Chinese greetings for daily conversations',
      progress: 0.0,
      imageAsset: 'assets/image/greetings.png',
    ),
    Lesson(
      id: 'name',
      title: 'Introduce Yourself',
      description: 'Learn how to introduce yourself in Chinese',
      progress: 0.0,
      imageAsset: 'assets/image/name.png',
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
                    onTap: () async {
                      if (lesson.id == 'pinyin_intro') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PinyinMenuScreen(),
                          ),
                        );
                        _loadProgress(); // 🔁 refresh after return
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
    );
  }
}
