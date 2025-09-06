CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL dart.bat run flutter_iconpicker:generate_packs --packs material
CALL flutter.bat build "windows" -v --no-tree-shake-icons
START "EvernightBoard" /D "build\windows\x64\runner\Release\" "evernight_board.exe"
