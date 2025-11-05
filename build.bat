CALL build_pre.bat
CALL flutter.bat build "windows" --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"
ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.exe"
explorer "%CD%\build\windows\x64\runner\Release"
START "EvernightBoard" /D "%CD%\build\windows\x64\runner\Release\" "evernight_board.exe"
