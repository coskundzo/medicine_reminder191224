import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'medicine_list_screen.dart';
import 'add_medicine_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../screens/floating_screen.dart' as floating_screen;

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

    await _notificationsPlugin.initialize(initializationSettings);
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
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    await Firebase.initializeApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addMedicine');
              },
              child: Text('İlaç Ekle'),
            ),
            SizedBox(height: 20), // Butonlar arasında boşluk
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medicines');
              },
              child: Text('İlaç Listesine Git'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/_medicines');
              },
              child: Text('İlaç Listesine Git/detay'),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return floating_screen.FloatingPage();
                  },
                );
              },
              child: Text('bildirim sayfası'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlaç Hatırlatma',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => HomeScreen(),
        '/addMedicine': (context) => AddMedicineScreen(),
        '/medicines': (context) => MedicineListScreen(),
        '/_medicines': (context) => MedicineListScreen(),
        '/floating_screen': (context) =>
            floating_screen.FloatingPage(), // Yeni rota tanımlama
      },
    );
  }
}
