import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:waterreminder/constant/constant.dart';
import 'package:waterreminder/data/local/local_storage_service.dart';
import 'package:waterreminder/data/notification/notification_service.dart';
import 'package:waterreminder/data/platform/platform_messenger.dart';
import 'package:waterreminder/product/water_reminder/model/water_settings.dart';

class WaterService {
  final _localStorage = LocalStorageService();
  final _notificationService = NotificationService();
  final _waterSettings = BehaviorSubject<WaterSettings>();

  WaterService() {
    // Platform callback'i KALDIRILDI
    // Native taraftan gelen veriler Flutter SharedPreferences'ı override ediyordu
    // Artık sadece Flutter tarafındaki SharedPreferences'ı kullanıyoruz
    
    // Başlangıçta local storage'dan yükle
    _loadInitialSettings();
  }

  Future<void> _updateNotifications(WaterSettings settings) async {
    double progress = settings.recommendedMilliliters > 0
        ? settings.currentMilliliters / settings.recommendedMilliliters
        : 0.0;

    // Flutter local notifications kullan (Native method channel sorunu var)
    await _notificationService.schedulePeriodicNotifications(
      intervalMinutes: settings.reminderIntervalMinutes,
      enabled: settings.alarmEnabled,
      startTime: settings.startTime,
      endTime: settings.endTime,
      progress: progress,
    );
  }

  Future<void> _loadInitialSettings() async {
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Bildirimleri güncelle (Dart tarafı)
    await _updateNotifications(settings);
  }

  Stream<WaterSettings> get waterSettings => _waterSettings.stream;

  Future<void> drinkWater(int milliliters) async {
    // Local storage'a kaydet
    await _localStorage.addWaterMilliliters(milliliters);
    // Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Bildirimleri güncelle (yeni progress ile)
    await _updateNotifications(settings);
    
    // Android için native metodu çağır (hata olsa da devam et)
    PlatformMessenger.invokeMethod(Constant.methodDrinkWater, milliliters);
  }

  Future<void> removeWater(int milliliters) async {
    // Local storage'dan düş
    await _localStorage.removeWaterMilliliters(milliliters);
    // Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Bildirimleri güncelle
    await _updateNotifications(settings);
    
    // Android tarafında 'drinkWater' metoduna negatif değer göndererek düşüm yapabiliriz 
    // veya özel bir metod tanımlayabiliriz. Mevcut yapıda negatif değer çalışabilir mi?
    // Android tarafını değiştiremediğimiz için şimdilik sadece local storage
    // ve UI güncellemesi yapıyoruz. Eğer widget senkronizasyonu bozulursa
    // Android tarafına yeni metod eklenmelidir.
    // Şimdilik negatif göndererek deneyelim:
    PlatformMessenger.invokeMethod(Constant.methodDrinkWater, -milliliters);
  }

  Future<void> changeAlarmEnabled(bool enabled) async {
    // Local storage'a kaydet
    await _localStorage.setAlarmEnabled(enabled);
    // Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Bildirimleri güncelle
    await _updateNotifications(settings);
    
    // Native taraftaki "enabled" state'ini güncelliyoruz ki DataStore senkron kalsın.
    // Ancak Native alarmı çalıştırmayacağız (MainActivity tarafında kodu engellendi).
    PlatformMessenger.invokeMethod(
        Constant.methodChangeNotificationEnabled, enabled);
  }

  Future<void> setStartTime(TimeOfDay time) async {
    await _localStorage.setStartTime(time);
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);

    await _updateNotifications(settings);
  }

  Future<void> setEndTime(TimeOfDay time) async {
    await _localStorage.setEndTime(time);
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);

    await _updateNotifications(settings);
  }

  void subscribeToDataStore() {
    // Bu metod artık kullanılmıyor çünkü Native callback kaldırıldı
    // Eski kod uyumluluk için boş bırakıldı
    print('subscribeToDataStore çağrıldı ama artık kullanılmıyor');
  }

  Future<void> setRecommendedMilliliters(int milliliters) async {
    // Local storage'a kaydet
    await _localStorage.setRecommendedMilliliters(milliliters);
    // Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);

    // Bildirimleri güncelle
    await _updateNotifications(settings);
    
    // Android için native metodu çağır
    PlatformMessenger.invokeMethod(
        Constant.methodSetRecommendedMilliliters, milliliters);
  }

  Future<void> setReminderInterval(int minutes) async {
    // 1. Önce Native tarafa gönder (DataStore güncellenir)
    PlatformMessenger.invokeMethod(
        Constant.methodSetReminderInterval, minutes);
    
    // 2. Sonra Flutter local storage'a kaydet
    await _localStorage.setReminderInterval(minutes);
    
    // 3. Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // 4. Bildirimleri güncelle
    await _updateNotifications(settings);
  }

  Future<void> clearDataStore() async {
    await _localStorage.clearAll();
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Android için native metodu çağır
    PlatformMessenger.invokeMethod(Constant.methodClearDataStore);
  }

  Future<void> resetDailyIntake() async {
    // Sadece su miktarını sıfırla
    await _localStorage.setWaterMilliliters(0);
    // Güncel settings'i yükle ve yayınla
    final settings = await _localStorage.loadWaterSettings();
    _waterSettings.add(settings);
    
    // Bildirimleri güncelle
    await _updateNotifications(settings);
    
    // UI güncellensin diye native tarafa da bildiriyoruz (gerçi şu an native taraf mock gibi ama olsun)
    // Aslında burada sadece native tarafa 0 göndermek yetmez, native taraftaki state'i de resetlemek lazım
    // ama native implementasyon yok şu an.
    // DÜZELTME: Native tarafı da sıfırlıyoruz.
    PlatformMessenger.invokeMethod(Constant.methodResetWater);
  }

  void close() {
    _waterSettings.close();
  }
}
