import 'package:flutter/material.dart';

class Medicine {
  final int? id; // Nullable id
  final String name;
  final String? dosage;
  final DateTime startDate;
  final TimeOfDay time;
  final int frequency; // Günlük kaç kez alınacak
  final List<int>? notificationIds; // Nullable
  final bool isNotificationActive; // Varsayılan olarak aktif

  Medicine({
    this.id, // Nullable
    required this.name,
    this.dosage,
    required this.startDate,
    required this.time,
    required this.frequency,
    this.notificationIds,
    this.isNotificationActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'startDate': startDate.toIso8601String(),
        'time': '${time.hour}:${time.minute}',
        'frequency': frequency,
        'isNotificationActive': isNotificationActive ? 1 : 0,
        'notificationIds': notificationIds?.join(','),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    try {
      final timeParts = (json['time'] as String).split(':');
      return Medicine(
        id: json['id'] as int?,
        name: json['name'],
        dosage: json['dosage'],
        startDate: DateTime.parse(json['startDate']),
        time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
        frequency: json['frequency'],
        isNotificationActive: json['isNotificationActive'] == 1,
        notificationIds: (json['notificationIds'] as String?)
            ?.split(',')
            .where((id) => id.isNotEmpty)
            .map((id) => int.parse(id))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Medicine verileri hatalı: $e');
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'startDate': startDate.toIso8601String(),
        'time': '${time.hour}:${time.minute}',
        'frequency': frequency,
        'isNotificationActive': isNotificationActive ? 1 : 0,
        'notificationIds': notificationIds?.join(','),
      };

  factory Medicine.fromMap(Map<String, dynamic> map) {
    try {
      final timeParts = map['time'].split(':');
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
            .map((id) => int.parse(id))
            .toList(),
      );
    } catch (e) {
      throw FormatException('Medicine verileri hatalı: $e');
    }
  }
}
