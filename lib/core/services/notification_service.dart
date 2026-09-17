import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );
    }

    _isInitialized = true;
  }

  Future<void> scheduleTaskAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return; // Ignore past dates
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'smartflow_tasks_channel',
        'SmartFlow Task Reminders',
        channelDescription: 'Pengingat jadwal dan pembayaran SmartFlow',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  Future<void> cancelAlarm(int id) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Cancel alarm error: $e');
    }
  }
}
