import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicine_reminder191224/show_custom_sanckbar.dart';
import 'db/medicine.dart'; // Medicine modelini import ettiniz
import 'database_helper.dart'; // Veritabanı işlemleri için
import 'notification_helper.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'add_medicine_screen.dart';

final _formKey = GlobalKey<FormState>();
TextEditingController _nameController = TextEditingController();
TextEditingController _dosageController = TextEditingController();
DateTime? _startDate;
TimeOfDay? _time;
int _frequency = 1;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification(
    String title, String body, DateTime scheduledTime) async {
  const androidDetails = AndroidNotificationDetails(
    'med_reminder_channel_id',
    'Med Reminders',
    channelDescription: 'Channel for medication reminders',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  const platformDetails = NotificationDetails(android: androidDetails);

  final tzScheduledTime =
      tz.TZDateTime.from(scheduledTime, tz.getLocation('Europe/Istanbul'));
  final notificationId =
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId,
    title,
    body,
    tzScheduledTime,
    platformDetails,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.exact,
  );
}

Future<void> scheduleRepeatingNotifications(String title, String body,
    DateTime startDate, TimeOfDay time, int frequency) async {
  for (int i = 0; i < frequency; i++) {
    final scheduledTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      time.hour,
      time.minute,
    ).add(Duration(hours: i * 24 ~/ frequency));
    print('Notification scheduled with title: ${_nameController.text}');
    await scheduleNotification(title, body, scheduledTime);
  }
}

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
}

class MedicineListScreen extends StatefulWidget {
  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    _medicines = DatabaseHelper.instance.getMedicines();
  }

  Future<void> _deleteMedicine(int id) async {
    await DatabaseHelper.instance.deleteMedicine(id);
    _loadMedicines();
    setState(() {});
  }

  void _editMedicine(Medicine medicine) {
    //_loadMedicines();
    //setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(medicine: medicine),
      ),
    );
    // Düzenleme ekranına yönlendirme veya işlem

    print("İlaç düzenle: ${medicine.name}");
  }

  Future<void> _toggleNotification(Medicine medicine) async {
    if (medicine.isNotificationActive) {
      // Bildirimleri iptal et
      for (int notificationId in medicine.notificationIds) {
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        print('bildirimler iptal edildi');
      }
      medicine.notificationIds.clear(); // Bildirim ID'lerini temizle

      setState(() {
        medicine.isNotificationActive = false;
      });

      // Kullanıcıya bildirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medicine.name} bildirimleri kapatıldı.')),
      );
    } else {
      // Bildirimleri yeniden zamanla
      final notificationIds = <int>[];
      for (int i = 0; i < medicine.frequency; i++) {
        final scheduledTime = DateTime(
          medicine.startDate.year,
          medicine.startDate.month,
          medicine.startDate.day,
          medicine.time.hour,
          medicine.time.minute,
        ).add(Duration(hours: i * 24 ~/ medicine.frequency));

        final notificationId =
            DateTime.now().millisecondsSinceEpoch.remainder(100000);
        await scheduleNotification(
          medicine.name,
          'İlacınızı almayı unutmayın.',
          scheduledTime,
        );
        notificationIds.add(notificationId);
      }

      medicine.notificationIds = notificationIds;

      setState(() {
        medicine.isNotificationActive = true;
      });

      // Kullanıcıya bildirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${medicine.name} bildirimleri etkinleştirildi.')),
      );
    }

    // Güncel durumu veritabanına kaydet
    await DatabaseHelper.instance.updateMedicine(medicine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kayıtlı İlaçlar')),
      body: FutureBuilder<List<Medicine>>(
        future: _medicines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Hiç ilaç kaydedilmedi.'));
          } else {
            final medicines = snapshot.data!;
            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return ListTile(
                  title: Text(medicine.name),
                  subtitle: Text(
                      'Dozaj: ${medicine.dosage}, Günde ${medicine.frequency} defa,: ${medicine.time.format(context)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editMedicine(medicine),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_off,
                          color: medicine.isNotificationActive
                              ? const Color.fromARGB(255, 161, 246, 50)
                              : const Color.fromARGB(255, 241, 86, 43),
                        ),
                        onPressed: () => _toggleNotification(medicine),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Silme Onayı'),
                                content: Text(
                                    '${medicine.name} isimli ilacı silmek istediğinizden emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false), // İptal
                                    child: Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true), // Onay
                                    child: Text('Sil'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Kullanıcı "Sil" butonuna tıkladıysa işlemi başlat
                          if (confirm == true) {
                            await DatabaseHelper.instance.deleteMedicine(
                                medicine.id!); // Veritabanından sil
                            setState(() {
                              medicines.remove(medicine); // Listeyi güncelle
                            });
                            showCustomSnackBar(
                                context,
                                '${medicine.name} başarıyla silindi.',
                                Colors.green);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
