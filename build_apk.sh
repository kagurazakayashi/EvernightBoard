flutter clean
flutter pub get
bash generate_icons
dart run flutter_iconpicker:generate_packs --packs material
flutter build "apk" -v --no-tree-shake-icons
adb devices
adb install "build/app/outputs/flutter-apk/app-release.apk"
