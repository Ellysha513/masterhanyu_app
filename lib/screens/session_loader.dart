import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import 'login_screen.dart';

class SessionLoader extends StatelessWidget {
  const SessionLoader({super.key});

  Future<bool> _restoreSession() async {
    await Supabase.instance.client.auth.onAuthStateChange.first;
    final session = Supabase.instance.client.auth.currentSession;
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
