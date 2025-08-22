import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'storage_service.dart';

class ApiService {
  static int? userId;

  /// Common headers
  static Future<Map<String, String>> _headers() async {
    return {'Content-Type': 'application/json'};
  }

  static Future<void> createUser({
    required String externalId,
    required String name,
    required String timezone,
  }) async {
    final r = await http.post(
      Uri.parse('$apiBaseUrl/users'),
      headers: await _headers(),
      body: jsonEncode({
        'external_id': externalId,
        'name': name,
        'timezone': timezone,
      }),
    );
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body);
      userId = data['id'] as int;
    } else {
      throw Exception('Failed to create user: ${r.statusCode} ${r.body}');
    }
  }

  Future<String> sendMessage(String message) async {
    final userId = await StorageService.getOrCreateUserId();

    final response = await http.post(
      Uri.parse("$apiBaseUrl/chat"),
      headers: await _headers(),
      body: jsonEncode({
        "user_id": userId,
        "message": message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Chat failed: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(response.body)['reply'];
  }

  static Future<String> chat(String input) async {
    final r = await http.post(
      Uri.parse('$apiBaseUrl/chat'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'user_input': input,
      }),
    );
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body);
      return data['response'] as String;
    } else {
      throw Exception('Chat failed: ${r.statusCode} ${r.body}');
    }
  }

  static Future<List<dynamic>> getReminders() async {
    final r = await http.get(Uri.parse('$apiBaseUrl/reminders/$userId'));
    if (r.statusCode == 200) {
      return jsonDecode(r.body) as List<dynamic>;
    }
    throw Exception('Failed to load reminders: ${r.statusCode}');
  }

  static Future<Map<String, dynamic>> addReminder({
    required int userId,
    required String title,
    String? description,
    required DateTime dueAt,
    String type = 'task',
  }) async {
    final r = await http.post(
      Uri.parse('$apiBaseUrl/reminders'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'description': description,
        'due_at': dueAt.toIso8601String(),
        'type': type,
        'is_recurring': false
      }),
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to add reminder: ${r.statusCode} ${r.body}');
    }
  }

static Future<void> deleteReminder(int id) async {
  final res = await http.delete(
    Uri.parse('$apiBaseUrl/reminders/$id'),
    headers: {'Content-Type': 'application/json'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to delete reminder: ${res.statusCode} ${res.body}');
  }
}

  static Future<List<dynamic>> getNotes() async {
    final r = await http.get(Uri.parse('$apiBaseUrl/notes/$userId'));
    if (r.statusCode == 200) {
      return jsonDecode(r.body) as List<dynamic>;
    }
    throw Exception('Failed to load notes: ${r.statusCode}');
  }

  static Future<void> addNote({
    required String title,
    required String content,
  }) async {
    final r = await http.post(
      Uri.parse('$apiBaseUrl/notes'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'content': content,
      }),
    );
    if (r.statusCode != 200) {
      throw Exception('Failed to create note: ${r.statusCode} ${r.body}');
    }
  }

static Future<void> deleteNote(int id) async {
  final res = await http.delete(
    Uri.parse('$apiBaseUrl/notes/$id'),
    headers: {'Content-Type': 'application/json'},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to delete note: ${res.statusCode} ${res.body}');
  }
}

  static Future<List<dynamic>> getNotifications() async {
    final r = await http.get(Uri.parse('$apiBaseUrl/notifications/$userId'));
    if (r.statusCode == 200) {
      return jsonDecode(r.body) as List<dynamic>;
    }
    throw Exception('Failed to load notifications: ${r.statusCode}');
  }

  static Future<void> ackNotification(int id) async {
    final r = await http.patch(Uri.parse('$apiBaseUrl/notifications/$id/ack'));
    if (r.statusCode != 200) {
      throw Exception('Failed to ack notification: ${r.statusCode}');
    }
  }
}
