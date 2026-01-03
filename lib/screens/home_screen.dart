import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/animated_progress.dart';

class HomeScreen extends StatelessWidget {
  final UserProfile user;
  final Function(int) onQuickAccessTap;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onQuickAccessTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 16),

              _welcomeCard(),
              const SizedBox(height: 20),

              _todayFocus(context),
              const SizedBox(height: 20),

              _activeCourse(),
              const SizedBox(height: 24),

              _learningTip(),
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
            "Hello, ${user.name.isNotEmpty ? user.name : user.username}!",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ready to continue your Chinese learning journey?",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
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
  // TODAY'S FOCUS ⭐ (NEW)
  // ------------------------------------------------------------
  Widget _todayFocus(BuildContext context) {
    return _card(
      title: "Today's Focus",
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.deepPurple.shade100,
            child: const Icon(
              Icons.record_voice_over,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Introduction",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Practice pronunciation & tones",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.deepPurple),
            onPressed: () {
              onQuickAccessTap(1); // Learn tab
            },
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
        children: const [
          Text(
            "Introduction to Chinese",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("6 / 12 lessons", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          AnimatedProgressBar(
            value: 0.5,
            height: 6,
            activeColor: Color.fromARGB(255, 248, 151, 240),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Practice pronunciation daily for just 5 minutes to improve your speaking skills!",
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
