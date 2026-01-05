import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearnSyllablesScreen extends StatefulWidget {
  const LearnSyllablesScreen({super.key});

  @override
  State<LearnSyllablesScreen> createState() => _LearnSyllablesScreenState();
}

class _LearnSyllablesScreenState extends State<LearnSyllablesScreen> {
  final AudioPlayer _syllablePlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final Stopwatch _stopwatch = Stopwatch();

  final List<String> allSyllables = [
    'ba',
    'mao',
    'ne',
    'teng',
    'hou',
    'kong',
    'qi',
    'jia',
    'qiao',
    'jian',
    'niu',
    'yin',
    'xiong',
    'wu',
    'zhua',
    'shuai',
    'zuan',
    'chuang',
    'cuo',
    'sun',
    'ju',
    'lüe',
    'quan',
    'yun',
    'dang',
    'die',
    'er',
    'fan',
    'gen',
    'lei',
    'mo',
    'pai',
    'qing',
    'rui',
    'xiang',
  ];

  late List<String> quizQueue;
  final List<String> retryQueue = [];

  int index = 0;
  int correct = 0;
  int totalAnswered = 0;
  int earnedXP = 0;
  bool isRetryMode = false;

  bool showResult = false;
  bool isCorrect = false;
  String selected = '';

  @override
  void initState() {
    super.initState();
    quizQueue =
        (List.from(allSyllables)..shuffle()).take(15).toList().cast<String>();
    earnedXP = 0; // Reset earned XP for this session
    isRetryMode = false; // Reset retry mode
    _stopwatch.start();
    _playSyllable();
  }

  // ------------------------------------------------------------
  // AUDIO
  // ------------------------------------------------------------

  Future<void> _playSyllable() async {
    final s = quizQueue[index];
    await _syllablePlayer.stop();
    await _syllablePlayer.setReleaseMode(ReleaseMode.stop);
    await _syllablePlayer.play(
      AssetSource('audio/syllable/$s.mp3'),
      volume: 1.0,
    );
  }

  Future<void> _playCorrect() async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/correct.mp3'), volume: 1.0);
  }

  Future<void> _playWrong() async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/wrong.mp3'), volume: 1.0);
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _syllablePlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // QUIZ LOGIC
  // ------------------------------------------------------------

  void answer(String value) async {
    if (showResult) return;

    final current = quizQueue[index];
    final ok = value == current;

    setState(() {
      selected = value;
      showResult = true;
      isCorrect = ok;
      totalAnswered++;
      if (ok) {
        correct++;
        // Award 2XP for first try, 1XP for retry
        earnedXP += isRetryMode ? 1 : 2;
      } else {
        retryQueue.add(current);
      }
    });

    ok ? _playCorrect() : _playWrong();
  }

  void next() async {
    if (index < quizQueue.length - 1) {
      setState(() {
        index++;
        showResult = false;
        selected = '';
      });
      _playSyllable();
    } else if (retryQueue.isNotEmpty) {
      quizQueue = List.from(retryQueue);
      retryQueue.clear();
      index = 0;
      showResult = false;
      selected = '';
      isRetryMode = true; // Now in retry mode
      setState(() {});
      _playSyllable();
    } else {
      _stopwatch.stop();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      // Calculate minutes with decimals (convert seconds to minutes)
      final sessionMinutes = (_stopwatch.elapsed.inSeconds / 60.0).ceil();

      if (userId != null) {
        await _saveProgress(
          userId: userId,
          earnedXP: earnedXP,
          sessionMinutes: sessionMinutes,
        );
      }

      if (!mounted) return;

      // Show completion dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => _CompletionDialog(
              xp: earnedXP,
              accuracy: ((correct / totalAnswered) * 100).round(),
              timeSpent: _stopwatch.elapsed,
            ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _saveProgress({
    required String userId,
    required int earnedXP,
    required int sessionMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    debugPrint(
      'DEBUG learn_syllables: Saving progress for user=$userId, earnedXP=$earnedXP, sessionMinutes=$sessionMinutes',
    );

    final lastDateKey = 'last_active_date_$userId';
    final lastDate = prefs.getString(lastDateKey);

    // Reset daily stats if new day
    if (lastDate != today) {
      await prefs.setInt('today_xp_$userId', 0);
      await prefs.setInt('today_minutes_$userId', 0);
      await prefs.setString(lastDateKey, today);
    }

    // Total XP
    final totalXP = prefs.getInt('xp_$userId') ?? 0;
    await prefs.setInt('xp_$userId', totalXP + earnedXP);

    // Today XP
    final todayXP = prefs.getInt('today_xp_$userId') ?? 0;
    await prefs.setInt('today_xp_$userId', todayXP + earnedXP);

    // Total time
    final totalMin = prefs.getInt('total_minutes_$userId') ?? 0;
    await prefs.setInt('total_minutes_$userId', totalMin + sessionMinutes);

    // Today time
    final todayMin = prefs.getInt('today_minutes_$userId') ?? 0;
    await prefs.setInt('today_minutes_$userId', todayMin + sessionMinutes);

    debugPrint(
      'DEBUG learn_syllables: Saved - xp_$userId=${totalXP + earnedXP}, today_xp_$userId=${todayXP + earnedXP}',
    );

    // Update lesson progress (Learn Syllables = 25%)
    final progressKey = 'learn_syllables_progress_$userId';
    await prefs.setDouble(progressKey, 0.25);
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final syllable = quizQueue[index];
    final options = _options(syllable);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (index + 1) / quizQueue.length,
            color: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade100,
          ),
          const SizedBox(height: 40),
          const Text(
            'Select what you heard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          IconButton(
            icon: const Icon(
              Icons.volume_up,
              size: 48,
              color: Color.fromARGB(255, 69, 69, 225),
            ),
            onPressed: _playSyllable,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2,
              ),
              itemCount: options.length,
              itemBuilder: (_, i) {
                final opt = options[i];
                final selectedBorder =
                    selected == opt
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.grey.shade300;

                return GestureDetector(
                  onTap: showResult ? null : () => answer(opt),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selectedBorder, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        opt,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showResult) _resultBar(syllable),
        ],
      ),
    );
  }

  Widget _resultBar(String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: isCorrect ? const Color(0xFFDFF5E6) : const Color(0xFFFFDADA),
      child: Column(
        children: [
          Text(
            isCorrect ? 'You are correct!' : 'Correct solution:',
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: next,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
            ),
            child: const Text(
              'CONTINUE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _options(String correct) {
    final r = Random();
    final set = {correct};
    while (set.length < 4) {
      set.add(allSyllables[r.nextInt(allSyllables.length)]);
    }
    return set.toList()..shuffle();
  }
}

// ============================================================
// COMPLETION DIALOG
// ============================================================

class _CompletionDialog extends StatefulWidget {
  final int xp;
  final int accuracy;
  final Duration timeSpent;

  const _CompletionDialog({
    required this.xp,
    required this.accuracy,
    required this.timeSpent,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti overlay
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

        // Dialog
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration emoji
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F8EF1),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  "You've completed this lesson!",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _statRow(Icons.bolt, 'XP Earned', '${widget.xp}'),
                      const SizedBox(height: 16),
                      _statRow(
                        Icons.timer_outlined,
                        'Time',
                        _formatTime(widget.timeSpent),
                      ),
                      const SizedBox(height: 16),
                      _statRow(
                        Icons.track_changes,
                        'Accuracy',
                        '${widget.accuracy}%',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
