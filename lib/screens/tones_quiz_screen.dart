import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masterhanyu_app/screens/pinyin_menu_screen.dart';

class TonesQuizScreen extends StatefulWidget {
  const TonesQuizScreen({super.key});

  @override
  State<TonesQuizScreen> createState() => _TonesQuizScreenState();
}

class _TonesQuizScreenState extends State<TonesQuizScreen> {
  final AudioPlayer _promptPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final int totalQuestions = 10;
  final _rng = Random();

  late List<_Question> _questions;
  late List<int> _wrongIndexes;
  int _index = 0;
  int _correct = 0;
  int _wrongAttempts = 0;
  String? _selectedChar;
  bool _answered = false;
  bool _wasCorrect = false;
  late List<bool> _solved;
  bool _isRetryMode = false;

  DateTime _start = DateTime.now();

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _questions = _generateQuestions(totalQuestions);
    _wrongIndexes = [];
    _solved = List<bool>.filled(totalQuestions, false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPrompt());
  }

  @override
  void dispose() {
    _promptPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  List<_Question> _generateQuestions(int count) {
    const aTones = [
      _Tone('ā', 'audio/tones/1st_ā.mp3'),
      _Tone('á', 'audio/tones/2nd_á.mp3'),
      _Tone('ǎ', 'audio/tones/3rd_ǎ.mp3'),
      _Tone('à', 'audio/tones/4th_à.mp3'),
    ];

    final syllableGroups = [
      _SyllableGroup(
        promptTones: aTones,
        optionChars: const ['ā', 'á', 'ǎ', 'à'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('duō', 'audio/tones/1st_duō.mp3')],
        optionChars: const ['duō', 'duó', 'duǒ', 'duò'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('zī', 'audio/tones/1st_zī.mp3')],
        optionChars: const ['zī', 'zí', 'zǐ', 'zì'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('ú', 'audio/tones/2nd_ú.mp3')],
        optionChars: const ['ū', 'ú', 'ǔ', 'ù'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('fǎ', 'audio/tones/3rd_fǎ.mp3')],
        optionChars: const ['fā', 'fá', 'fǎ', 'fà'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('ǐ', 'audio/tones/3rd_ǐ.mp3')],
        optionChars: const ['ī', 'í', 'ǐ', 'ì'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('gù', 'audio/tones/4th_gù.mp3')],
        optionChars: const ['gū', 'gú', 'gǔ', 'gù'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('wò', 'audio/tones/4th_wò.mp3')],
        optionChars: const ['wō', 'wó', 'wǒ', 'wò'],
      ),
      _SyllableGroup(
        promptTones: const [_Tone('xiè', 'audio/tones/4th_xiè.mp3')],
        optionChars: const ['xiē', 'xié', 'xiě', 'xiè'],
      ),
    ];

    final list = <_Question>[];
    final usedAudios = <String>{};

    for (var i = 0; i < count; i++) {
      _SyllableGroup group;
      _Tone prompt;
      do {
        group = syllableGroups[_rng.nextInt(syllableGroups.length)];
        prompt = group.promptTones[_rng.nextInt(group.promptTones.length)];
      } while (usedAudios.contains(prompt.audio) && usedAudios.length < 10);

      usedAudios.add(prompt.audio);
      final correct = _Tone(prompt.char, prompt.audio);
      final options =
          group.optionChars.map((c) => _Tone(c, prompt.audio)).toList();
      options.shuffle(_rng);
      list.add(_Question(correct: correct, options: options));
    }

    list.shuffle(_rng);
    return list;
  }

  Future<void> _playPrompt() async {
    final questionIndex = _isRetryMode ? _wrongIndexes[_index] : _index;
    final q = _questions[questionIndex];
    try {
      await _promptPlayer.stop();
      await _promptPlayer.setReleaseMode(ReleaseMode.stop);
      await _promptPlayer.setVolume(1.0);
      debugPrint('Playing tone audio: ${q.correct.audio}');
      await _promptPlayer.play(AssetSource(q.correct.audio));
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

  void _onSelect(_Tone choice) {
    if (_answered) return;
    setState(() {
      _selectedChar = choice.char;
    });
  }

  Future<void> _onCheck() async {
    if (_selectedChar == null || _answered) return;
    final questionIndex = _isRetryMode ? _wrongIndexes[_index] : _index;
    final q = _questions[questionIndex];
    final isRight = _selectedChar == q.correct.char;
    setState(() {
      _answered = true;
      _wasCorrect = isRight;
      if (isRight && !_solved[questionIndex]) {
        _correct++;
        _solved[questionIndex] = true;
      }
      if (!isRight) {
        _wrongAttempts++;
        if (!_isRetryMode && !_wrongIndexes.contains(questionIndex)) {
          _wrongIndexes.add(questionIndex);
        }
      }
    });
    await _playSfx(isRight);
  }

  Future<void> _onContinue() async {
    if (!_answered) return;

    if (_wasCorrect) {
      if (!_isRetryMode) {
        if (_index < totalQuestions - 1) {
          setState(() {
            _index++;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        } else {
          // Completed all main questions correctly, check for retry
          if (_wrongIndexes.isNotEmpty) {
            setState(() {
              _isRetryMode = true;
              _index = 0;
              _answered = false;
              _wasCorrect = false;
              _selectedChar = null;
            });
            await _playPrompt();
          } else {
            await _finishQuiz();
          }
        }
      } else {
        if (_index < _wrongIndexes.length - 1) {
          setState(() {
            _index++;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        } else {
          await _finishQuiz();
        }
      }
    } else {
      // User got it wrong, move to next question
      if (!_isRetryMode) {
        if (_index < totalQuestions - 1) {
          setState(() {
            _index++;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        } else {
          // Last question of main quiz, always enter retry if there are wrong answers
          setState(() {
            _isRetryMode = true;
            _index = 0;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        }
      } else {
        // In retry mode and got it wrong, move to next retry question
        if (_index < _wrongIndexes.length - 1) {
          setState(() {
            _index++;
            _answered = false;
            _wasCorrect = false;
            _selectedChar = null;
          });
          await _playPrompt();
        } else {
          // All retries done
          await _finishQuiz();
        }
      }
    }
  }

  Future<void> _finishQuiz() async {
    final elapsed = DateTime.now().difference(_start);
    final elapsedSeconds = elapsed.inSeconds;
    final minutes = (elapsedSeconds / 60).ceil();
    final earnedXp = _correct;
    final attempts = _correct + _wrongAttempts;
    final accuracy = attempts == 0 ? 0 : ((_correct / attempts) * 100).round();

    await _saveProgress(earnedXp, minutes);

    // Track high-accuracy completion for badges
    if (accuracy >= 90) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final key = 'tones_quiz_high_accuracy_count_$userId';
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

      final tonesProgressKey = 'tones_quiz_progress_$userId';
      final existingProgress = prefs.getDouble(tonesProgressKey) ?? 0.0;
      if (existingProgress < 0.25) {
        await prefs.setDouble(tonesProgressKey, 0.25);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final questionIndex = _isRetryMode ? _wrongIndexes[_index] : _index;
    final q = _questions[questionIndex];
    final progress =
        _isRetryMode
            ? (_index + 1) / _wrongIndexes.length
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
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE6E6E6),
              color: Colors.deepPurple,
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
                    for (final t in q.options)
                      _OptionChip(
                        label: t.char,
                        selected: false,
                        disabled: _answered,
                        onTap: () => _onSelect(t),
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
                                  q.correct.char,
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
                        (route) => route.isFirst, // Keep only learn_screen
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

class _Tone {
  final String char;
  final String audio;
  const _Tone(this.char, this.audio);
}

class _SyllableGroup {
  final List<_Tone> promptTones;
  final List<String> optionChars;
  const _SyllableGroup({required this.promptTones, required this.optionChars});
}

class _Question {
  final _Tone correct;
  final List<_Tone> options;
  const _Question({required this.correct, required this.options});
}
