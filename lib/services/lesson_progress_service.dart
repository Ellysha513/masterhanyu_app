import 'package:supabase_flutter/supabase_flutter.dart';

class LessonProgressService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> loadProgress({
    required String userId,
    required String lessonId,
  }) async {
    return await _client
        .from('lesson_progress')
        .select()
        .eq('user_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle();
  }

  Future<void> saveProgress({
    required String userId,
    required String lessonId,
    required int currentIndex,
    required int total,
  }) async {
    await _client.from('lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'current_index': currentIndex,
      'total': total,
      'progress': (currentIndex + 1) / total,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
