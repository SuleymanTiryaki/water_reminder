import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterreminder/product/water_reminder/model/water_settings.dart';

class LocalStorageService {
  static const String _keyCurrentMilliliters = 'current_milliliters';
  static const String _keyRecommendedMilliliters = 'recommended_milliliters';
  static const String _keyAlarmEnabled = 'alarm_enabled';
  static const String _keyReminderInterval = 'reminder_interval_minutes';
  static const String _keyStartTime = 'start_time';
  static const String _keyEndTime = 'end_time';
  static const String _keyLastUpdate = 'last_update';

  Future<void> saveWaterSettings(WaterSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentMilliliters, settings.currentMilliliters);
    await prefs.setInt(_keyRecommendedMilliliters, settings.recommendedMilliliters);
    await prefs.setBool(_keyAlarmEnabled, settings.alarmEnabled);
    await prefs.setInt(_keyReminderInterval, settings.reminderIntervalMinutes);
    await prefs.setString(_keyStartTime, "${settings.startTime.hour}:${settings.startTime.minute}");
    await prefs.setString(_keyEndTime, "${settings.endTime.hour}:${settings.endTime.minute}");
  }

  Future<WaterSettings> loadWaterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkDailyReset(prefs);
    
    return WaterSettings(
      currentMilliliters: prefs.getInt(_keyCurrentMilliliters) ?? 0,
      recommendedMilliliters: prefs.getInt(_keyRecommendedMilliliters) ?? 2000,
      alarmEnabled: prefs.getBool(_keyAlarmEnabled) ?? true,
      reminderIntervalMinutes: prefs.getInt(_keyReminderInterval) ?? 60,
      startTime: _parseTime(prefs.getString(_keyStartTime), 8, 0),
      endTime: _parseTime(prefs.getString(_keyEndTime), 23, 0),
    );
  }

  TimeOfDay _parseTime(String? value, int defaultHour, int defaultMinute) {
    if (value == null) return TimeOfDay(hour: defaultHour, minute: defaultMinute);
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> addWaterMilliliters(int milliliters) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCurrentMilliliters) ?? 0;
    await prefs.setInt(_keyCurrentMilliliters, current + milliliters);
    await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());
  }

  Future<void> removeWaterMilliliters(int milliliters) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCurrentMilliliters) ?? 0;
    int newValue = current - milliliters;
    
    // Alt sınır 0 olmalı
    if (newValue < 0) {
      newValue = 0;
    }
    
    await prefs.setInt(_keyCurrentMilliliters, newValue);
    // lastUpdate'i güncellemiyoruz çünkü su içme işlemi iptal ediliyor, tarih değişmemeli.
    // Ancak günlük sıfırlama mantığına ters düşmemesi için tarihin bugün olduğundan emin olabiliriz.
  }

  Future<void> setRecommendedMilliliters(int milliliters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRecommendedMilliliters, milliliters);
  }

  Future<void> setAlarmEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlarmEnabled, enabled);
  }

  Future<void> setReminderInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderInterval, minutes);
  }

  Future<void> setStartTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStartTime, "${time.hour}:${time.minute}");
  }

  Future<void> setEndTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEndTime, "${time.hour}:${time.minute}");
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _checkDailyReset(SharedPreferences prefs) async {
    final lastUpdateStr = prefs.getString(_keyLastUpdate);
    if (lastUpdateStr == null) return;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();

    // Farklı gün ise sıfırla
    if (lastUpdate.year != now.year ||
        lastUpdate.month != now.month ||
        lastUpdate.day != now.day) {
      await prefs.setInt(_keyCurrentMilliliters, 0);
    }
  }

  Future<void> setWaterMilliliters(int milliliters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentMilliliters, milliliters);
    await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());
  }
}
