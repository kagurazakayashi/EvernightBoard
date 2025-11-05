DEL flutter_*.log
CALL flutter.bat clean
RD /S /Q build
CALL flutter.bat pub get
CALL generate_icons.bat
CALL dart.bat run flutter_native_splash:create
CALL dart.bat run flutter_iconpicker:generate_packs --packs material
CALL flutter.bat gen-l10n
