#!/bin/bash

# iOS Build Script for İlaç Vakti

echo "🚀 Starting iOS build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
cd ..

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install iOS dependencies
echo "📱 Installing iOS pods..."
cd ios
pod install --repo-update
cd ..

# Build for iOS
echo "🔨 Building iOS app..."
flutter build ios --release --no-codesign

echo "✅ iOS build completed successfully!"
echo "📁 Build output location: build/ios/iphoneos/Runner.app"
