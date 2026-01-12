import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'app.dart';
import 'data/notification/background_refresh_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Android için AlarmManager'ı başlat
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
    print('✅ Android Alarm Manager başlatıldı');
  } else if (Platform.isIOS) {
    print('✅ iOS - Alarm Manager gerekmez');
    // iOS background refresh servisini başlat
    await BackgroundRefreshService.initialize();
  }
  
  runApp(App());
}
