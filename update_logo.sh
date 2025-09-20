#!/bin/bash

# Logo güncelleme script'i
echo "🎨 Uygulama logosu güncelleniyor..."

# Kaynak logo dosyası
SOURCE_LOGO="assets/app_logo.png"

# Android logo dosyalarını güncelle
echo "📱 Android logo dosyaları güncelleniyor..."
cp "$SOURCE_LOGO" android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp "$SOURCE_LOGO" android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp "$SOURCE_LOGO" android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp "$SOURCE_LOGO" android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp "$SOURCE_LOGO" android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# iOS logo dosyalarını güncelle
echo "🍎 iOS logo dosyaları güncelleniyor..."
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
cp "$SOURCE_LOGO" ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

echo "✅ Logo güncelleme tamamlandı!"
echo "📱 Android ve iOS için tüm logo dosyaları güncellendi."
echo "🔄 Uygulamayı yeniden build etmek için 'flutter clean && flutter pub get' komutunu çalıştırın."
