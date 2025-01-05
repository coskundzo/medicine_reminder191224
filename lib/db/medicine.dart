import 'package:flutter/material.dart';

class Medicine {
  int? id;
  String name;
  String dosage;
  DateTime startDate;
  TimeOfDay time;
  int frequency;
  bool isNotificationActive;
  List<int> notificationIds;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
    required this.time,
    required this.frequency,
    required this.isNotificationActive,
    required this.notificationIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'startDate': startDate.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'frequency': frequency,
      'isNotificationActive': isNotificationActive ? 1 : 0,
      'notificationIds': notificationIds.join(','),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    if (timeParts.length != 2) {
      throw FormatException('Geçersiz saat formatı: ${map['time']}');
    }

    return Medicine(
      id: map['id'] as int?,
      name: map['name'],
      dosage: map['dosage'],
      startDate: DateTime.parse(map['startDate']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      frequency: map['frequency'],
      isNotificationActive: map['isNotificationActive'] == 1,
      notificationIds: (map['notificationIds'] as String?)
              ?.split(',')
              .where((id) => id.isNotEmpty)
              .map((id) => int.tryParse(id) ?? 0)
              .toList() ??
          [],
    );
  }
}
