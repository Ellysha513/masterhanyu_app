import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../widgets/animated_progress.dart';
import '../utils/time_formatter.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile user;
  final Function(int) onQuickAccessTap;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onQuickAccessTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int todayXP = 0;
  int todayMinutes = 0;
  double pinyinProgress = 0.0;
  String _focusTitle = "Introduction";
  String _focusSubtitle = "Learn pinyin, syllables & tones";
  bool _isInitialized = false;
  bool _refreshScheduled = false;
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodayStats();
    _loadLearnStatus();
    _isInitialized = true;
    _needsRefresh = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    if (_isInitialized) {
      _needsRefresh = true;
      _scheduleRefresh();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      _needsRefresh = true;
      _scheduleRefresh();
    }
  }

  Future<void> _loadTodayStats() async {
    final prefs = await SharedPreferences.getInstance();
    final id = widget.user.id;

    // Reset daily stats if it's a new day
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDateKey = 'last_active_date_$id';
    final lastDate = prefs.getString(lastDateKey);
    if (lastDate != today) {
      await prefs.setInt('today_xp_$id', 0);
      await prefs.setInt('today_minutes_$id', 0);
      await prefs.setString(lastDateKey, today);
    }

    if (mounted) {
      setState(() {
        todayXP = prefs.getInt('today_xp_$id') ?? 0;
        todayMinutes = prefs.getInt('today_minutes_$id') ?? 0;
      });
    }
  }

  Future<void> _loadLearnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = widget.user.id;

    final intro = prefs.getDouble('pinyin_intro_progress_$id') ?? 0.0;
    final syllables = prefs.getDouble('learn_syllables_progress_$id') ?? 0.0;
    final tones = prefs.getDouble('tones_quiz_progress_$id') ?? 0.0;
    final introQuiz = prefs.getDouble('introduction_quiz_progress_$id') ?? 0.0;

    final total = ((intro + syllables + tones + introQuiz) / 4).clamp(0.0, 1.0);

    String focusTitle;
    String focusSubtitle;
    if (intro < 0.25) {
      focusTitle = 'Introduction';
      focusSubtitle = 'Start with Pinyin basics';
    } else if (syllables < 0.25) {
      focusTitle = 'Syllables';
      focusSubtitle = 'Practice initials and finals';
    } else if (tones < 0.25) {
      focusTitle = 'Tones Quiz';
      focusSubtitle = 'Master the four tones';
    } else {
      focusTitle = 'Review';
      focusSubtitle = "You're all caught up!";
    }

    if (!mounted) return;
    setState(() {
      pinyinProgress = total;
      _focusTitle = focusTitle;
      _focusSubtitle = focusSubtitle;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _needsRefresh = true;
      _scheduleRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    _needsRefresh = true;
    _scheduleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleRefresh();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 20),

              _welcomeCard(),
              const SizedBox(height: 20),

              _todayStats(),
              const SizedBox(height: 24),

              _todayFocus(context),
              const SizedBox(height: 20),

              _activeCourse(),
              const SizedBox(height: 20),

              _learningTip(),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleRefresh() {
    if (_refreshScheduled || !_needsRefresh) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refreshScheduled = false;
      _needsRefresh = false;
      await Future.wait([_loadTodayStats(), _loadLearnStatus()]);
    });
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
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
            Text(
              'MasterHanyu',
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
            const Text(
              'MasterHanyu',
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

  // ------------------------------------------------------------
  // WELCOME CARD
  // ------------------------------------------------------------
  Widget _welcomeCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${widget.user.name.isNotEmpty ? widget.user.name : widget.user.username}!",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Ready to continue your Chinese learning journey?",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow("Your Level", "Beginner", Colors.blue),
                SizedBox(height: 6),
                _InfoRow("Learning Progress", "32%", Colors.orange),
                SizedBox(height: 10),
                AnimatedProgressBar(
                  value: 0.32,
                  height: 8,
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TODAY'S STATS (NEW)
  // ------------------------------------------------------------
  Widget _todayStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Today's XP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$todayXP XP",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Study Time",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatMinutes(todayMinutes),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TODAY'S FOCUS ⭐
  // ------------------------------------------------------------
  Widget _todayFocus(BuildContext context) {
    return _card(
      title: "Today's Focus",
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.deepPurple.shade100,
            child: const Icon(
              Icons.record_voice_over,
              color: Colors.deepPurple,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _focusTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _focusSubtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => widget.onQuickAccessTap(1),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF5C56D6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTIVE COURSE
  // ------------------------------------------------------------
  Widget _activeCourse() {
    return _card(
      title: "Active Lesson",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Introduction to Chinese",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${(pinyinProgress * 100).round()}% complete",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          AnimatedProgressBar(
            value: pinyinProgress,
            height: 6,
            activeColor: const Color.fromARGB(255, 248, 151, 240),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LEARNING TIP
  // ------------------------------------------------------------
  Widget _learningTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA726).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Pro Tip",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Listen first, then repeat. Tones are everything in Chinese!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CARD WRAPPER
  // ------------------------------------------------------------
  Widget _card({String? title, Gradient? gradient, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? Colors.white : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// SMALL COMPONENTS
// ------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final String left;
  final String right;
  final Color color;
  const _InfoRow(this.left, this.right, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left),
        Text(
          right,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedButton({required this.label, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 99, 78, 221),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
