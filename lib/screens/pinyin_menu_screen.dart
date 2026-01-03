import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pinyin_introduction_screen.dart';

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

    setState(() {
      progress = prefs.getDouble('pinyin_intro_progress_$userId') ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        title: const Text('Intoduction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
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
              color: const Color.fromARGB(255, 101, 101, 230),
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
              subtitle: 'Pronounce Pinyin syllables',
              onTap: () {},
            ),
            _lessonTile(
              icon: Icons.graphic_eq,
              color: const Color.fromARGB(255, 102, 248, 89),
              title: 'Tones',
              subtitle: 'Master the 4 Chinese tones',
              onTap: () {},
            ),
            _lessonTile(
              icon: Icons.question_answer,
              color: const Color.fromARGB(255, 53, 195, 243),
              title: 'Quiz',
              subtitle: 'Test your pronunciation and listening skills',
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
