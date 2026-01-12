import 'dart:io' show Platform;
import 'package:flutter/material.dart'; // import TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_notification_service.dart';
import 'background_refresh_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone'u başlat
    tz.initializeTimeZones();
    // Yerel timezone'u ayarla
    final locationName = await _getLocalTimeZoneName();
    tz.setLocalLocation(tz.getLocation(locationName));
    
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

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('NotificationService initialized with timezone: $locationName');
  }

  Future<String> _getLocalTimeZoneName() async {
    try {
      // Cihazın yerel timezone'unu al
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      
      // Türkiye için Europe/Istanbul
      if (hours == 3) return 'Europe/Istanbul';
      // UTC için
      if (hours == 0) return 'UTC';
      
      // Diğer timezone'lar için generic UTC offset
      return 'UTC';
    } catch (e) {
      print('Timezone belirleme hatası: $e');
      return 'UTC';
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Bildirime tıklandı: ${response.payload}');
  }

  Future<bool> requestPermission() async {
    // iOS için önce flutter_local_notifications ile izin iste
    if (Platform.isIOS) {
      try {
        await initialize();
        
        print('🍎 iOS: Flutter local notifications ile izin isteniyor...');
        final result = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        
        print('🍎 iOS bildirim izni sonucu: $result');
        
        if (result == true) {
          return true;
        }
        
        // İzin verilmediği durumda permission_handler dene
        print('🍎 iOS: permission_handler ile kontrol ediliyor...');
        final status = await Permission.notification.status;
        
        if (status.isGranted) {
          print('✅ İzin zaten verilmiş (permission_handler)');
          return true;
        }
        
        if (status.isPermanentlyDenied) {
          print('⚠️ İzin kalıcı olarak reddedildi. Ayarlara yönlendir.');
          return false;
        }
        
        return result ?? false;
      } catch (e) {
        print('❌ iOS izin hatası: $e');
        return false;
      }
    }
    
    // Android için mevcut kod
    try {
      final status = await Permission.notification.status;
      
      if (status.isGranted) {
        print('✅ Bildirim izni zaten verilmiş');
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.notification.request();
        print('Bildirim izni istendi. Sonuç: $result');
        
        if (result.isGranted) {
          return true;
        } else if (result.isPermanentlyDenied) {
          print('⚠️ Bildirim izni reddedildi.');
          return false;
        }
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        print('⚠️ Bildirim izni kalıcı olarak reddedildi.');
        return false;
      }

      return false;
    } catch (e) {
      print('İzin kontrolü hatası: $e');
      return Platform.isAndroid;
    }
  }

  // Test bildirimi gönder
  Future<void> showTestNotification() async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Su İçme Hatırlatıcısı',
      channelDescription: 'Periyodik su içme hatırlatmaları',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'Test bildirimi',
      autoCancel: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      '💧 Test Bildirimi!',
      'Bu bir test bildirimidir. Eğer bunu görüyorsanız bildirimler çalışıyor!',
      details,
    );
    print('Test bildirimi gönderildi');
  }

  // Su içme hatırlatma bildirimi gönder - AlarmManager tarafından çağrılacak
  Future<void> showWaterReminder() async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Su İçme Hatırlatıcısı',
      channelDescription: 'Periyodik su içme hatırlatmaları',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      category: AndroidNotificationCategory.alarm,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💧 Su İçme Zamanı!',
      'Hidrasyon seviyenizi korumak için su içmeyi unutmayın.',
      details,
    );
    print('Su içme hatırlatma bildirimi gönderildi: ${DateTime.now()}');
  }

  // Battery optimization'ı kontrol et ve devre dışı bırak
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      // ignoreBatteryOptimizations izni iste
      final status = await Permission.ignoreBatteryOptimizations.status;
      
      if (status.isGranted) {
        print('Battery optimization zaten devre dışı');
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.ignoreBatteryOptimizations.request();
        print('Battery optimization izni istendi: $result');
        return result.isGranted;
      }

      return false;
    } catch (e) {
      print('Battery optimization kontrolü hatası: $e');
      return false;
    }
  }

  // Exact alarm izni kontrol et (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      
      if (status.isGranted) {
        print('Exact alarm izni zaten verilmiş');
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();
        print('Exact alarm izni istendi: $result');
        return result.isGranted;
      }

      return false;
    } catch (e) {
      print('Exact alarm izni kontrolü hatası (Android 8-11 için normal): $e');
      // Android 8-11'de bu izin otomatik verilir
      return true;
    }
  }

  // Tüm izinleri kontrol et
  Future<bool> checkAllPermissions() async {
    final notification = await requestPermission();
    final battery = await requestIgnoreBatteryOptimizations();
    final exactAlarm = await requestExactAlarmPermission();
    
    print('İzin durumu - Bildirim: $notification, Battery: $battery, ExactAlarm: $exactAlarm');
    return notification && battery && exactAlarm;
  }

  Future<void> schedulePeriodicNotifications({
    required int intervalMinutes,
    required bool enabled,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    double progress = 0.0,
  }) async {
    print('schedulePeriodicNotifications çağrıldı: interval=$intervalMinutes, enabled=$enabled, platform=${Platform.operatingSystem}');
    
    // iOS için ayarları kaydet (background refresh için)
    if (Platform.isIOS) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      await prefs.setInt('notification_interval', intervalMinutes);
      await prefs.setInt('start_hour', startTime.hour);
      await prefs.setInt('start_minute', startTime.minute);
      await prefs.setInt('end_hour', endTime.hour);
      await prefs.setInt('end_minute', endTime.minute);
      
      // Arka planda bildirimler azaldıysa yenile
      await BackgroundRefreshService.checkAndRefreshIfLow();
    }
    
    if (!enabled) {
      print('Bildirimler kapalı, tüm bildirimleri iptal ediyorum');
      await cancelAllNotifications();
      return;
    }

    // İzinleri kontrol et
    final hasNotificationPermission = await requestPermission();
    if (!hasNotificationPermission) {
      print('❌ Bildirim izni verilmediği için planlama yapılamadı.');
      return;
    }

    if (Platform.isAndroid) {
      // Android: AlarmManager kullan (çalışıyor!)
      print('🤖 Android: AlarmNotificationService kullanılıyor...');
      await requestExactAlarmPermission();
      await requestIgnoreBatteryOptimizations();
      
      await AlarmNotificationService().scheduleAlarmsForNotifications(
        intervalMinutes: intervalMinutes,
        startTime: startTime,
        endTime: endTime,
        progress: progress,
      );
    } else if (Platform.isIOS) {
      // iOS: Timezone scheduled notifications kullan
      print('🍎 iOS: Timezone scheduled notifications kullanılıyor...');
      await _scheduleIOSNotifications(
        intervalMinutes: intervalMinutes,
        startTime: startTime,
        endTime: endTime,
        progress: progress,
      );
    }
  }

  Future<void> _scheduleIOSNotifications({
    required int intervalMinutes,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    double progress = 0.0,
  }) async {
    await initialize();
    
    // Önce tüm bildirimleri iptal et
    await _notifications.cancelAll();
    
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
    
    // Başlangıç ve bitiş saatlerini hesapla
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    // Bir günde kaç bildirim gönderileceğini hesapla
    int dailyNotifications;
    if (startMinutes <= endMinutes) {
      // Normal gün (örn: 08:00 - 22:00)
      dailyNotifications = ((endMinutes - startMinutes) / intervalMinutes).floor();
    } else {
      // Gece yarısını geçiyor (örn: 22:00 - 08:00)
      dailyNotifications = ((1440 - startMinutes + endMinutes) / intervalMinutes).floor();
    }
    
    print('📊 Günlük bildirim sayısı: $dailyNotifications (Her $intervalMinutes dakikada bir)');
    print('⏰ Saat aralığı: ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}');

    int scheduledCount = 0;
    
    // iOS limiti 64 bildirim - bunu günlere yayalım
    final maxDays = (64 / (dailyNotifications > 0 ? dailyNotifications : 1)).ceil();
    print('📅 Maksimum $maxDays gün için bildirim zamanlanacak');
    
    // Her gün için bildirimleri oluştur
    for (int day = 0; day < maxDays && scheduledCount < 64; day++) {
      final targetDate = now.add(Duration(days: day));
      
      // O günün başlangıç saatini hesapla
      DateTime dayStart = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        startTime.hour,
        startTime.minute,
      );
      
      // Eğer bugün ise ve başlangıç saati geçmişse, sonraki interval'den başla
      if (day == 0 && dayStart.isBefore(now)) {
        final minutesSinceStart = now.difference(dayStart).inMinutes;
        final nextIntervalOffset = ((minutesSinceStart / intervalMinutes).ceil() * intervalMinutes);
        dayStart = dayStart.add(Duration(minutes: nextIntervalOffset));
      }
      
      // O gün için bildirimleri oluştur
      for (int i = 0; i < dailyNotifications && scheduledCount < 64; i++) {
        final scheduledDate = dayStart.add(Duration(minutes: intervalMinutes * i));
        
        // Saat aralığı kontrolü
        final scheduledTime = TimeOfDay.fromDateTime(scheduledDate);
        if (!_isTimeBetween(scheduledTime, startTime, endTime)) {
          continue;
        }
        
        // Geçmiş bir zaman değilse zamanla
        if (scheduledDate.isAfter(now)) {
          try {
            final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
            
            const iosDetails = DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            );

            const details = NotificationDetails(
              iOS: iosDetails,
            );

            final message = messages[scheduledCount % messages.length];

            // Her bildirim için benzersiz ID kullan (1-64 arası)
            await _notifications.zonedSchedule(
              scheduledCount + 1,  // ID: 1'den başlar
              '💧 Su İçme Zamanı!',
              message,
              tzScheduledDate,
              details,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );

            scheduledCount++;
            // Debug için sadece her 5. bildirimi logla (log kalabalığını azalt)
            if (scheduledCount % 5 == 0 || scheduledCount == 1) {
              print('✅ iOS Bildirim #$scheduledCount zamanlandı: $scheduledDate');
            }
          } catch (e) {
            print('❌ iOS bildirim zamanlama hatası: $e');
          }
        }
      }
    }
    
    print('✅ TOPLAM $scheduledCount adet iOS bildirimi zamanlandı ($maxDays gün için)');
  }

  bool _isTimeBetween(TimeOfDay target, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = target.hour * 60 + target.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Gece yarısını geçen aralık (örn. 23:00 - 08:00)
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    
    if (Platform.isAndroid) {
      await AlarmNotificationService().cancelAllAlarms();
    }
    
    print('Tüm bildirimler iptal edildi');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('Bekleyen bildirim sayısı: ${pending.length}');
    for (var notification in pending) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    return pending;
  }
}
