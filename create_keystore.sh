#!/bin/bash

# Android Keystore Oluşturma Scripti

echo "🔐 Android Keystore oluşturuluyor..."

# Keystore oluştur
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storetype JKS

echo "📄 key.properties dosyası oluşturuluyor..."

# key.properties dosyası oluştur
cat > android/key.properties << EOF
storePassword=123456
keyPassword=123456
keyAlias=upload
storeFile=../upload-keystore.jks
EOF

echo "✅ Keystore ve key.properties dosyası oluşturuldu!"
echo "📝 Şifre: 123456 (değiştirmeyi unutmayın)"
echo "🔑 Alias: upload"
echo "📁 Dosya: upload-keystore.jks"

echo ""
echo "🚀 Artık release build alabilirsiniz:"
echo "flutter build appbundle --release"
