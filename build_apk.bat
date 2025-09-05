CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL flutter.bat build "apk" -v --no-tree-shake-icons
adb devices
adb install "build\app\outputs\flutter-apk\app-release.apk"
