import 'package:flutter/services.dart';

/// ⚠️ DEPRECATED: Bu dosya artık kullanılmıyor!
/// Native platform kanalları yerine Workmanager + Flutter Local Notifications kullanılıyor.
/// Dosya: lib/data/notification/notification_service.dart
@Deprecated('Workmanager kullanın')
class NativeNotificationService {
  static const MethodChannel _channel = MethodChannel('com.fabirt.waterreminder/channel');

  /// Native bildirim zamanlama (Android için)
  static Future<bool> scheduleNativeNotification({
    required DateTime triggerTime,
    required int notificationId,
    required String title,
    required String message,
  }) async {
    try {
      final result = await _channel.invokeMethod('scheduleNativeNotification', {
        'triggerTime': triggerTime.millisecondsSinceEpoch,
        'notificationId': notificationId,
        'title': title,
        'message': message,
      });
      return result == true;
    } catch (e) {
      print('Native bildirim zamanlama hatası: $e');
      return false;
    }
  }

  /// Native bildirimi iptal et
  static Future<bool> cancelNativeNotification(int notificationId) async {
    try {
      final result = await _channel.invokeMethod('cancelNativeNotification', {
        'notificationId': notificationId,
      });
      return result == true;
    } catch (e) {
      print('Native bildirim iptal hatası: $e');
      return false;
    }
  }

  /// Tüm native bildirimleri iptal et (1-60 arası ID'ler)
  static Future<void> cancelAllNativeNotifications() async {
    for (int i = 1; i <= 60; i++) {
      await cancelNativeNotification(i);
    }
  }
}
