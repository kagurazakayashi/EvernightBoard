CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL dart.bat run flutter_iconpicker:generate_packs --packs material
CALL flutter.bat build "apk" -v --no-tree-shake-icons
adb devices
adb install "build\app\outputs\flutter-apk\app-release.apk"
