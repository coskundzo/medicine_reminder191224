import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db/medicine.dart'; // Medicine modelini import ettiniz
import 'database_helper.dart'; // Veritabanı işlemleri için
import 'notification_helper.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

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
    // Düzenleme ekranına yönlendirme veya işlem
    print("İlaç düzenle: ${medicine.name}");
  }

  void _toggleNotification(Medicine medicine) async {
    await NotificationHelper.cancelNotification(medicine.id);
    // Bildirim durumunu değiştirme (örneğin, veritabanında güncelleme)
    print("Bildirim kapat: ${medicine.name}");
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
                        icon:
                            Icon(Icons.notifications_off, color: Colors.orange),
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
                                medicine.id); // Veritabanından sil
                            setState(() {
                              medicines.remove(medicine); // Listeyi güncelle
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${medicine.name} başarıyla silindi.')),
                            );
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
