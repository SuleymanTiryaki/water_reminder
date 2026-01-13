import 'package:flutter/material.dart';
import 'package:notification_scheduler/notification_scheduler.dart';

class TestAlarmButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {        
        print('⏰ Test bildirimi gönderiliyor...');
        
        try {
          // Plugin ile test bildirimi gönder
          await NotificationScheduler.showTestNotification();
          
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
}
