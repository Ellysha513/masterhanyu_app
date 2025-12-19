import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  static Future<UserProfile> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    final data =
        await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle(); // ✅ IMPORTANT FIX

    // 🟡 If profile row does not exist, create it
    if (data == null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'username': user.userMetadata?['username'] ?? '',
      });

      // fetch again
      final created =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();

      return UserProfile(
        id: user.id,
        username: created['username'],
        email: created['email'],
        name: created['name'] ?? '',
        age: created['age'] ?? 0,
        gender: created['gender'] ?? '',
        imagePath: created['avatar_url'],
      );
    }

    // 🟢 Normal path
    return UserProfile(
      id: user.id,
      username: data['username'],
      email: data['email'],
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      imagePath: data['avatar_url'],
    );
  }
}
