DEL flutter_*.log
CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL dart.bat run flutter_native_splash:create
CALL dart.bat run flutter_iconpicker:generate_packs --packs material
CALL flutter.bat gen-l10n
RD /S /Q build
CALL flutter.bat build "windows" --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"
ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.exe"
explorer "%CD%\build\windows\x64\runner\Release"
START "EvernightBoard" /D "%CD%\build\windows\x64\runner\Release\" "evernight_board.exe"
