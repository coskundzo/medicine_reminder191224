import 'package:flutter/material.dart';
import 'db/medicine.dart';
import 'database_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _time;
  int _frequency = 1; // Varsayılan günlük alınma sayısı

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Zaman dilimini başlat
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

    var androidScheduleMode = null;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledTime,
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: androidScheduleMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İlaç Ekle')),
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
                    iconSize: 30, // İkonun boyutunu artırdık
                    icon: Icon(Icons.remove,
                        size: 30), // İkonun boyutunu artırdık
                    onPressed: () {
                      if (_frequency > 1) {
                        setState(() {
                          _frequency--;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 8), // Araya boşluk ekledik
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Günlük Alım Sayısı', // Başlık yazısını ekledik
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_frequency', // Sayı yazısı
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold), // Sayının stilini ayarladık
                      ),
                    ],
                  ),
                  SizedBox(width: 8), // Araya boşluk ekledik
                  IconButton(
                    iconSize: 30, // İkonun boyutunu artırdık
                    icon: Icon(Icons.add, size: 30), // İkonun boyutunu artırdık
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
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      startDate: _startDate!,
                      time: _time!,
                      frequency: _frequency,
                    );

                    await DatabaseHelper.instance.insertMedicine(medicine);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('İlaç kaydedildi!')),
                    );

                    Navigator.pop(context);
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
