flutter clean
flutter pub get
bash generate_icons.sh
dart run flutter_native_splash:create
dart run flutter_iconpicker:generate_packs --packs material
flutter gen-l10n
rm -rf "`pwd`/build/app"
flutter build "apk" --no-tree-shake-icons --dart-define-from-file="flavor/android.json"
echo "`pwd`/build/app/outputs/flutter-apk/app-release.apk"
adb devices
adb install "build/app/outputs/flutter-apk/app-release.apk"
