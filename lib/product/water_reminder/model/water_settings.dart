import 'package:flutter/material.dart';

class WaterSettings {
  final int currentMilliliters;
  final int recommendedMilliliters;
  final bool alarmEnabled;
  final int reminderIntervalMinutes;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  WaterSettings({
    required this.currentMilliliters,
    required this.recommendedMilliliters,
    required this.alarmEnabled,
    required this.reminderIntervalMinutes,
    required this.startTime,
    required this.endTime,
  });

  WaterSettings copyWith({
    int? currentMilliliters,
    int? recommendedMilliliters,
    bool? alarmEnabled,
    int? reminderIntervalMinutes,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return WaterSettings(
      currentMilliliters: currentMilliliters ?? this.currentMilliliters,
      recommendedMilliliters: recommendedMilliliters ?? this.recommendedMilliliters,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  factory WaterSettings.initial() {
    return WaterSettings(
      currentMilliliters: 0,
      recommendedMilliliters: 2000,
      alarmEnabled: true,
      reminderIntervalMinutes: 60,
      startTime: TimeOfDay(hour: 8, minute: 0),
      endTime: TimeOfDay(hour: 23, minute: 0),
    );
  }

  factory WaterSettings.fromMap(Map map) {
    return WaterSettings(
      currentMilliliters: map["currentMilliliters"] ?? 0,
      recommendedMilliliters: map["recommendedMilliliters"] ?? 2000,
      alarmEnabled: map["alarmEnabled"] ?? true,
      reminderIntervalMinutes: map["reminderIntervalMinutes"] ?? 60,
      startTime: map['startTime'] != null 
          ? _timeOfDayFromString(map['startTime']) 
          : TimeOfDay(hour: 8, minute: 0),
      endTime: map['endTime'] != null 
          ? _timeOfDayFromString(map['endTime']) 
          : TimeOfDay(hour: 23, minute: 0),
    );
  }

  static TimeOfDay _timeOfDayFromString(String s) {
    final parts = s.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterSettings &&
        other.currentMilliliters == currentMilliliters &&
        other.recommendedMilliliters == recommendedMilliliters &&
        other.alarmEnabled == alarmEnabled &&
        other.reminderIntervalMinutes == reminderIntervalMinutes &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode =>
      currentMilliliters.hashCode ^
      recommendedMilliliters.hashCode ^
      alarmEnabled.hashCode ^
      reminderIntervalMinutes.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
}
