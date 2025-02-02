import 'package:flutter/material.dart';
import 'package:medicine_reminder191224/screens/floating_screen.dart';
import 'db/medicine.dart';
import 'database_helper.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'show_custom_sanckbar.dart';
import 'main.dart';

class AddMedicineScreen extends StatefulWidget {
  //---------------------------------
  final Medicine? medicine; // Düzenleme için opsiyonel parametre

  AddMedicineScreen({this.medicine});
  //---------------------------------
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _time;
  int _frequency = 1;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Bildirim Aksiyonu Alındı: ${response.actionId}');
        if (response.actionId != null) {
          if (response.actionId == 'snooze') {
            print('Erteleme aksiyonu çalıştırılıyor.');
            showGeneralDialog(
              context: navigatorKey.currentState!.context,
              barrierDismissible: true,
              barrierLabel: "Dialog",
              pageBuilder: (_, __, ___) {
                return Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 300,
                      height: 200,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: FloatingPage(),
                    ),
                  ),
                );
              },
            );
          } else if (response.actionId == 'take') {
            print('Al aksiyonu çalıştırılıyor.');
            ScaffoldMessenger.of(navigatorKey.currentState!.context)
                .showSnackBar(
              SnackBar(
                content: Text('İlacınız alındı!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (response.actionId == 'cancel') {
            print('İptal aksiyonu çalıştırılıyor.');
            ScaffoldMessenger.of(navigatorKey.currentState!.context)
                .showSnackBar(
              SnackBar(
                content: Text('Bildirim iptal edildi'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('response.actionId null.');
        }
      },
    );

    // Form alanlarını düzenleme modunda doldur
    _nameController = TextEditingController(
      text: widget.medicine?.name ?? '',
    );
    _dosageController = TextEditingController(
      text: widget.medicine?.dosage ?? '',
    );
    _startDate = widget.medicine?.startDate;
    _time = widget.medicine?.time;
    _frequency = widget.medicine?.frequency ?? 1;
  }

  Future<void> scheduleNotification(
      String title, String body, DateTime scheduledTime) async {
    const androidDetails = AndroidNotificationDetails(
      'med_reminder_channel_id',
      'Med Reminders',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'snooze',
          'Erteleee',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'take',
          'Al',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'cancel',
          'İptal Et',
          showsUserInterface: true,
        ),
      ],
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
    if (_time == null || _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başlangıç tarihi ve zamanı seçilmelidir.')),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'İlaç Ekle' : 'İlaç Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'İlaç Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dozaj'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  }
                },
                child: Text(_startDate == null
                    ? 'Başlangıç Tarihini Seç'
                    : 'Başlangıç Tarihi: ${_startDate!.toLocal()}'
                        .split(' ')[0]),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _time = pickedTime;
                    });
                  }
                },
                child: Text(_time == null
                    ? 'Zamanı Seç'
                    : 'Zaman: ${_time!.format(context)}'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.remove, size: 30),
                    onPressed: () {
                      if (_frequency > 1) {
                        setState(() {
                          _frequency--;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Günlük Alım Sayısı',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_frequency',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.add, size: 30),
                    onPressed: () {
                      setState(() {
                        _frequency++;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Lütfen başlangıç tarihi seçin.')),
                      );
                      return;
                    }
                    final isExists = await DatabaseHelper.instance
                        .isMedicineNameExists(_nameController.text);
                    print('Is Exists: $isExists');

                    if (isExists && widget.medicine == null) {
                      // Yeni ilaç ekliyorsanız ve isim zaten varsa kaydetme
                      showCustomSnackBar(context,
                          'Bu isimde bir ilaç zaten kayıtlı!', Colors.red);
                      return;
                    } else if (isExists &&
                        widget.medicine != null &&
                        widget.medicine!.name != _nameController.text) {
                      // Güncelleme yaparken isim farklı bir ilaçla çakışıyorsa
                      showCustomSnackBar(context,
                          'Bu isimde bir ilaç zaten kayıtlı!', Colors.red);
                      return;
                    }

                    final medicine = Medicine(
                      id: widget.medicine?.id,
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      startDate: _startDate!,
                      time: _time!,
                      frequency: _frequency,
                      isNotificationActive: true, // Yeni alan
                      notificationIds: [],
                    );
                    if (widget.medicine == null) {
                      // Yeni ilaç ekleme
                      int id = await DatabaseHelper.instance
                          .insertMedicine(medicine);
                      print('inserted medicine id: $id');
                      print('Medicine Name: ${_nameController.text}');
                    } else {
                      // Mevcut ilacı güncelleme
                      print(
                          'Updating medicine with id: ${widget.medicine?.id}');
                      print('Updated Medicine Name: ${_nameController.text}');
                      await DatabaseHelper.instance.updateMedicine(medicine);
                      print('Medicine updated');
                    }

                    final String title = _nameController.text;
                    final String body = 'İlacınızı almayı unutmayın.';

                    await scheduleRepeatingNotifications(
                      title,
                      body,
                      _startDate!,
                      _time!,
                      _frequency,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(widget.medicine == null
                              ? 'İlaç kaydedildi ve bildirimler ayarlandı!'
                              : 'İlaç güncellendi ve bildirimler yeniden ayarlandı!')),
                    );
                    Navigator.of(context).pop();

                    //Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/medicines');
                  }
                },
                child: Text('Kaydet'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/medicines');
                },
                child: Text('İlaç Listesine Git'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
