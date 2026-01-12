import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundRefreshService {
  static const platform = MethodChannel('com.fabirt.waterreminder/background');
  
  static Future<void> initialize() async {
    if (!Platform.isIOS) return;
    
    // iOS background task handler'ı kaydet
    platform.setMethodCallHandler((call) async {
      if (call.method == 'refreshNotifications') {
        await _refreshNotifications();
        return true;
      }
      return false;
    });
    
    print('✅ iOS Background Refresh Service başlatıldı');
  }
  
  static Future<void> _refreshNotifications() async {
    print('🔄 Arka planda bildirimler yenileniyor...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Son ayarları oku
      final enabled = prefs.getBool('notifications_enabled') ?? false;
      final intervalMinutes = prefs.getInt('notification_interval') ?? 60;
      final startHour = prefs.getInt('start_hour') ?? 8;
      final startMinute = prefs.getInt('start_minute') ?? 0;
      final endHour = prefs.getInt('end_hour') ?? 22;
      final endMinute = prefs.getInt('end_minute') ?? 0;
      
      if (!enabled) {
        print('⚠️ Bildirimler kapalı, yenileme yapılmadı');
        return;
      }
      
      // Bildirimleri yenile
      await NotificationService().schedulePeriodicNotifications(
        intervalMinutes: intervalMinutes,
        enabled: enabled,
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        endTime: TimeOfDay(hour: endHour, minute: endMinute),
      );
      
      // Son yenileme zamanını kaydet
      await prefs.setString('last_refresh', DateTime.now().toIso8601String());
      
      print('✅ Arka planda bildirimler başarıyla yenilendi');
    } catch (e) {
      print('❌ Arka plan yenileme hatası: $e');
    }
  }
  
  // Kullanıcı uygulamayı açtığında bildirimleri kontrol et ve gerekirse yenile
  static Future<bool> checkAndRefreshIfNeeded() async {
    if (!Platform.isIOS) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final lastRefreshStr = prefs.getString('last_refresh');
    
    if (lastRefreshStr == null) {
      // İlk kez, yenile
      await _refreshNotifications();
      return true;
    }
    
    final lastRefresh = DateTime.parse(lastRefreshStr);
    final hoursSinceRefresh = DateTime.now().difference(lastRefresh).inHours;
    
    // 12 saatten fazla geçmişse yenile
    if (hoursSinceRefresh >= 12) {
      print('🔄 12 saatten fazla geçti, bildirimler yenileniyor...');
      await _refreshNotifications();
      return true;
    }
    
    print('✅ Bildirimler güncel (${hoursSinceRefresh} saat önce yenilendi)');
    return false;
  }
  
  // Kalan bildirim sayısını kontrol et
  static Future<int> getPendingNotificationCount() async {
    final pending = await NotificationService().getPendingNotifications();
    return pending.length;
  }
  
  // Bildirimlerin %80'i kullanıldıysa yenile
  static Future<bool> checkAndRefreshIfLow() async {
    if (!Platform.isIOS) return false;
    
    final count = await getPendingNotificationCount();
    
    // 64'ün %20'si = 13'ten az kaldıysa yenile
    if (count < 13) {
      print('⚠️ Bildirimler azalıyor ($count/64), yenileniyor...');
      await _refreshNotifications();
      return true;
    }
    
    print('✅ Yeterli bildirim var ($count/64)');
    return false;
  }
}
