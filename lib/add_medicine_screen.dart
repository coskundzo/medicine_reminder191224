import 'package:flutter/material.dart';
import 'db/medicine.dart';
import 'database_helper.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
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
      print('Notification scheduled with title: $_nameController.text');
      await scheduleNotification(title, body, scheduledTime);
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
                    if (_time == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lütfen zamanı seçin.')),
                      );
                      return;
                    }

                    final medicine = Medicine(
                      id: widget.medicine?.id ?? 0,
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      startDate: _startDate!,
                      time: _time!,
                      frequency: _frequency,
                    );
                    if (widget.medicine == null) {
                      // Yeni ilaç ekleme
                      await DatabaseHelper.instance.insertMedicine(medicine);
                    } else {
                      // Mevcut ilacı güncelleme
                      await DatabaseHelper.instance.updateMedicine(medicine);

                      setState(() {});
                    }

                    await scheduleRepeatingNotifications(
                      _nameController.text,
                      'İlacınızı almayı unutmayın.',
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

                    Navigator.pop(context);
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
