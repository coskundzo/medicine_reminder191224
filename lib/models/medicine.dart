import 'package:flutter/material.dart';

class Medicine {
  final int?
      id; // id, opsiyonel çünkü yeni bir kayıt oluşturulurken id veritabanı tarafından atanabilir.
  final String name;
  final String dosage;
  final DateTime startDate;
  final TimeOfDay time;
  final int frequency; // Günlük kaç kez alınacak

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
    required this.time,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
        'id': id, // id'yi de JSON'a dahil edin
        'name': name,
        'dosage': dosage,
        'startDate': startDate.toIso8601String(),
        'time': '${time.hour}:${time.minute}',
        'frequency': frequency,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return Medicine(
      id: json['id'], // id'yi parse edin
      name: json['name'],
      dosage: json['dosage'],
      startDate: DateTime.parse(json['startDate']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      frequency: json['frequency'],
    );
  }
}
