sh build_pre.sh
flutter build "apk" --no-tree-shake-icons --dart-define-from-file="flavor/android.json"
echo "$PWD/build/app/outputs/flutter-apk/app-release.apk"
adb devices
adb install "build/app/outputs/flutter-apk/app-release.apk"
