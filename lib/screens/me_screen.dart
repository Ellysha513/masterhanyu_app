import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user_profile.dart';
import '../theme/app_background.dart';
import '../widgets/stat_graph_sheet.dart';
import '../utils/time_formatter.dart';
import 'account_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeScreen extends StatefulWidget {
  final UserProfile user;

  // GlobalKey to access state for manual refresh
  final GlobalKey<_MeScreenState> _stateKey = GlobalKey<_MeScreenState>();

  MeScreen({super.key, required this.user});

  @override
  State<MeScreen> createState() => _MeScreenState();

  void refreshStats() {
    _stateKey.currentState?.refreshStatsNow();
  }
}

class _MeScreenState extends State<MeScreen> with WidgetsBindingObserver {
  int totalXP = 0;
  int todayXP = 0;
  int totalMinutes = 0;
  int todayMinutes = 0;
  UserProfile? _userOverride;
  UserProfile get user => _userOverride ?? widget.user;
  bool _refreshScheduled = false;
  bool _needsRefresh = false;

  Future<void> _loadStats() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final id = user.id;

    // Check if it's a new day and reset daily stats if needed
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
        totalXP = prefs.getInt('xp_$id') ?? 0;
        todayXP = prefs.getInt('today_xp_$id') ?? 0;
        totalMinutes = prefs.getInt('total_minutes_$id') ?? 0;
        todayMinutes = prefs.getInt('today_minutes_$id') ?? 0;
      });
    }
  }

  /// Get last 7 days of XP data for the graph
  Future<List<double>> _getLast7DaysXP() async {
    final prefs = await SharedPreferences.getInstance();
    final id = user.id;
    final data = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      final key = 'xp_daily_$id$dateStr';
      final xp = prefs.getInt(key) ?? 0;
      data.add(xp.toDouble());
    }

    return data;
  }

  /// Get last 7 days of minutes data for the graph
  Future<List<double>> _getLast7DaysMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final id = user.id;
    final data = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);
      final key = 'minutes_daily_$id$dateStr';
      final minutes = prefs.getInt(key) ?? 0;
      data.add(minutes.toDouble());
    }

    return data;
  }

  Future<void> _reloadUserFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final data =
          await client
              .from('profiles')
              .select('name, age, gender, avatar_url')
              .eq('id', user.id)
              .maybeSingle();

      if (!mounted || data == null) return;

      setState(() {
        _userOverride = UserProfile(
          id: widget.user.id,
          username: widget.user.username,
          email: widget.user.email,
          name: (data['name'] as String?)?.trim() ?? '',
          age: (data['age'] as int?) ?? 0,
          gender:
              (data['gender'] as String?)?.trim().isNotEmpty == true
                  ? (data['gender'] as String).trim()
                  : 'Female',
          imagePath: data['avatar_url'] as String?,
        );
      });
    } catch (_) {
      // If fetch fails, keep existing user data
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStats();
    _needsRefresh = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats whenever the widget's dependencies change
    // This helps when switching between tabs
    // Use addPostFrameCallback to ensure timing is correct after screen transition
    _needsRefresh = true;
    _scheduleRefresh();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _needsRefresh = true;
      _scheduleRefresh();
    }
  }

  void refreshStatsNow() {
    _loadStats();
  }

  void _scheduleRefresh() {
    if (_refreshScheduled || !_needsRefresh) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refreshScheduled = false;
      _needsRefresh = false;
      await _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleRefresh();
    return Scaffold(
      body: Container(
        decoration: masterHanyuBackground(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _profileCard(context),
                const SizedBox(height: 24),
                _statistics(context),
                const SizedBox(height: 24),
                _badges(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
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
              'Profile',
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
              'Profile',
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
  // PROFILE CARD
  // ------------------------------------------------------------
  Widget _profileCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountSettingsScreen(user: user),
            ),
          );
          await _reloadUserFromSupabase();
          _loadStats(); // Refresh stats after returning
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.deepPurple,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        backgroundImage:
            user.imagePath != null
                ? CachedNetworkImageProvider(user.imagePath!)
                : null,
        child:
            user.imagePath == null
                ? Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                )
                : null,
      ),
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------
  Widget _statistics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StatCard(title: "$totalXP XP", subtitle: "Total XP"),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: "$todayXP XP",
                  subtitle: "Today's XP",
                  isClickable: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: formatMinutes(totalMinutes),
                  subtitle: "Total time",
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: formatMinutes(todayMinutes),
                  subtitle: "Today's time",
                  isClickable: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BADGES
  // ------------------------------------------------------------
  Widget _badges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Badges",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>>(
            future: _loadBadgeStatus(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final badges = snapshot.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BadgeCategory(
                    title: 'Learning',
                    lvl1Image: 'assets/image/lvl1_lesson.png',
                    lvl2Image: 'assets/image/lvl2_lesson.png',
                    lvl1Earned: badges['lvl1_lesson'] as bool,
                    lvl2Earned: badges['lvl2_lesson'] as bool,
                    lvl1Text: badges['lesson_progress'] as String,
                    lvl2Text: badges['lesson_progress2'] as String,
                  ),
                  _BadgeCategory(
                    title: 'Bullseye',
                    lvl1Image: 'assets/image/lvl1_quiz.png',
                    lvl2Image: 'assets/image/lvl2_quiz.png',
                    lvl1Earned: badges['lvl1_quiz'] as bool,
                    lvl2Earned: badges['lvl2_quiz'] as bool,
                    lvl1Text: badges['quiz_progress'] as String,
                    lvl2Text: badges['quiz_progress2'] as String,
                  ),
                  _BadgeCategory(
                    title: 'Marathon Pro',
                    lvl1Image: 'assets/image/lvl1_time.png',
                    lvl2Image: 'assets/image/lvl2_time.png',
                    lvl1Earned: badges['lvl1_time'] as bool,
                    lvl2Earned: badges['lvl2_time'] as bool,
                    lvl1Text: badges['time_progress'] as String,
                    lvl2Text: badges['time_progress2'] as String,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadBadgeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = user.id;

    final lessonsCompleted = prefs.getInt('lessons_completed_$id') ?? 0;
    final quizHighAccuracy =
        (prefs.getInt('tones_quiz_high_accuracy_count_$id') ?? 0) +
        (prefs.getInt('learn_syllables_high_accuracy_count_$id') ?? 0);
    final totalMinutes = prefs.getInt('total_minutes_$id') ?? 0;

    return {
      'lvl1_lesson': lessonsCompleted >= 1,
      'lvl2_lesson': lessonsCompleted >= 3,
      'lvl1_quiz': quizHighAccuracy >= 5,
      'lvl2_quiz': quizHighAccuracy >= 10,
      'lvl1_time': totalMinutes >= 30,
      'lvl2_time': totalMinutes >= 60,
      'lesson_progress': '${lessonsCompleted.clamp(0, 1)}/1 lesson',
      'lesson_progress2': '${lessonsCompleted.clamp(0, 3)}/3 lessons',
      'quiz_progress': '${quizHighAccuracy.clamp(0, 5)}/5 high scores',
      'quiz_progress2': '${quizHighAccuracy.clamp(0, 10)}/10 high scores',
      'time_progress': '${totalMinutes.clamp(0, 30)}/30 mins',
      'time_progress2': '${totalMinutes.clamp(0, 60)}/60 mins',
    };
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isClickable;

  const StatCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          isClickable
              ? () async {
                final isXP = title.contains('XP');
                final meScreenState =
                    context.findAncestorStateOfType<_MeScreenState>();

                if (meScreenState == null) return;

                final data =
                    isXP
                        ? await meScreenState._getLast7DaysXP()
                        : await meScreenState._getLast7DaysMinutes();

                if (!context.mounted) return;

                final dateRange =
                    '(${DateTime.now().subtract(const Duration(days: 6)).month}/${DateTime.now().subtract(const Duration(days: 6)).day} - ${DateTime.now().month}/${DateTime.now().day})';

                if (!context.mounted) return;

                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder:
                      (_) => StatGraphSheet(
                        title: isXP ? 'XP' : 'Study time (min)',
                        dateRange: dateRange,
                        values: data.cast<double>(),
                      ),
                );
              }
              : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            if (isClickable)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _BadgeCategory extends StatelessWidget {
  final String title;
  final String lvl1Image;
  final String lvl2Image;
  final bool lvl1Earned;
  final bool lvl2Earned;
  final String lvl1Text;
  final String lvl2Text;

  const _BadgeCategory({
    required this.title,
    required this.lvl1Image,
    required this.lvl2Image,
    required this.lvl1Earned,
    required this.lvl2Earned,
    required this.lvl1Text,
    required this.lvl2Text,
  });

  @override
  Widget build(BuildContext context) {
    // Show highest earned level, or locked if none earned
    final bool showLvl2 = lvl2Earned;
    final bool isEarned = lvl1Earned || lvl2Earned;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (ctx) => _BadgeDetailDialog(
                title: title,
                lvl1Image: lvl1Image,
                lvl2Image: lvl2Image,
                lvl1Earned: lvl1Earned,
                lvl2Earned: lvl2Earned,
                lvl1Text: lvl1Text,
                lvl2Text: lvl2Text,
              ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              gradient:
                  isEarned
                      ? const LinearGradient(
                        colors: [Color(0xFF8A5BFF), Color(0xFFD76DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color: isEarned ? null : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  isEarned
                      ? [
                        BoxShadow(
                          color: const Color(
                            0xFF8A5BFF,
                          ).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child:
                      isEarned
                          ? Image.asset(
                            showLvl2 ? lvl2Image : lvl1Image,
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          )
                          : ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                            child: Image.asset(
                              lvl1Image,
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                          ),
                ),
                if (showLvl2)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Lv.2',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B3FFF),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BadgeDetailDialog extends StatelessWidget {
  final String title;
  final String lvl1Image;
  final String lvl2Image;
  final bool lvl1Earned;
  final bool lvl2Earned;
  final String lvl1Text;
  final String lvl2Text;

  const _BadgeDetailDialog({
    required this.title,
    required this.lvl1Image,
    required this.lvl2Image,
    required this.lvl1Earned,
    required this.lvl2Earned,
    required this.lvl1Text,
    required this.lvl2Text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Swipe to see all levels',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                children: [
                  _BadgeLevelDetail(
                    level: 1,
                    imagePath: lvl1Image,
                    earned: lvl1Earned,
                    progressText: lvl1Text,
                  ),
                  _BadgeLevelDetail(
                    level: 2,
                    imagePath: lvl2Image,
                    earned: lvl2Earned,
                    progressText: lvl2Text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeLevelDetail extends StatelessWidget {
  final int level;
  final String imagePath;
  final bool earned;
  final String progressText;

  const _BadgeLevelDetail({
    required this.level,
    required this.imagePath,
    required this.earned,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            gradient:
                earned
                    ? LinearGradient(
                      colors:
                          level == 1
                              ? [
                                const Color(0xFF9C6BFF),
                                const Color(0xFFD8B4FF),
                              ]
                              : [
                                const Color(0xFF7C4DFF),
                                const Color(0xFFB388FF),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: earned ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24),
            boxShadow:
                earned
                    ? [
                      BoxShadow(
                        color: (level == 1
                                ? const Color(0xFF9C6BFF)
                                : const Color(0xFF7C4DFF))
                            .withValues(alpha: 0.45),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                    : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child:
                    earned
                        ? Image.asset(
                          imagePath,
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        )
                        : ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Image.asset(
                            imagePath,
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.$level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          level == 1
                              ? const Color(0xFFFFA500)
                              : const Color(0xFFFF6B00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                earned
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: earned ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                earned ? '✓ Earned!' : 'Locked',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: earned ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progressText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
