flutter clean
flutter pub get
bash generate_icons
flutter build "apk" -v --no-tree-shake-icons
adb devices
adb install "build/app/outputs/flutter-apk/app-release.apk"
