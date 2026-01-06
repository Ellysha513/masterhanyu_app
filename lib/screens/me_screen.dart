import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user_profile.dart';
import '../theme/app_background.dart';
import '../widgets/stat_graph_sheet.dart';
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

  Future<void> _loadStats() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final id = user.id;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats whenever the widget's dependencies change
    // This helps when switching between tabs
    // Use addPostFrameCallback to ensure timing is correct after screen transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStats();
    }
  }

  void refreshStatsNow() {
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
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
                  title: "$totalMinutes min",
                  subtitle: "Total time",
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: "$todayMinutes min",
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
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Badges",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              BadgeItem(label: "XP Hunter"),
              SizedBox(width: 12),
              BadgeItem(label: "Native Speaker"),
              SizedBox(width: 12),
              BadgeItem(label: "Marathon Pro"),
            ],
          ),
        ],
      ),
    );
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

class BadgeItem extends StatelessWidget {
  final String label;

  const BadgeItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
