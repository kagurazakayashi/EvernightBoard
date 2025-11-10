set "TARGET_DIR=%CD%\build\windows\x64\runner\Release"

echo Running pre-build script...
CALL build_pre.bat

echo Compiling EvernightBoard for Windows...
CALL flutter.bat build "windows" --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed with error code %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Copying deployment files to: "%TARGET_DIR%"

if exist "shortcuts.ps1" (
    copy /y "shortcuts.ps1" "%TARGET_DIR%\"
) else (
    echo [WARNING] shortcuts.ps1 not found, skipping.
)

if exist "*.md" (
    copy /y "*.md" "%TARGET_DIR%\"
)
if exist "LICENSE*" (
    copy /y "LICENSE*" "%TARGET_DIR%\"
)

echo.
echo Launching: "%TARGET_DIR%\evernight_board.exe"
START "EvernightBoard" /D "%TARGET_DIR%" "evernight_board.exe"
