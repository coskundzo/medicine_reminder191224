import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String dosage;
  final DateTime startDate;
  final TimeOfDay time;
  final int frequency; // Günlük kaç kez alınacak

  Medicine({
    required this.name,
    required this.dosage,
    required this.startDate,
    required this.time,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'startDate': startDate.toIso8601String(),
        'time': '${time.hour}:${time.minute}',
        'frequency': frequency,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return Medicine(
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

  // Veritabanı için Map dönüşümü
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'startDate': startDate.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'frequency': frequency,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return Medicine(
      name: map['name'],
      dosage: map['dosage'],
      startDate: DateTime.parse(map['startDate']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      frequency: map['frequency'],
    );
  }
}
