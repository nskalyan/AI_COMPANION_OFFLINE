import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class StorageService {
  static const String _userIdKey = 'user_id';
  static const String messagesBoxName = 'messages_box';
  static const String notesBoxName = 'notes_box';
  static const String remindersBoxName = 'reminders_box';
  static const String profileBoxName = 'profile_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(messagesBoxName);
    await Hive.openBox(notesBoxName);
    await Hive.openBox(remindersBoxName);
    await Hive.openBox(profileBoxName);
  }

  static Future<void> cacheMessages(List<Message> list) async {
    final box = Hive.box(messagesBoxName);
    final data = list.map((m) => m.toJson()).toList();
    await box.put('messages', data);
  }

  static Future<int> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_userIdKey);

    if (userId == null) {
      // Generate a random user_id (offline-safe)
      userId = Random().nextInt(9999999) + 1;
      await prefs.setInt(_userIdKey, userId);
    }

    return userId;
  }

    static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }


  static List<Message> loadMessages() {
    final box = Hive.box(messagesBoxName);
    final data = (box.get('messages') as List?) ?? [];
    return data.map((e) => Message.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveProfile({required String name, required String timezone}) async {
    final box = Hive.box(profileBoxName);
    await box.put('name', name);
    await box.put('timezone', timezone);
  }

  static Map<String, String> loadProfile() {
    final box = Hive.box(profileBoxName);
    return {
      'name': (box.get('name') ?? 'me').toString(),
      'timezone': (box.get('timezone') ?? 'Asia/Kolkata').toString()
    };
  }

  static Future<void> saveThemeMode(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_theme', dark);
  }

  static Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_theme') ?? false;
  }
}
