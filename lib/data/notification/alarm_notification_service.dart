import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ⚠️ DEPRECATED: Bu dosya artık kullanılmıyor!
/// AndroidAlarmManager iOS'ta desteklenmediği için kaldırıldı.
/// Yeni sistem: Workmanager + Flutter Local Notifications kullanılıyor.
/// Dosya: lib/data/notification/notification_service.dart
@Deprecated('Workmanager kullanın')
class AlarmNotificationService {
  static final AlarmNotificationService _instance = AlarmNotificationService._internal();
  factory AlarmNotificationService() => _instance;
  AlarmNotificationService._internal();

  static const platform = MethodChannel('com.fabirt.waterreminder/alarm');

  Future<void> scheduleAlarmsForNotifications({
    required int intervalMinutes,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    double progress = 0.0,
  }) async {
    print('🔔 AlarmNotificationService (NATIVE): Alarmlar planlanıyor...');
    
    // Önce tüm alarmları iptal et
    await cancelAllAlarms();
    
    // Bildirim mesajları
    final List<String> messages = [
      'Bir bardak su + devam ✅',
      'Minik su molası, büyük fark ✅',
      'Su zamanı! 💧',
      'Kendine bir iyilik yap, su iç 🥤',
      'Hadi, bir bardak daha! 💪',
      'Vücudun suya ihtiyaç duyuyor 🌊',
      'Sağlığın için su içmeyi unutma ❤️',
      'Bardağını doldurma vaktin geldi! 🚰',
    ];

    final now = DateTime.now();
    print('📱 Current Time: $now');
    
    int minutesFromDayStart = now.hour * 60 + now.minute;
    int remainder = minutesFromDayStart % intervalMinutes;
    int minutesUntilNext = intervalMinutes - remainder;
    
    DateTime nextInstance = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + minutesUntilNext,
      0, 0, 0,
    );

    print('⏰ First alarm at: $nextInstance');

    int scheduledCount = 0;
    int attemptCount = 0;
    bool halfwayMessageUsed = false;
    
    while (scheduledCount < 60 && attemptCount < 300) {
      final scheduledDate = nextInstance.add(Duration(minutes: intervalMinutes * attemptCount));
      attemptCount++;
      
      if (scheduledDate.isBefore(now)) {
        continue;
      }

      final scheduledTime = TimeOfDay.fromDateTime(scheduledDate);
      if (!_isTimeBetween(scheduledTime, startTime, endTime)) {
        continue;
      }

      try {
        final alarmId = scheduledCount + 1;
        String title = '💧 Su İçme Zamanı!';
        String body = messages[scheduledCount % messages.length];

        if (!halfwayMessageUsed && progress >= 0.40 && progress <= 0.60 && scheduledCount < 2) {
          body = 'Hedefin yarısı tamam! Bir bardak daha iç ve devam et 🚀';
          halfwayMessageUsed = true;
        }

        // Native alarm kur (AlarmManager + BroadcastReceiver)
        final success = await _scheduleNativeAlarm(
          scheduledDate: scheduledDate,
          alarmId: alarmId,
          title: title,
          message: body,
        );

        if (success) {
          scheduledCount++;
          print('✅ Native Alarm #$scheduledCount zamanlandı: $scheduledDate');
        } else {
          print('❌ Native Alarm #$alarmId zamanlama başarısız');
        }
      } catch (e) {
        print('❌ Alarm planlama hatası: $e');
      }
    }
    
    print('✅ TOPLAM $scheduledCount native alarm başarıyla kuruldu.');
  }

  Future<bool> _scheduleNativeAlarm({
    required DateTime scheduledDate,
    required int alarmId,
    required String title,
    required String message,
  }) async {
    try {
      final result = await platform.invokeMethod('scheduleAlarm', {
        'alarmId': alarmId,
        'triggerTimeMillis': scheduledDate.millisecondsSinceEpoch,
        'title': title,
        'message': message,
      });
      return result == true;
    } catch (e) {
      print('❌ Native alarm zamanlama hatası: $e');
      return false;
    }
  }

  bool _isTimeBetween(TimeOfDay target, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = target.hour * 60 + target.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  Future<void> cancelAllAlarms() async {
    print('🔕 Tüm native alarmlar iptal ediliyor...');
    try {
      await platform.invokeMethod('cancelAllAlarms');
      print('✅ Tüm native alarmlar iptal edildi.');
    } catch (e) {
      print('❌ Alarm iptal hatası: $e');
    }
  }
}
