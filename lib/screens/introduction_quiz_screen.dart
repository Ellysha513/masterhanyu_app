import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masterhanyu_app/screens/pinyin_menu_screen.dart';

class IntroductionQuizScreen extends StatefulWidget {
  const IntroductionQuizScreen({super.key});

  @override
  State<IntroductionQuizScreen> createState() => _IntroductionQuizScreenState();
}

class _IntroductionQuizScreenState extends State<IntroductionQuizScreen> {
  final AudioPlayer _promptPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final int totalQuestions = 10;
  final _rng = Random();

  late List<_Question> _questions;
  int _index = 0;
  int _correct = 0;
  int _phase1Correct = 0;
  int _hearts = 3;
  String? _selectedChar;
  bool _answered = false;
  bool _wasCorrect = false;

  bool _isPhase2 = false;
  late List<int> _wrongIndices;
  int _phase2Index = 0;

  DateTime _start = DateTime.now();

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _questions = _generateQuestions(totalQuestions);
    _wrongIndices = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPrompt());
  }

  @override
  void dispose() {
    _promptPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  List<_Question> _generateQuestions(int count) {
    // All intro quiz audio files with their phonetic characters
    final questionsBank = [
      _Question(
        pinyin: 'bēn',
        audio: 'audio/intro_quiz/1st_bēn.mp3',
        options: ['bēn', 'bén', 'běn', 'bèn'],
      ),
      _Question(
        pinyin: 'cūn',
        audio: 'audio/intro_quiz/1st_cūn.mp3',
        options: ['cūn', 'cún', 'cǔn', 'cùn'],
      ),
      _Question(
        pinyin: 'huān',
        audio: 'audio/intro_quiz/1st_huān.mp3',
        options: ['huān', 'huán', 'huǎn', 'huàn'],
      ),
      _Question(
        pinyin: 'xiāng',
        audio: 'audio/intro_quiz/1st_xiāng.mp3',
        options: ['xiāng', 'xiáng', 'xiǎng', 'xiàng'],
      ),
      _Question(
        pinyin: 'xūn',
        audio: 'audio/intro_quiz/1st_xūn.mp3',
        options: ['xūn', 'xún', 'xǔn', 'xùn'],
      ),
      _Question(
        pinyin: 'zhuāng',
        audio: 'audio/intro_quiz/1st_zhuāng.mp3',
        options: ['zhuāng', 'zhuáng', 'zhuǎng', 'zhuàng'],
      ),
      _Question(
        pinyin: 'chóu',
        audio: 'audio/intro_quiz/2nd_chóu.mp3',
        options: ['chōu', 'chóu', 'chǒu', 'chòu'],
      ),
      _Question(
        pinyin: 'qié',
        audio: 'audio/intro_quiz/2nd_qié.mp3',
        options: ['qiē', 'qié', 'qiě', 'qiè'],
      ),
      _Question(
        pinyin: 'shá',
        audio: 'audio/intro_quiz/2nd_shá.mp3',
        options: ['shā', 'shá', 'shǎ', 'shà'],
      ),
      _Question(
        pinyin: 'shén',
        audio: 'audio/intro_quiz/2nd_shén.mp3',
        options: ['shēn', 'shén', 'shěn', 'shèn'],
      ),
      _Question(
        pinyin: 'sóng',
        audio: 'audio/intro_quiz/2nd_sóng.mp3',
        options: ['sōng', 'sóng', 'sǒng', 'sòng'],
      ),
      _Question(
        pinyin: 'xióng',
        audio: 'audio/intro_quiz/2nd_xióng.mp3',
        options: ['xiōng', 'xióng', 'xiǒng', 'xiòng'],
      ),
      _Question(
        pinyin: 'zhuó',
        audio: 'audio/intro_quiz/2nd_zhuó.mp3',
        options: ['zhuō', 'zhuó', 'zhuǒ', 'zhuò'],
      ),
      _Question(
        pinyin: 'fǎng',
        audio: 'audio/intro_quiz/3rd_fǎng.mp3',
        options: ['fāng', 'fáng', 'fǎng', 'fàng'],
      ),
      _Question(
        pinyin: 'liǎng',
        audio: 'audio/intro_quiz/3rd_liǎng.mp3',
        options: ['liāng', 'liáng', 'liǎng', 'liàng'],
      ),
      _Question(
        pinyin: 'qǐng',
        audio: 'audio/intro_quiz/3rd_qǐng.mp3',
        options: ['qīng', 'qíng', 'qǐng', 'qìng'],
      ),
      _Question(
        pinyin: 'wǒ',
        audio: 'audio/intro_quiz/3rd_wǒ.mp3',
        options: ['wō', 'wó', 'wǒ', 'wò'],
      ),
      _Question(
        pinyin: 'gùn',
        audio: 'audio/intro_quiz/4th_gùn.mp3',
        options: ['gūn', 'gún', 'gǔn', 'gùn'],
      ),
      _Question(
        pinyin: 'lèi',
        audio: 'audio/intro_quiz/4th_lèi.mp3',
        options: ['lēi', 'léi', 'lěi', 'lèi'],
      ),
      _Question(
        pinyin: 'què',
        audio: 'audio/intro_quiz/4th_què.mp3',
        options: ['quē', 'qué', 'quě', 'què'],
      ),
      _Question(
        pinyin: 'ruì',
        audio: 'audio/intro_quiz/4th_ruì.mp3',
        options: ['ruī', 'ruí', 'ruǐ', 'ruì'],
      ),
      _Question(
        pinyin: 'zuì',
        audio: 'audio/intro_quiz/4th_zuì.mp3',
        options: ['zuī', 'zuí', 'zuǐ', 'zuì'],
      ),
    ];

    // Shuffle and pick random count
    questionsBank.shuffle(_rng);
    return questionsBank.take(count).toList();
  }

  Future<void> _playPrompt() async {
    final qIndex = _isPhase2 ? _wrongIndices[_phase2Index] : _index;
    final q = _questions[qIndex];
    try {
      await _promptPlayer.stop();
      await _promptPlayer.setReleaseMode(ReleaseMode.stop);
      await _promptPlayer.setVolume(1.0);
      debugPrint('Playing intro audio: ${q.audio}');
      await _promptPlayer.play(AssetSource(q.audio));
    } catch (e) {
      debugPrint('Error playing prompt audio: $e');
    }
  }

  Future<void> _playSfx(bool correct) async {
    final path = correct ? 'audio/correct.mp3' : 'audio/wrong.mp3';
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(1.0);
      debugPrint('Playing SFX: $path');
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }

  void _onSelect(String choice) {
    if (_answered) return;
    setState(() {
      _selectedChar = choice;
    });
  }

  Future<void> _onCheck() async {
    if (_selectedChar == null || _answered) return;

    final qIndex = _isPhase2 ? _wrongIndices[_phase2Index] : _index;
    final q = _questions[qIndex];

    final isRight = _selectedChar == q.pinyin;
    setState(() {
      _answered = true;
      _wasCorrect = isRight;
      if (isRight) {
        _correct++; // Increment correct count
        // Track Phase 1 correct answers for accuracy calculation
        if (!_isPhase2) {
          _phase1Correct++;
        }
      } else {
        _hearts--; // Lose a heart on wrong answer
        // In Phase 1, track wrong question indices
        if (!_isPhase2 && !_wrongIndices.contains(qIndex)) {
          _wrongIndices.add(qIndex);
        }
      }
    });
    await _playSfx(isRight);
  }

  Future<void> _onContinue() async {
    if (!_answered) return;

    // Check if game over (hearts reached 0)
    if (_hearts <= 0) {
      if (!mounted) return;
      await _showGameOverDialog();
      return;
    }

    if (!_isPhase2) {
      // PHASE 1: Answer all 10 questions (move forward regardless of right/wrong)
      if (_index < _questions.length - 1) {
        setState(() {
          _index++;
          _answered = false;
          _wasCorrect = false;
          _selectedChar = null;
        });
        await _playPrompt();
      } else {
        // Phase 1 complete - check if there are wrong answers
        if (_wrongIndices.isEmpty) {
          // All correct! Finish quiz
          await _finishQuiz();
        } else {
          // Have wrong answers - enter Phase 2
          setState(() {
            _isPhase2 = true;
            _phase2Index = 0;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        }
      }
    } else {
      // PHASE 2: Re-answer wrong questions
      if (_phase2Index < _wrongIndices.length - 1) {
        setState(() {
          _phase2Index++;
          _answered = false;
          _wasCorrect = false;
          _selectedChar = null;
        });
        await _playPrompt();
      } else {
        // Phase 2 complete - finish quiz and save progress
        await _finishQuiz();
      }
    }
  }

  Future<void> _showGameOverDialog() async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/try_again.mp3'));
    } catch (e) {
      debugPrint('Error playing try again audio: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😢', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Try Again!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE74C3C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You ran out of hearts. Please review the lesson and try again!",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _statRow(
                        Icons.check_circle_outline,
                        'Correct Answers',
                        '$_correct/$totalQuestions',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const PinyinMenuScreen(),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'BACK TO LESSON',
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
        );
      },
    );
  }

  Future<void> _finishQuiz() async {
    final elapsed = DateTime.now().difference(_start);
    final elapsedSeconds = elapsed.inSeconds;
    final minutes = (elapsedSeconds / 60).ceil();
    final earnedXp = totalQuestions; // 1 XP per question
    final accuracy =
        _phase1Correct == 0
            ? 0
            : ((_phase1Correct / totalQuestions) * 100).round();

    await _saveProgress(earnedXp, minutes);

    // Track high-accuracy completion for badges
    if (accuracy >= 90) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final key = 'learn_syllables_high_accuracy_count_$userId';
          final count = prefs.getInt(key) ?? 0;
          await prefs.setInt(key, count + 1);
        }
      } catch (_) {}
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _CompletionDialog(
          xp: earnedXp,
          accuracy: accuracy,
          timeText: _formatDuration(elapsed),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/finish.mp3'));
    } catch (e) {
      debugPrint('Error playing finish audio: $e');
    }
  }

  Future<void> _saveProgress(int earnedXp, int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final today = DateTime.now().toIso8601String().substring(0, 10);

      final lastDateKey = 'last_active_date_$userId';
      final lastDate = prefs.getString(lastDateKey);

      // Reset daily stats if new day
      if (lastDate != today) {
        await prefs.setInt('today_xp_$userId', 0);
        await prefs.setInt('today_minutes_$userId', 0);
        await prefs.setString(lastDateKey, today);
      }

      final xpKey = 'xp_$userId';
      final todayXpKey = 'today_xp_$userId';
      final minutesKey = 'total_minutes_$userId';
      final todayMinutesKey = 'today_minutes_$userId';

      final xpDailyKey = 'xp_daily_$userId$today';
      final minutesDailyKey = 'minutes_daily_$userId$today';

      final currentXp = prefs.getInt(xpKey) ?? 0;
      final currentTodayXp = prefs.getInt(todayXpKey) ?? 0;
      final currentMinutes = prefs.getInt(minutesKey) ?? 0;
      final currentTodayMinutes = prefs.getInt(todayMinutesKey) ?? 0;
      final currentDailyXp = prefs.getInt(xpDailyKey) ?? 0;
      final currentDailyMinutes = prefs.getInt(minutesDailyKey) ?? 0;

      await prefs.setInt(xpKey, currentXp + earnedXp);
      await prefs.setInt(todayXpKey, currentTodayXp + earnedXp);
      await prefs.setInt(minutesKey, currentMinutes + minutes);
      await prefs.setInt(todayMinutesKey, currentTodayMinutes + minutes);
      await prefs.setInt(xpDailyKey, currentDailyXp + earnedXp);
      await prefs.setInt(minutesDailyKey, currentDailyMinutes + minutes);

      final introProgressKey = 'introduction_quiz_progress_$userId';
      await prefs.setDouble(introProgressKey, 1.0);
    } catch (_) {}
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE74C3C), size: 24),
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
            color: Color(0xFFE74C3C),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final qIndex = _isPhase2 ? _wrongIndices[_phase2Index] : _index;
    final q = _questions[qIndex];
    final progress =
        _isPhase2
            ? (_phase2Index + 1) / _wrongIndices.length
            : (_index + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6E6E6),
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.favorite,
                          color:
                              i < _hearts
                                  ? const Color(0xFFE74C3C)
                                  : Colors.grey.shade300,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Select what you heard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _playPrompt,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E4FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF6550F5),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _selectedChar ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final option in q.options)
                      _OptionChip(
                        label: option,
                        selected: _selectedChar == option,
                        disabled: _answered,
                        onTap: () => _onSelect(option),
                      ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    _answered
                        ? Container(
                          key: const ValueKey('feedback-panel'),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color:
                                _wasCorrect
                                    ? const Color(0xFFD1F0ED)
                                    : const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _wasCorrect
                                    ? 'You are correct!'
                                    : 'Correct solution:',
                                style: TextStyle(
                                  color:
                                      _wasCorrect
                                          ? const Color(0xFF1BA8A8)
                                          : const Color(0xFFE74C3C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Text(
                                  q.pinyin,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox(key: ValueKey('feedback-empty')),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _answered
                        ? _onContinue
                        : (_selectedChar != null ? _onCheck : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      !_answered
                          ? (_selectedChar != null
                              ? const Color(0xFF22C1A0)
                              : Colors.grey[300])
                          : (_wasCorrect
                              ? const Color(0xFF22C1A0)
                              : const Color(0xFFDA3A3A)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(_answered ? 'CONTINUE' : 'CHECK'),
              ),
            ),
          ],
        ),
      ),
    );
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
                      _statRow(Icons.bolt, 'XP Earned', '${widget.xp}'),
                      const SizedBox(height: 16),
                      _statRow(Icons.timer_outlined, 'Time', widget.timeText),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const PinyinMenuScreen(),
                        ),
                        (route) => route.isFirst,
                      );
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

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF22C1A0) : const Color(0xFFF2F2F2);
    final fg = selected ? Colors.white : Colors.black87;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Question {
  final String pinyin;
  final String audio;
  final List<String> options;

  const _Question({
    required this.pinyin,
    required this.audio,
    required this.options,
  });
}
