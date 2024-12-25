import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_reminder191224/database_helper.dart';
import 'package:medicine_reminder191224/db/medicine.dart';
import 'add_medicine_screen.dart';
import 'medicine_list_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() {
  tz.initializeTimeZones(); // Zaman bölgelerini başlatır
  tz.setLocalLocation(
      tz.getLocation('Europe/Istanbul')); // Yerel zaman bölgesini ayarlar

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// eklendi
Future<void> scheduleNotification(
    String title, String body, DateTime time) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    tz.TZDateTime.from(time, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id', // Kanal ID
        'your_channel_name', // Kanal adı
        importance: Importance.max,
        priority: Priority.high,
        playSound: true, // Oynatılacak ses
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    ),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.exact, // Zaman bileşenleri
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asenkron işlemler için gerekli
  initializeNotifications(); // Bildirimleri başlat
  runApp(MyApp());
}

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
      routes: {
        '/': (context) => HomeScreen(),
        '/addMedicine': (context) => AddMedicineScreen(),
        '/medicines': (context) => MedicineListScreen(), // Yeni rota tanımlama
      },
    );
  }
}

class MedicineListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine List'),
      ),
      body: FutureBuilder<List<Medicine>>(
        future: DatabaseHelper.instance.getMedicines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final medicines = snapshot.data!;
            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return ListTile(
                  title: Text(medicine.name),
                  subtitle: Text(medicine.dosage),
                  onTap: () {
                    // Medicien detayına gitmek için gerekli işlemler
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No medicines found.'));
          }
        },
      ),
    );
  }
}
