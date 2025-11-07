CALL build_pre.bat
CALL flutter.bat build "apk" --no-tree-shake-icons --dart-define-from-file="flavor/android.json"
ECHO "%CD%\build\app\outputs\flutter-apk\app-release.apk"
adb devices
adb install "build\app\outputs\flutter-apk\app-release.apk"
