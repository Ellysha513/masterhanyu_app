import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class LearnGreetingsScreen extends StatefulWidget {
  const LearnGreetingsScreen({super.key});

  @override
  State<LearnGreetingsScreen> createState() => _LearnGreetingsScreenState();
}

class _LearnGreetingsScreenState extends State<LearnGreetingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  bool _hasAnswered = false;
  int _phase1Correct = 0;
  final List<int> _wrongIndices = [];
  bool _isPhase2 = false;
  late DateTime _start;
  bool _warnedMissingAudio = false;

  final List<GreetingPair> _greetingPairs = [
    GreetingPair('audio/greetings/zǎo_ān.mp3', 'zǎo ān', 'Good morning'),
    GreetingPair('audio/greetings/wǔ_ān.mp3', 'wǔ ān', 'Good afternoon'),
    GreetingPair(
      'audio/greetings/wǎnshang_hǎo.mp3',
      'wǎnshang hǎo',
      'Good evening',
    ),
    GreetingPair('audio/greetings/wǎn_ān.mp3', 'wǎn ān', 'Good night'),
    GreetingPair('audio/greetings/nǐhǎo.mp3', 'nǐhǎo', 'Hello'),
    GreetingPair(
      'audio/greetings/nǐhǎo_ma.mp3',
      'wǒ hěn hǎo',
      'I\'m very well',
    ),
    GreetingPair(
      'audio/greetings/hǎojiǔ_bújiàn.mp3',
      'hǎojiǔ bújiàn',
      'Long time no see',
    ),
    GreetingPair('audio/greetings/zàijiàn.mp3', 'zàijiàn', 'Goodbye'),
    GreetingPair('audio/greetings/xièxie.mp3', 'bú kèqi', 'You\'re welcome'),
    GreetingPair('audio/greetings/duìbuqǐ.mp3', 'méi guānxi', 'No problem'),
  ];

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _generateQuestions();
    _playCurrentAudio();
  }

  void _generateQuestions() {
    final random = Random();
    final shuffled = List<GreetingPair>.from(_greetingPairs)..shuffle(random);

    _questions =
        shuffled.map((pair) {
          final correctAnswer = pair.response;
          final wrongAnswers =
              _greetingPairs
                  .where((p) => p.response != correctAnswer)
                  .map((p) => p.response)
                  .toList()
                ..shuffle(random);

          final options = [correctAnswer, ...wrongAnswers.take(3)]
            ..shuffle(random);

          return QuizQuestion(
            audioPath: pair.audioPath,
            correctAnswer: correctAnswer,
            correctTranslation: pair.translation,
            options:
                options.map((opt) {
                  final match = _greetingPairs.firstWhere(
                    (p) => p.response == opt,
                  );
                  return AnswerOption(opt, match.translation);
                }).toList(),
          );
        }).toList();
  }

  Future<void> _playCurrentAudio() async {
    if (_currentQuestionIndex < _questions.length) {
      try {
        await _audioPlayer.play(
          AssetSource(_questions[_currentQuestionIndex].audioPath),
        );
      } catch (e) {
        debugPrint('Error playing audio: $e');
        if (mounted && !_warnedMissingAudio) {
          _warnedMissingAudio = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio unavailable for this question, skipping.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _playSfx(String assetPath) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sfx: $e');
    }
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswerIndex = index;
    });
  }

  Future<void> _checkAnswer() async {
    if (_selectedAnswerIndex == -1 || _hasAnswered) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect =
        question.options[_selectedAnswerIndex].text == question.correctAnswer;

    setState(() {
      _hasAnswered = true;

      if (isCorrect) {
        if (!_isPhase2) {
          _phase1Correct++;
        }
      } else {
        if (!_isPhase2) {
          _wrongIndices.add(_currentQuestionIndex);
        }
      }
    });

    await _playSfx(isCorrect ? 'audio/correct.mp3' : 'audio/wrong.mp3');
  }

  void _nextQuestion() {
    if (!_hasAnswered) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _hasAnswered = false;
      });
      _playCurrentAudio();
    } else {
      // Phase 1 complete
      if (_wrongIndices.isNotEmpty && !_isPhase2) {
        setState(() {
          _isPhase2 = true;
          _questions = _wrongIndices.map((i) => _questions[i]).toList();
          _wrongIndices.clear();
          _currentQuestionIndex = 0;
          _selectedAnswerIndex = -1;
          _hasAnswered = false;
        });
        _playCurrentAudio();
      } else {
        _finishQuiz();
      }
    }
  }

  Future<void> _finishQuiz() async {
    final elapsed = DateTime.now().difference(_start);
    final elapsedSeconds = elapsed.inSeconds;
    final minutes = (elapsedSeconds / 60).ceil();
    final earnedXp = 10; // 1 XP per question
    final accuracy = (_phase1Correct / 10) * 100;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        final today = DateTime.now().toIso8601String().substring(0, 10);

        // Save progress for greetings_menu_screen.dart and learn_screen.dart
        await prefs.setDouble('learn_greetings_progress_$userId', 1.0);

        // Save XP
        final totalXP = (prefs.getInt('xp_$userId') ?? 0) + earnedXp;
        await prefs.setInt('xp_$userId', totalXP);

        // Save today's XP
        final todayXP = (prefs.getInt('today_xp_$userId') ?? 0) + earnedXp;
        await prefs.setInt('today_xp_$userId', todayXP);

        // Save total minutes
        final totalMinutes =
            (prefs.getInt('total_minutes_$userId') ?? 0) + minutes;
        await prefs.setInt('total_minutes_$userId', totalMinutes);

        // Save today's minutes
        final todayMinutes =
            (prefs.getInt('today_minutes_$userId') ?? 0) + minutes;
        await prefs.setInt('today_minutes_$userId', todayMinutes);

        // Save daily tracking for graph
        final dailyXPKey = 'xp_daily_$userId$today';
        final dailyMinutesKey = 'minutes_daily_$userId$today';

        final dailyXP = (prefs.getInt(dailyXPKey) ?? 0) + earnedXp;
        await prefs.setInt(dailyXPKey, dailyXP);

        final dailyMinutesVal = (prefs.getInt(dailyMinutesKey) ?? 0) + minutes;
        await prefs.setInt(dailyMinutesKey, dailyMinutesVal);

        // Badge tracking for Bullseye badge (high accuracy count)
        if (accuracy >= 90) {
          final currentCount =
              prefs.getInt('learn_syllables_high_accuracy_count_$userId') ?? 0;
          await prefs.setInt(
            'learn_syllables_high_accuracy_count_$userId',
            currentCount + 1,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }

    if (!mounted) return;

    await _playSfx('audio/finish.mp3');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _CompletionDialog(
          xp: earnedXp,
          accuracy: accuracy.toInt(),
          timeText: _formatDuration(elapsed),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 160, 248),
        elevation: 0,
        title: const Text(
          'Learn Greetings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentQuestionIndex + 1) / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 25, 194),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Choose the correct response based on what you heard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildAudioButton(),
                    const SizedBox(height: 24),
                    ..._buildAnswerOptions(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _hasAnswered ? _nextQuestion : () => _checkAnswer(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F8EF1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _hasAnswered ? 'CONTINUE' : 'CHECK',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton() {
    return Center(
      child: GestureDetector(
        onTap: _playCurrentAudio,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFB8A7FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.volume_up, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions() {
    final question = _questions[_currentQuestionIndex];
    return List.generate(question.options.length, (index) {
      final option = question.options[index];
      final isSelected = _selectedAnswerIndex == index;
      final isCorrect = _hasAnswered && option.text == question.correctAnswer;
      final isWrong = _hasAnswered && isSelected && !isCorrect;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => _selectAnswer(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isCorrect
                      ? Colors.green[100]
                      : isWrong
                      ? Colors.red[100]
                      : isSelected
                      ? const Color(0xFFE8DFFF)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isCorrect
                        ? Colors.green
                        : isWrong
                        ? Colors.red
                        : isSelected
                        ? const Color(0xFF9F8EF1)
                        : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isCorrect
                                  ? Colors.green[900]
                                  : isWrong
                                  ? Colors.red[900]
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(${option.translation})',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (_hasAnswered && (isCorrect || isWrong))
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}

class _CompletionDialog extends StatefulWidget {
  final int xp;
  final int accuracy;
  final String timeText;

  const _CompletionDialog({
    required this.xp,
    required this.accuracy,
    required this.timeText,
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
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F8EF1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You've completed this lesson!",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
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
                      _statRow(Icons.star, 'XP', '${widget.xp}'),
                      const SizedBox(height: 16),
                      _statRow(
                        Icons.trending_up,
                        'Accuracy',
                        '${widget.accuracy}%',
                      ),
                      const SizedBox(height: 16),
                      _statRow(Icons.schedule, 'Time Spent', widget.timeText),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
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

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class GreetingPair {
  final String audioPath;
  final String response;
  final String translation;

  GreetingPair(this.audioPath, this.response, this.translation);
}

class QuizQuestion {
  final String audioPath;
  final String correctAnswer;
  final String correctTranslation;
  final List<AnswerOption> options;

  QuizQuestion({
    required this.audioPath,
    required this.correctAnswer,
    required this.correctTranslation,
    required this.options,
  });
}

class AnswerOption {
  final String text;
  final String translation;

  AnswerOption(this.text, this.translation);
}
