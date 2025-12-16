import 'package:flutter/material.dart';
import '../widgets/animated_progress.dart';
import 'lessons_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),

              const SizedBox(height: 16),
              _welcomeCard(),

              const SizedBox(height: 20),
              _activeCourse(),

              const SizedBox(height: 24),
              _quickAccess(context),

              const SizedBox(height: 24),
              _dailyGoal(context),

              const SizedBox(height: 24),
              _learningTip(),

              const SizedBox(height: 40),
            ],
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
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B7CFF), Color(0xFFB59CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        children: [
          Text(
            "MasterHanyu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Learn Chinese with confidence",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
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
          const Text(
            "Welcome back, Student!",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ready to continue your Chinese learning journey?",
            style: TextStyle(color: Colors.grey),
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
                _InfoRow("Words Learned", "48 words", Colors.orange),
                SizedBox(height: 10),
                Text(
                  "32% to next level",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 6),
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
  // ACTIVE COURSE
  // ------------------------------------------------------------
  Widget _activeCourse() {
    return _card(
      title: "Active Courses",
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book, color: Colors.deepPurple),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Basic Greetings",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text("6 / 12 lessons", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 6),
                AnimatedProgressBar(
                  value: 0.5,
                  height: 6,
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          const Text(
            "50%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK ACCESS (NO OVERFLOW ✅)
  // ------------------------------------------------------------
  Widget _quickAccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Access",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickTile(
                icon: Icons.menu_book,
                label: "Browse Lessons",
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LessonsScreen()),
                  );
                },
              ),
              _QuickTile(
                icon: Icons.emoji_events,
                label: "Take a Quiz",
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PracticeScreen()),
                  );
                },
              ),
              _QuickTile(
                icon: Icons.trending_up,
                label: "View Progress",
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DAILY GOAL
  // ------------------------------------------------------------
  Widget _dailyGoal(BuildContext context) {
    return _card(
      title: "Daily Goal",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Learn 10 new words"),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "7 / 10",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 6),
          const AnimatedProgressBar(
            value: 0.7,
            height: 8,
            activeColor: Colors.blue,
          ),
          const SizedBox(height: 14),
          _AnimatedButton(
            label: "Continue Learning",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LessonsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LEARNING TIP
  // ------------------------------------------------------------
  Widget _learningTip() {
    return _card(
      gradient: const LinearGradient(
        colors: [Color(0xFFEDE7FF), Color(0xFFF7F4FF)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Learning Tip",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Practice pronunciation daily for just 5 minutes to improve your speaking skills faster!",
          ),
        ],
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

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
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
