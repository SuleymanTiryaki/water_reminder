import 'package:flutter/material.dart';
import 'package:notification_scheduler/notification_scheduler.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Plugin ile bildirim sistemini başlat (hem Android hem iOS)
  await NotificationScheduler.initialize();
  print('✅ Notification Scheduler Plugin başlatıldı');
  
  runApp(App());
}
