@ECHO OFF
SETLOCAL

@REM Image files assets\appicon\iconforeground.png and assets\appicon\iconbackground.png should be larger than 1024x1024 pixels.

ECHO ========================================
ECHO Flutter App Icon Generation Script by KagurazakaYashi
ECHO ========================================

REM =========================================================
REM CHECK DEPENDENCIES
REM =========================================================

ECHO [INFO] Checking ImageMagick...
WHERE magick.exe >NUL 2>NUL
IF ERRORLEVEL 1 (
    ECHO [ERROR] ImageMagick not found. Please install and add to PATH.
    PAUSE
    EXIT /B 1
)
ECHO [OK] ImageMagick detected.

ECHO [INFO] Checking Dart / Flutter...
WHERE dart.bat >NUL 2>NUL
IF ERRORLEVEL 1 (
    WHERE dart.exe >NUL 2>NUL
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Dart/Flutter not found. Please install Flutter SDK.
        PAUSE
        EXIT /B 1
    )
)
ECHO [OK] Dart / Flutter detected.

REM =========================================================
REM CLEAN OLD FILES
REM =========================================================

ECHO [INFO] Cleaning old icon files...

DEL /Q "web\icons\*.png" 2>NUL
DEL /Q "macos\Runner\Assets.xcassets\AppIcon.appiconset\*.png" 2>NUL
DEL /Q "ios\Runner\Assets.xcassets\AppIcon.appiconset\*.png" 2>NUL
DEL /Q "web\favicon.png" 2>NUL
DEL /Q "windows\runner\resources\app_icon.ico" 2>NUL
DEL /Q "assets\appicon\*_*.png" 2>NUL

ECHO [OK] Old files cleaned.

REM =========================================================
REM CLEAN ANDROID RESOURCES
REM =========================================================

ECHO [INFO] Cleaning Android resource directories...
CD "android\app\src\main\res\" || (
    ECHO [ERROR] Failed to enter Android res directory.
    EXIT /B 1
)

FOR /D %%i IN (mipmap-*) DO (
    ECHO [INFO] Removing folder %%i
    RD /S /Q "%%i"
)

FOR /D %%i IN (drawable-*) DO (
    ECHO [INFO] Removing folder %%i
    RD /S /Q "%%i"
)

CD "..\..\..\..\..\" || (
    ECHO [ERROR] Failed to return to project root.
    EXIT /B 1
)

ECHO [OK] Android resources cleaned.

REM =========================================================
REM GENERATE ICONS
REM =========================================================

ECHO [INFO] Generating icon assets...
CD "assets\appicon\" || (
    ECHO [ERROR] Failed to enter assets\appicon directory.
    EXIT /B 1
)

IF NOT EXIST "iconbackground.png" (
    ECHO [ERROR] Missing iconbackground.png
    EXIT /B 1
)

IF NOT EXIST "iconforeground.png" (
    ECHO [ERROR] Missing iconforeground.png
    EXIT /B 1
)

ECHO [INFO] Creating adaptive_icon_background.png
magick.exe "iconbackground.png" -resize "1024x1024!" "adaptive_icon_background.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate adaptive_icon_background.png
    EXIT /B 1
)

ECHO [INFO] Creating adaptive_icon_round_background.png
magick.exe "adaptive_icon_background.png" ( -size 1024x1024 xc:black -fill white -draw "roundrectangle 0,0 1023,1023 220,220" ) -alpha off -compose copy_opacity -composite "adaptive_icon_round_background.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate adaptive_icon_round_background.png
    EXIT /B 1
)

ECHO [INFO] Creating adaptive_icon_foreground.png
magick.exe "iconforeground.png" -resize "1024x1024!" "adaptive_icon_foreground.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate adaptive_icon_foreground.png
    EXIT /B 1
)

ECHO [INFO] Creating launcher_icons.png
magick.exe "adaptive_icon_background.png" "adaptive_icon_foreground.png" -gravity center -composite "launcher_icons.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate launcher_icons.png
    EXIT /B 1
)

ECHO [INFO] Creating launcher_round_icons.png
magick "launcher_icons.png" ( -size 1024x1024 xc:black -fill white -draw "roundrectangle 0,0 1023,1023 220,220" ) -alpha off -compose copy_opacity -composite "launcher_round_icons.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate launcher_round_icons.png
    EXIT /B 1
)

ECHO [INFO] Creating web_round_icon.png
magick.exe "launcher_icons.png" ( -size "1024x1024" xc:none -fill white -draw "circle 512,512 512,1" ) -compose dst-in -composite "web_round_icon.png"
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to generate web_round_icon.png
    EXIT /B 1
)

CD "..\..\" || (
    ECHO [ERROR] Failed to return to root directory.
    EXIT /B 1
)

ECHO [OK] Icon assets generated.

REM =========================================================
REM RUN FLUTTER TOOL
REM =========================================================

ECHO [INFO] Running flutter_launcher_icons...

dart.bat run flutter_launcher_icons
IF ERRORLEVEL 1 (
    ECHO [WARN] dart.bat failed, trying dart.exe...
    dart.exe run flutter_launcher_icons
    IF ERRORLEVEL 1 (
        ECHO [ERROR] flutter_launcher_icons execution failed.
        EXIT /B 1
    )
)

ECHO [OK] flutter_launcher_icons completed.

REM =========================================================
REM DONE
REM =========================================================

ECHO ========================================
ECHO [SUCCESS] All steps completed successfully.
ECHO ========================================

ENDLOCAL
EXIT /B 0