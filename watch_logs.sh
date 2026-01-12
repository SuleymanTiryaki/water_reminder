#!/bin/bash

# Su İçme Hatırlatıcı - Log İzleme Script'i
# Bu script cihaz loglarını izler ve ilgili mesajları gösterir

echo "🔍 Cihaz logları izleniyor..."
echo "📱 Uygulama çalıştığında loglar burada görünecek"
echo "----------------------------------------"

# ADB path'ini bul
ADB_PATH=$(which adb)
if [ -z "$ADB_PATH" ]; then
    # Flutter'ın ADB'sini kullan
    FLUTTER_PATH=$(which flutter)
    FLUTTER_DIR=$(dirname "$FLUTTER_PATH")
    ADB_PATH="$FLUTTER_DIR/cache/artifacts/engine/android-arm-release/android-sdk-tools/platform-tools/adb"
    
    # Alternatif konumlar
    if [ ! -f "$ADB_PATH" ]; then
        ADB_PATH="$HOME/Library/Android/sdk/platform-tools/adb"
    fi
    if [ ! -f "$ADB_PATH" ]; then
        ADB_PATH="/usr/local/bin/adb"
    fi
fi

echo "ADB konumu: $ADB_PATH"
echo "----------------------------------------"

# Logları temizle
"$ADB_PATH" logcat -c 2>/dev/null

# Logları filtrele ve izle
"$ADB_PATH" logcat | grep -E "(flutter|waterreminder|WorkManager|Notification|Alarm|Error|Exception|FATAL)" --color=auto
