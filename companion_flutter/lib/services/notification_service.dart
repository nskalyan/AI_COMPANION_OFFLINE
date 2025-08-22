import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../config.dart';
import 'api_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Timer? _pollTimer;
  static final Set<int> _shown = {}; // avoid duplicates per session

  /// Initialize plugin & timezone
  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(initSettings);
  }

  /// Show an immediate notification
  static Future<void> showNow(String title, String body) async {
    const android = AndroidNotificationDetails(
      'companion_ch',
      'Companion',
      channelDescription: 'Companion reminders & alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  /// Schedule a local reminder (safe even offline)
  static Future<void> schedule(
    String title,
    String body,
    DateTime scheduledTime, {
    int? id,
  }) async {
    final notifId = id ?? scheduledTime.millisecondsSinceEpoch % 100000;

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Local reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Poll backend-driven notifications (still supported)
  static void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(notificationPollInterval, (timer) async {
      try {
        final items = await ApiService.getNotifications();
        for (final n in items) {
          final id = n['id'] as int;
          final sentAt = n['sent_at'];
          if (sentAt == null && !_shown.contains(id)) {
            _shown.add(id);
            await showNow('Reminder', n['content'] as String);
            try {
              await ApiService.ackNotification(id);
            } catch (_) {}
          }
        }
      } catch (_) {
        // fail silently, will retry next tick
      }
    });
  }

  static void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

    /// Cancel a scheduled notification by ID
  static Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      // optional: log or show toast
    }
  }

  /// Cancel all scheduled notifications (helper if needed)
  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      // optional: log or show toast
    }
  }


  
}
