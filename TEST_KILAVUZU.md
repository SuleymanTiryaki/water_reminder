# 🧪 Su İçme Hatırlatıcı - Test Kılavuzu

## 📱 Cihaz Bilgileri
- **Cihaz**: LG H870
- **Android Sürümü**: Android 9 (API 28)
- **Durum**: ✅ Bağlı ve Hazır

## 🚀 Kurulum Tamamlandı

### APK Konumu
```
build/app/outputs/flutter-apk/app-release.apk
```

### Manuel Kurulum (Gerekirse)
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## ✅ Test Adımları

### 1. İlk Açılış Testleri
- [ ] Uygulama açılıyor mu?
- [ ] Bildirim izni isteniyor mu?
- [ ] İzinleri verin (Bildirimler, Exact Alarm, Battery Optimization)

### 2. Bildirim İzinleri
Uygulama açıldığında şu izinler istenecek:
1. **Bildirim İzni** - İzin ver
2. **Exact Alarm İzni** (Android 12+) - İzin ver
3. **Battery Optimization** - Kapat (önemli!)

### 3. Temel Fonksiyon Testleri

#### A) Test Bildirimi Gönder
1. Ayarlar sayfasını açın
2. "Test Bildirimi Gönder" butonuna tıklayın
3. Anında bir test bildirimi gelmelidir
4. ✅ Geldiyse bildirimler çalışıyor

#### B) Su İçme Takibi
1. Ana sayfada "+" butonuna tıklayın
2. Su miktarı seçin (örn: 250ml)
3. Progress bar güncellenmelidir
4. ✅ Günlük hedefe doğru ilerleme göstermeli

#### C) Periyodik Bildirimler
1. Ayarlar > "Bildirimleri Aç/Kapat" açık olmalı
2. "Bildirim Aralığı" ayarlayın (örn: 30 dakika)
3. "Başlangıç Saati" ve "Bitiş Saati" ayarlayın
4. Uygulamayı arka plana atın
5. **Bekleyin** - İlk bildirim ayarlanan süre sonra gelecek

### 4. Arka Plan Testi (ÖNEMLİ!)

#### Adımlar:
1. Bildirimleri aç ve aralık ayarla (örn: 15-30 dakika)
2. Uygulamayı **tamamen kapatın** (arka planda çalışmasın)
3. Telefonu kilit ekranına alın
4. **BEKLE** - Belirlenen süre sonra bildirim gelmelidir

#### Beklenen Sonuç:
- ✅ Uygulama kapalıyken bile bildirim gelmeli
- ✅ Belirlenen aralıklarla düzenli bildirimler gelmeli
- ✅ Başlangıç-Bitiş saatleri arasında çalışmalı

### 5. Battery Optimization Kontrolü

Bildirimler düzenli gelmiyorsa:
1. Ayarlar > Uygulamalar > Su İçme Hatırlatıcı
2. Pil Kullanımı > "Pil Optimizasyonu"
3. **"Optimize etme"** seçeneğini kapatın
4. Uygulamayı yeniden başlatın

### 6. Bildirim Ayarları Kontrolü

Cihaz Ayarları:
1. Ayarlar > Uygulamalar > Su İçme Hatırlatıcı > Bildirimler
2. Tüm bildirim kategorileri açık olmalı
3. Ses ve titreşim aktif olmalı

## 🐛 Sorun Giderme

### Bildirimler Gelmiyor
1. **İzinleri kontrol et**:
   - Ayarlar > Uygulamalar > Su İçme Hatırlatıcı > İzinler
   - Bildirimler açık mı?

2. **Battery Optimization kapalı mı?**
   - Ayarlar > Pil > Pil Optimizasyonu
   - Su İçme Hatırlatıcı "Optimize edilmiyor" olmalı

3. **Exact Alarm izni** (Android 12+):
   - Ayarlar > Uygulamalar > Su İçme Hatırlatıcı > Alarms & reminders
   - İzin verilmiş olmalı

### Uygulama Crash Oluyor
```bash
# Logları kontrol et
adb logcat | grep -i flutter
adb logcat | grep -i waterreminder
```

### APK Yüklenmiyor
```bash
# Eski sürümü kaldır
adb uninstall com.fabirt.waterreminder

# Tekrar yükle
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Test Sonuçları

### Başarı Kriterleri:
- [x] Uygulama açılıyor
- [ ] İzinler veriliyor
- [ ] Test bildirimi geliyor
- [ ] Su ekleme çalışıyor
- [ ] Progress bar güncelleniyor
- [ ] Periyodik bildirimler geliyor
- [ ] Arka planda çalışıyor
- [ ] Uygulama kapalıyken bildirim geliyor

## 🎯 Performans Notları

### Android 9 (API 28) için:
- ✅ WorkManager tam destekli
- ✅ Background task'ler çalışır
- ✅ Exact alarm'lar çalışır
- ⚠️ Battery optimization agresif olabilir

### Önerilen Test Süresi:
- **Kısa Test**: 30 dakika (2-3 bildirim bekle)
- **Uzun Test**: 3-4 saat (bir gün boyunca)
- **Gerçek Kullanım**: 24 saat (gece-gündüz döngüsü)

## 📝 Not Defteri

Testlerinizi kaydedin:

**Test Tarihi**: 9 Ocak 2026
**Test Eden**: [İsminiz]

**Gözlemler**:
- 
- 
- 

**Bulunan Hatalar**:
- 
- 

**İyileştirme Önerileri**:
- 
- 

## 🔄 Güncelleme

Yeni sürüm yüklemek için:
```bash
cd /Users/suleyman/Desktop/water_reminder/water_reminder
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## 📞 Destek

Sorun yaşarsanız:
1. Logları kaydedin (`adb logcat`)
2. Ekran görüntüleri alın
3. Hata mesajlarını not edin

---
**İyi Testler!** 💧🚀
