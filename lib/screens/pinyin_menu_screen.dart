import 'package:flutter/material.dart';
import 'package:masterhanyu_app/screens/tones_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pinyin_introduction_screen.dart';
import 'learn_syllables_screen.dart';

class PinyinMenuScreen extends StatefulWidget {
  const PinyinMenuScreen({super.key});

  @override
  State<PinyinMenuScreen> createState() => _PinyinMenuScreenState();
}

class _PinyinMenuScreenState extends State<PinyinMenuScreen> {
  double progress = 0.0;

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

    setState(() {
      progress = (intro + syllables + tones).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 160, 248),
        elevation: 0,
        title: const Text(
          "Introduction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _progressCard(),
            const SizedBox(height: 24),
            _lessonTile(
              icon: Icons.lightbulb,
              color: const Color.fromARGB(255, 63, 63, 231),
              title: 'Pinyin Introduction',
              subtitle: 'What is Pinyin, initials & finals',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PinyinIntroScreen()),
                );
                _loadProgress(); // 🔁 refresh after return
              },
            ),
            _lessonTile(
              icon: Icons.record_voice_over,
              color: const Color.fromARGB(255, 254, 122, 204),
              title: 'Learn Syllables',
              subtitle: 'Listening Pinyin syllables',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LearnSyllablesScreen(),
                  ),
                );
                _loadProgress(); // 🔁 refresh after return
              },
            ),
            _lessonTile(
              icon: Icons.graphic_eq,
              color: const Color.fromARGB(255, 102, 248, 89),
              title: 'Tones',
              subtitle: 'Master the 4 Chinese tones',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TonesScreen()),
                );
                _loadProgress(); // 🔁 refresh after return
              },
            ),
            _lessonTile(
              icon: Icons.question_answer,
              color: const Color.fromARGB(255, 53, 195, 243),
              title: 'Quiz',
              subtitle: 'Test your Pinyin knowledge',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topic Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: Colors.deepPurple,
            backgroundColor: const Color(0xFFE0DFFF),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toInt()}% completed',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _lessonTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
