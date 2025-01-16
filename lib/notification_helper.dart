import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_reminder191224/main.dart';
import 'package:medicine_reminder191224/medicine_list_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../screens/floating_screen.dart' as floating_screen;
import 'package:flutter/material.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Bildirim ayarlarını başlat
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Bildirim zamanlama fonksiyonu
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_channel', // Kanal ID'si
        'Medicine Notifications', // Kanal adı
        channelDescription: 'İlaç hatırlatıcı bildirimleri için kanal',
        importance: Importance.max,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('ertele', 'Ertele'),
          AndroidNotificationAction('al', 'Al'),
          AndroidNotificationAction('iptal', 'İptal Et'),
        ],
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 18 sürümle gelen parametre
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Bildirim iptali
  static Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }
}

void showNotification(int id, String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', // Kanal ID'si
    'channel_name', // Kanal Adı
    channelDescription: 'Kanal açıklaması',
    importance: Importance.max,
    priority: Priority.high,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('ertele', 'Ertele'),
      AndroidNotificationAction('al', 'Al'),
      AndroidNotificationAction('iptal', 'İptal Et'),
    ],
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformDetails,
    payload: 'notification_payload', // Aksiyon verisi
  );
}
