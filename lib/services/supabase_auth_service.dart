import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // -------------------------
  // SIGN UP (email + username + password)
  // -------------------------
  Future<AuthResponse> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    // 1️⃣ Check if username already exists
    final existingUser =
        await _supabase
            .from('profiles')
            .select('id')
            .eq('username', username)
            .maybeSingle();

    if (existingUser != null) {
      throw AuthException('Username already taken');
    }

    // 2️⃣ Create user in Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Signup failed');
    }

    // 3️⃣ Insert profile row
    await _supabase.from('profiles').insert({
      'id': user.id,
      'email': email,
      'username': username,
      'created_at': DateTime.now().toIso8601String(),
    });

    return response;
  }

  // -------------------------
  // LOGIN (username + password)
  // -------------------------
  Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) async {
    // 1️⃣ Resolve username → email
    final userData =
        await _supabase
            .from('profiles')
            .select('email')
            .eq('username', username)
            .maybeSingle();

    if (userData == null || userData['email'] == null) {
      throw AuthException('Username not found');
    }

    final String email = userData['email'];

    // 2️⃣ Login using email
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw AuthException('Invalid password');
    }

    return response;
  }

  // -------------------------
  // SIGN OUT
  // -------------------------
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // -------------------------
  // CURRENT USER
  // -------------------------
  User? get currentUser => _supabase.auth.currentUser;
}
