import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:confetti/confetti.dart';
import '../models/lesson.dart';
import '../widgets/lesson_card.dart';
import 'pinyin_menu_screen.dart';
import 'greetings_menu_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  double pinyinProgress = 0.0;
  double greetingsProgress = 0.0;

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
    final quiz = prefs.getDouble('introduction_quiz_progress_$userId') ?? 0.0;

    final total = (intro + syllables + tones + quiz).clamp(0.0, 1.0);

    // Greetings topic progress (basic + learn + quiz) each contributes 1/3
    final basicG = prefs.getDouble('basic_greetings_progress_$userId') ?? 0.0;
    final learnG = prefs.getDouble('learn_greetings_progress_$userId') ?? 0.0;
    final quizG = prefs.getDouble('greetings_quiz_progress_$userId') ?? 0.0;
    final greetingsTotal = ((basicG + learnG + quizG) / 3).clamp(0.0, 1.0);

    // Check if lesson was just completed (progress reached 100%)
    // Guard: only increment and show dialog once (tracked in SharedPreferences)
    final hasShownDialogKey = 'has_shown_completion_dialog_$userId';
    final hasShownDialog = prefs.getBool(hasShownDialogKey) ?? false;

    if (total >= 1.0 && pinyinProgress < 1.0 && !hasShownDialog) {
      try {
        final key = 'lessons_completed_$userId';
        final count = prefs.getInt(key) ?? 0;
        await prefs.setInt(key, count + 1);
        // Persist the flag so it survives app restarts
        await prefs.setBool(hasShownDialogKey, true);

        // Show lesson completion dialog
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLessonCompletionDialog(count + 1);
          });
        }
      } catch (_) {}
    }

    setState(() {
      // Each sub-lesson contributes 25%; intro + syllables + tones + intro_quiz = 100%
      pinyinProgress = total;
      greetingsProgress = greetingsTotal;
    });
  }

  void _showLessonCompletionDialog(int totalLessonsCompleted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _LessonCompletionDialog(
          lessonName: 'Pinyin Introduction',
          totalLessonsCompleted: totalLessonsCompleted,
        );
      },
    );
  }

  List<Lesson> get lessons => [
    Lesson(
      id: 'pinyin_intro',
      title: 'Pinyin Introduction',
      description: 'Learn Chinese pronunciation using the Pinyin system',
      progress: pinyinProgress,
      imageAsset: 'assets/image/pinyin.png',
    ),
    Lesson(
      id: 'greetings',
      title: 'Greetings',
      description: 'Learn basic Chinese greetings for daily conversations',
      progress: greetingsProgress,
      imageAsset: 'assets/image/greetings.png',
    ),
    // Lesson(
    //   id: 'name',
    //   title: 'Introduce Yourself',
    //   description: 'Learn how to introduce yourself in Chinese',
    //   progress: 0.0,
    //   imageAsset: 'assets/image/name.png',
    // ),
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
                        return;
                      }

                      if (lesson.id == 'greetings') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GreetingsMenuScreen(),
                          ),
                        );
                        _loadProgress();
                        return;
                      }

                      // if (lesson.id == 'name') {
                      //    await Navigator.push(
                      //      context,
                      //      MaterialPageRoute(
                      //        builder: (_) => const NameMenuScreen(),
                      //      ),
                      //    );
                      //    _loadProgress();
                      //    return;
                      // }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lesson coming soon 👀')),
                      );
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

class _LessonCompletionDialog extends StatefulWidget {
  final String lessonName;
  final int totalLessonsCompleted;

  const _LessonCompletionDialog({
    required this.lessonName,
    required this.totalLessonsCompleted,
  });

  @override
  State<_LessonCompletionDialog> createState() =>
      _LessonCompletionDialogState();
}

class _LessonCompletionDialogState extends State<_LessonCompletionDialog> {
  late ConfettiController _confetti;
  bool _showBadgeUnlock = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();

    // Check if badge was just unlocked
    _showBadgeUnlock =
        widget.totalLessonsCompleted == 1 || widget.totalLessonsCompleted == 3;
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Lesson Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F8EF1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You completed ${widget.lessonName}!',
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _statRow(Icons.check_circle, 'Parts Completed', '4/4'),
                      const SizedBox(height: 16),
                      _statRow(
                        Icons.stars,
                        'Total Lessons',
                        '${widget.totalLessonsCompleted}',
                      ),
                      if (_showBadgeUnlock) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8A5BFF), Color(0xFFD76DFF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.totalLessonsCompleted == 1
                                      ? '🏆 Learning Lv.1 Unlocked!'
                                      : '🏆 Learning Lv.2 Unlocked!',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9F8EF1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9F8EF1), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9F8EF1),
          ),
        ),
      ],
    );
  }
}
