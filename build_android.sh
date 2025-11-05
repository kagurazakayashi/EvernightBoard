sh build_pre.sh
flutter build "apk" --no-tree-shake-icons --dart-define-from-file="flavor/android.json"
flutter build "aab" --no-tree-shake-icons --dart-define-from-file="flavor/googleplay.json"
echo "$PWD/build/app/outputs/flutter-apk/app-release.apk"
echo "$PWD/build/app/outputs/bundle/release/app-release.aab"
adb devices
adb install "build/app/outputs/flutter-apk/app-release.apk"
