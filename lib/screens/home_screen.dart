import 'package:flutter/material.dart';
import '../widgets/quick_button.dart';
import '../widgets/animated_progress.dart';

// Local file paths (fallback). These were uploaded earlier and exist on the runtime host.
// If you move images to assets/, prefer Image.asset('assets/..') and add to pubspec.yaml.
const String localImg1 = '/mnt/data/Screenshot 2025-11-21 092530.png';
const String localImg2 = '/mnt/data/Screenshot 2025-11-21 092552.png';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double learningProgress = 0.32;
  double dailyProgress = 0.7;

  late final AnimationController _fadeController;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: BottomNavigationBar is provided by main.dart RootTabs; screens shouldn't create another bottom nav.
      backgroundColor: const Color(0xFFFDF3EE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFF4D00),
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'MasterHanyu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Learn Chinese with Confidence',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeIn,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back, Student!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Continue your Chinese learning journey',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Learning Progress',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '32%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AnimatedProgressBar(
                            value: learningProgress,
                            height: 10,
                            activeColor: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Keep it up! You've learned 48 words this week.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(height: 80),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Access
              const Text(
                'Quick Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  QuickButton(
                    icon: Icons.menu_book,
                    label: 'Browse Lessons',
                    color: Colors.orange,
                    onTap: () => _navigateTo(context, 1),
                  ),
                  QuickButton(
                    icon: Icons.mic,
                    label: 'Practice Speaking',
                    color: Colors.blue,
                    onTap: () => _navigateTo(context, 2),
                  ),
                  QuickButton(
                    icon: Icons.quiz,
                    label: 'Take a Quiz',
                    color: Colors.purple,
                    onTap: () => _navigateTo(context, 3),
                  ),
                  QuickButton(
                    icon: Icons.show_chart,
                    label: 'View Progress',
                    color: Colors.green,
                    onTap: () => _navigateTo(context, 4),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Daily Goal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Learn 10 new words',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          '7/10',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedProgressBar(
                      value: dailyProgress,
                      height: 8,
                      activeColor: Colors.green,
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _navigateTo(context, 1),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Continue Learning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Community Section
              const Text(
                'Community',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _communitySection(),

              const SizedBox(height: 28),

              // Learning Tip
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Learning Tip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Practice pronunciation daily for just 5 minutes to improve your speaking skills faster!',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, int tabIndex) {
    // communicate with RootTabs by popping until RootTabs and changing index
    // Since RootTabs owns the BottomNav index, we use Navigator.popUntil to reach the top and then set the index via
    // a convenient method — but for simplicity, RootTabs will be the home; we can use a hack: pushReplacement with new RootTabs and index
    // Simpler approach: show an instruction for the user to press bottom nav. For now, we'll push the corresponding screen.
    // In the provided architecture BottomNav is persistent, so normally you'd change the index in RootTabs.
    // We'll navigate to the simple screen placeholders (they are also in the IndexedStack).
    // For better integration, you'd use a shared state (Provider, Riverpod).
    switch (tabIndex) {
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LessonsScreenShim()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SpeakingScreenShim()));
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const QuizScreenShim()));
        break;
      case 4:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProgressScreenShim()));
        break;
    }
  }

  Widget _communitySection() {
    final posts = [
      {
        'author': 'Lina',
        'text': 'Loved today\'s lesson on greetings! Any tips for tones?',
      },
      {
        'author': 'Sam',
        'text': 'Share your favorite Chinese songs for learners.',
      },
      {'author': 'Wei', 'text': 'Anyone up for a speaking partner this week?'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: posts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              if (idx == 0) return _communityCardCreate();
              final p = posts[idx - 1];
              return _communityCard(p['author']!, p['text']!);
            },
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {}, child: const Text('View All')),
        ),
      ],
    );
  }

  Widget _communityCardCreate() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.add_circle_outline, size: 28),
            SizedBox(height: 8),
            Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Share your progress or ask a question to the community.'),
          ],
        ),
      ),
    );
  }

  Widget _communityCard(String author, String text) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(author[0])),
              const SizedBox(width: 8),
              Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(text, maxLines: 4, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Simple shims used when a tab action from the Home quick buttons pushes a route.
/// In the real app the RootTabs' BottomNav should be changed — consider using a shared state manager.
class LessonsScreenShim extends StatelessWidget {
  const LessonsScreenShim({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lessons')),
    body: const Center(child: Text('Lessons (pushed from quick action)')),
  );
}

class SpeakingScreenShim extends StatelessWidget {
  const SpeakingScreenShim({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Speaking')),
    body: const Center(child: Text('Speaking (pushed from quick action)')),
  );
}

class QuizScreenShim extends StatelessWidget {
  const QuizScreenShim({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quiz')),
    body: const Center(child: Text('Quiz (pushed from quick action)')),
  );
}

class ProgressScreenShim extends StatelessWidget {
  const ProgressScreenShim({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Progress')),
    body: const Center(child: Text('Progress (pushed from quick action)')),
  );
}
