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
    // Check if username exists
    final existingUser = await _supabase
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (existingUser != null) {
      throw AuthException('Username already taken');
    }

    // Create user in Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );

    if (response.user == null) {
      throw AuthException("Signup failed");
    }

    // Insert into profiles table
    await _supabase.from('profiles').insert({
      'id': response.user!.id,
      'email': email,
      'username': username,
    });

    return response;
  }

  // -------------------------
  // LOGIN (using username, not email)
  // -------------------------
  Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) async {
    // First, find email from username
    final userData = await _supabase
        .from('profiles')
        .select('email')
        .eq('username', username)
        .maybeSingle();

    if (userData == null) {
      throw AuthException("Username not found");
    }

    final email = userData['email'];

    // Now sign in using the email
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // -------------------------
  // SIGN OUT
  // -------------------------
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // -------------------------
  // GET CURRENT USER
  // -------------------------
  User? get currentUser => _supabase.auth.currentUser;
}
