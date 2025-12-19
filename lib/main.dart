import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_profile.dart';
import 'services/profile_service.dart';
import 'screens/login_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/me_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rfvavvmdthkmixkwfosa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmdmF2dm1kdGhrbWl4a3dmb3NhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyMDUyNTUsImV4cCI6MjA4MDc4MTI1NX0.3jTiFio_b9BcwbpNG4kySW85z8KJIwR1iSJjAw1EoZ8',
  );

  final prefs = await SharedPreferences.getInstance();
  final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

  runApp(MyApp(hasSeenIntro: hasSeenIntro));
}

// ------------------------------------------------------------
// APP ROOT
// ------------------------------------------------------------
class MyApp extends StatelessWidget {
  final bool hasSeenIntro;

  const MyApp({super.key, required this.hasSeenIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !hasSeenIntro ? const SessionLoader() : const IntroScreen(),
    );
  }
}

/// ------------------------------------------------------------
/// 🔐 WAIT FOR SESSION RESTORE (THIS FIXES EVERYTHING)
/// ------------------------------------------------------------
class SessionLoader extends StatelessWidget {
  const SessionLoader({super.key});

  Future<bool> _restoreSession() async {
    // ⏳ Wait for Supabase to finish restoring session
    await Supabase.instance.client.auth.onAuthStateChange.first;

    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('RESTORED SESSION = $session');

    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restoreSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const RootApp();
        }

        return const LoginScreen();
      },
    );
  }
}

// ------------------------------------------------------------
// LOAD PROFILE → ROOT TABS
// ------------------------------------------------------------
class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: ProfileService.fetchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'ERROR: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Profile not found')));
        }

        return RootTabs(user: snapshot.data!);
      },
    );
  }
}

// ------------------------------------------------------------
// ROOT TABS (BOTTOM NAV)
// ------------------------------------------------------------
class RootTabs extends StatefulWidget {
  final UserProfile user;

  const RootTabs({super.key, required this.user});

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeScreen(user: widget.user, onQuickAccessTap: _switchTab),
      const LearnScreen(),
      const PracticeScreen(),
      MeScreen(user: widget.user),
    ];
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 56, 54, 180),
        unselectedItemColor: Colors.grey[600],
        onTap: _switchTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Learn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Practice'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
