# 🤖 Android Test Kılavuzu

## 📱 Bağlı Cihaz
- **Model**: LG H870
- **Android**: 9 (API 28)
- **Durum**: ✅ Bağlı

## 🚀 Yükleme
Debug modda yükleniyor:
```bash
flutter run -d LGH87042864c94
```

## ✅ Test Adımları

### 1. İlk Açılış
- [x] Uygulama başladı
- [ ] Bildirim izni iste → İZİN VER
- [ ] Exact Alarm izni iste → İZİN VER  
- [ ] Battery Optimization → KAPAT

### 2. Ayarları Yapılandır
- [ ] Bildirim aralığı ayarla (örn: 30 dakika)
- [ ] Başlangıç saati: 08:00
- [ ] Bitiş saati: 22:00
- [ ] Bildirimleri Aç

### 3. Test Et
- [ ] Uygulamayı arka plana at
- [ ] 30 dakika bekle
- [ ] Bildirim geldi mi? ✅

### 4. Logları Kontrol Et
Terminal çıktısında şunları görmeli:
```
✅ Android Alarm Manager başlatıldı
🤖 Android: AlarmNotificationService kullanılıyor...
✅ Native Alarm #1 zamanlandı: [ZAMAN]
✅ TOPLAM X native alarm başarıyla kuruldu
```

## 🐛 Sorun Giderme

### Bildirim Gelmiyor?
1. **İzinleri Kontrol Et**:
   - Ayarlar > Uygulamalar > Su İçme Hatırlatıcı
   - İzinler > Bildirimler: ✅
   - Alarms & reminders: ✅

2. **Battery Optimization**:
   - Ayarlar > Pil > Pil Optimizasyonu
   - Su İçme Hatırlatıcı: "Optimize edilmiyor" olmalı

3. **Logları İzle**:
   ```bash
   ./watch_logs.sh
   ```

### Build Hatası?
```bash
flutter clean
flutter pub get
flutter run -d LGH87042864c94
```

## 📊 Beklenen Davranış

### Android (AlarmManager):
- ✅ Arka planda çalışır
- ✅ Uygulama kapalıyken bile bildirim atar
- ✅ Exact alarm ile tam zamanında
- ✅ Sınırsız bildirim

### iOS (Timezone):
- ✅ Zamanlanmış bildirimler
- ⚠️ Maksimum 64 bildirim
- ✅ Birkaç güne yayılmış

## 🎯 Başarı Kriterleri
- [x] Uygulama cihazda çalışıyor
- [ ] İzinler verildi
- [ ] Ayarlar yapılandırıldı
- [ ] İlk bildirim geldi (30 dk sonra)
- [ ] Arka planda çalışıyor
- [ ] Uygulama kapalıyken bildirim geliyor

---
**Not**: Debug modda yüklü olduğu için hot reload çalışır (r tuşu).
