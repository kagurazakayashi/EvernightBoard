CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL dart.bat run flutter_native_splash:create
CALL dart.bat run flutter_iconpicker:generate_packs --packs material
CALL flutter.bat gen-l10n
RD /S /Q "build\app"
CALL flutter.bat build "apk" --no-tree-shake-icons --dart-define-from-file="flavor/android.json"
ECHO "%CD%\build\app\outputs\flutter-apk\app-release.apk"
explorer "%CD%\build\app\outputs\flutter-apk"
adb devices
adb install "build\app\outputs\flutter-apk\app-release.apk"
