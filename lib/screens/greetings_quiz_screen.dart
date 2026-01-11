import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GreetingsQuizScreen extends StatelessWidget {
  const GreetingsQuizScreen({super.key});

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await prefs.setDouble('greetings_quiz_progress_$userId', 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Greetings Quiz')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _saveProgress();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Mark Quiz Completed'),
        ),
      ),
    );
  }
}
