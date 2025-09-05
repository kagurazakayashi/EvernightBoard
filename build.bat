CALL flutter.bat clean
CALL flutter.bat pub get
CALL generate_icons.bat
CALL flutter.bat build "windows" -v --no-tree-shake-icons
START "EvernightBoard" /D "build\windows\x64\runner\Release\" "evernight_board.exe"
