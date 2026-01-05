import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user_profile.dart';
import '../theme/app_background.dart';
import '../widgets/stat_graph_sheet.dart';
import 'account_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeScreen extends StatefulWidget {
  final UserProfile user;

  const MeScreen({super.key, required this.user});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> with WidgetsBindingObserver {
  int totalXP = 0;
  int todayXP = 0;
  int totalMinutes = 0;
  int todayMinutes = 0;
  UserProfile get user => widget.user;

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
    _loadStats();
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
          _loadStats(); // Refresh stats after returning
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
      radius: 26,
      backgroundColor: Colors.deepPurple,
      child: CircleAvatar(
        radius: 24,
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
              Text(
                "VIEW ALL",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
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
              ? () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder:
                      (_) => StatGraphSheet(
                        title:
                            subtitle == "Today's XP"
                                ? "XP"
                                : "Study time (min)",
                        dateRange: "(12/12/2025 - 18/12/2025)",
                        values: const [0, 0, 0, 0, 0, 0, 0],
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
