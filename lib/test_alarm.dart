import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TestAlarmButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {        
        print('⏰ Test bildirimi gönderiliyor...');
        
        try {
          // Doğrudan bildirim gönder (anında)
          await _showTestNotification();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Test bildirimi gönderildi!'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          print('✅ Test bildirimi başarıyla gönderildi');
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Hata: $e')),
            );
          }
          print('❌ Test bildirimi hatası: $e');
        }
      },
      child: Text('🎯 Test Bildirimi Gönder'),
    );
  }
  
  Future<void> _showTestNotification() async {
    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await notifications.initialize(settings);
    
    const androidDetails = AndroidNotificationDetails(
      'test_alarm_channel',
      'Test Bildirimleri',
      channelDescription: 'Test bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await notifications.show(
      999,
      '🎯 TEST BİLDİRİMİ!',
      'Bildirimler çalışıyor!',
      details,
    );
    
    print('✅ Test bildirimi gösterildi');
  }
}
