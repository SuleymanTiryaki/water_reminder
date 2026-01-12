# Su İçme Hatırlatıcı - iOS ve Android Kurulum Kılavuzu

## Yapılan Değişiklikler

### 1. Paket Değişiklikleri
- ❌ **Kaldırıldı**: `android_alarm_manager_plus` (iOS desteklemiyordu)
- ✅ **Eklendi**: `workmanager` v0.5.2 (Hem iOS hem Android destekliyor)
- ✅ **Eklendi**: `timezone` v0.9.0 (Zamanlanmış bildirimler için)

### 2. iOS Yapılandırması
- `Info.plist` güncellendi - Arka plan görevleri için izinler eklendi
- `AppDelegate.swift` güncellendi - Workmanager yapılandırması eklendi
- CocoaPods bağımlılıkları yüklendi

### 3. Bildirim Sistemi
- Workmanager ile periyodik arka plan görevleri
- Flutter Local Notifications ile timezone tabanlı zamanlanmış bildirimler
- Hem iOS hem Android'de çalışır

## Gerçek Cihazda Test Etme

### iOS için:
1. **Xcode'u açın**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Signing & Capabilities**:
   - Xcode'da Runner target'ını seçin
   - "Signing & Capabilities" sekmesine gidin
   - Team'inizi seçin (Apple Developer hesabınız gerekli)
   - "Background Modes" capability'sini ekleyin (zaten eklendi)

3. **iPhone'u bağlayın** ve cihazınızı seçin

4. **Çalıştırın**:
   ```bash
   flutter run
   ```

### Android için:
1. **USB Debugging'i açın** (Geliştirici Seçenekleri)
2. **Cihazı bağlayın**
3. **Çalıştırın**:
   ```bash
   flutter run
   ```

## Önemli Notlar

### iOS Bildirimleri:
- iOS'ta periyodik arka plan görevleri **minimum 15 dakika** aralıklarla çalışır
- Daha kısa aralıklar seçerseniz, sistem otomatik olarak 15 dakikaya yükseltir
- iOS, arka plan görevlerini batarya durumuna göre optimize eder
- İlk 10 bildirim timezone ile zamanlanır (daha hassas)
- Sonraki bildirimler periyodik görevlerle çalışır

### Android Bildirimleri:
- Android'de workmanager minimum 15 dakika önerir
- Daha hassas zamanlamalar için timezone kullanılır
- İlk 10 bildirim timezone ile zamanlanır
- Battery optimization'ı kapatmanız önerilir

### İzinler:
Uygulama aşağıdaki izinleri otomatik ister:
- ✅ Bildirim izni
- ✅ Exact alarm izni (Android 12+)
- ✅ Battery optimization bypass (Android)

## Sorun Giderme

### "Bildirimler gelmiyor"
1. Ayarlar > Bildirimler > Su İçme Hatırlatıcı - Bildirimlerin açık olduğundan emin olun
2. iOS: Uygulamayı arka plana atın ve birkaç dakika bekleyin
3. Android: Battery optimization'ı kapatın

### "iOS'ta periyodik bildirimler çalışmıyor"
- iOS'un arka plan görevleri cihazın durumuna göre çalışır
- Düşük batarya durumunda iOS görevleri erteleyebilir
- Cihaz şarja takılıyken daha düzenli çalışır

### "MissingPluginException hatası"
- Bu hata artık gelmemeli çünkü `android_alarm_manager_plus` kaldırıldı
- Eğer hala geliyorsa:
  ```bash
  flutter clean
  flutter pub get
  cd ios && pod install && cd ..
  flutter run
  ```

## Geliştirici Notları

### Bildirim Akışı:
1. Kullanıcı ayarları değiştirdiğinde `schedulePeriodicNotifications()` çağrılır
2. İlk 10 bildirim `zonedSchedule()` ile zamanlanır (hassas)
3. Periyodik görev `Workmanager` ile kaydedilir
4. Arka plan görevi tetiklendiğinde bildirim gönderilir

### Test için:
```dart
// Test bildirimi gönder
await NotificationService().showTestNotification();

// Zamanlanmış bildirimleri kontrol et
await NotificationService().getPendingNotifications();
```

## Version
- **App Version**: 1.0.4+5
- **Flutter SDK**: >=2.12.0 <3.0.0
- **Workmanager**: 0.5.2
- **Flutter Local Notifications**: 17.0.0

## Lisans
Bu proje MIT lisansı altındadır.
