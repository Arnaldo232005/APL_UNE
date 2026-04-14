import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evaluation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth Operations
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // Course Operations
  Future<List<Map<String, dynamic>>> getCoursesWithStats() async {
    try {
      final response = await _client
          .from('courses')
          .select('*, evaluations(weight, score, difficulty)')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en getCoursesWithStats: $e');
      rethrow;
    }
  }

  Future<void> addCourse(String name, String importance, String colorHex, int iconCode) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No hay sesión activa');
    
    try {
      await _client.from('courses').insert({
        'name': name,
        'importance': importance,
        'user_id': user.id,
        'color_hex': colorHex,
        'icon_code': iconCode,
      });
    } catch (e) {
      debugPrint('Error en addCourse: $e');
      rethrow;
    }
  }

  // Evaluation Operations
  Future<List<Evaluation>> getEvaluations(String courseId) async {
    try {
      final response = await _client
          .from('evaluations')
          .select()
          .eq('course_id', courseId)
          .order('evaluation_date', ascending: true);
      
      return (response as List).map((data) => Evaluation.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error en getEvaluations: $e');
      return [];
    }
  }

  Future<void> addEvaluation(String courseId, String title, String? description, DateTime date, double weight, int difficulty) async {
    try {
      await _client.from('evaluations').insert({
        'course_id': courseId,
        'title': title,
        'description': description,
        'evaluation_date': date.toIso8601String(),
        'weight': weight,
        'difficulty': difficulty,
      });
    } catch (e) {
      debugPrint('Error en addEvaluation: $e');
      rethrow;
    }
  }

  Future<void> updateEvaluationScore(String evaluationId, double score) async {
    try {
      await _client.from('evaluations').update({
        'score': score,
      }).eq('id', evaluationId);
    } catch (e) {
      debugPrint('Error en updateEvaluationScore: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _client.from('courses').delete().eq('id', courseId);
    } catch (e) {
      debugPrint('Error en deleteCourse: $e');
      rethrow;
    }
  }

  Future<void> deleteEvaluation(String evaluationId) async {
    try {
      await _client.from('evaluations').delete().eq('id', evaluationId);
    } catch (e) {
      debugPrint('Error en deleteEvaluation: $e');
      rethrow;
    }
  }

  /// Returns all evaluations joined with their course name and color for the global calendar
  Future<List<Map<String, dynamic>>> getAllEvaluationsWithCourse() async {
    try {
      final response = await _client
          .from('evaluations')
          .select('*, courses(name, color_hex, icon_code)')
          .order('evaluation_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error en getAllEvaluationsWithCourse: $e');
      rethrow;
    }
  }

  /// Updates title, description, weight and difficulty of an evaluation
  Future<void> updateEvaluation(String evaluationId, {
    required String title,
    required String? description,
    required double weight,
    required int difficulty,
  }) async {
    try {
      await _client.from('evaluations').update({
        'title': title,
        'description': description,
        'weight': weight,
        'difficulty': difficulty,
      }).eq('id', evaluationId);
    } catch (e) {
      debugPrint('Error en updateEvaluation: $e');
      rethrow;
    }
  }
}
