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
DEL /Q "windows\msix_assets\BadgeLogo*.png" 2>NUL
DEL /Q "mask.png" 2>NUL

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

ECHO [INFO] Creating installer_nsi.bmp
magick.exe "iconbackground.png" -resize "164x314!" ^( iconforeground.png -resize "150x150!" ^) -gravity center -composite BMP3:installer_nsi.bmp
IF ERRORLEVEL 1 (
    ECHO [ERROR] Failed to installer_nsi.bmp
    EXIT /B 1
)

IF NOT EXIST "monochromatic.png" (
    ECHO [INFO] Creating monochromatic.png for Microsoft Store
    magick.exe "iconforeground.png" -resize "512x512!" -threshold 50%% -fill black -opaque white -fill white -opaque black -transparent black monochromatic.png
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Failed to generate monochromatic.png
        EXIT /B 1
    )
) ELSE (
    ECHO [INFO] monochromatic.png already exists, skipping generation.
)

CD "..\..\" || (
    ECHO [ERROR] Failed to return to root directory.
    EXIT /B 1
)

ECHO [OK] Icon assets generated.

REM =========================================================
REM GENERATE MICROSOFT STORE BADGELOGO
REM =========================================================

ECHO [INFO] Generating Microsoft Store BadgeLogo assets...
IF NOT EXIST "assets\appicon\monochromatic.png" (
    ECHO [WARN] monochromatic.png not found, skipping BadgeLogo generation.
    GOTO :badge_done
)

ECHO [INFO] Creating BadgeLogo base and scale variants from monochromatic.png...
REM Microsoft Store requires RGBA (color-type 6) format with pure white (#FFFFFF) or transparent pixels.

magick.exe "assets\appicon\monochromatic.png" -resize 24x24 -background none -gravity center -extent 24x24 -fill white -colorize 100 "windows\msix_assets\BadgeLogo.png"
IF ERRORLEVEL 1 GOTO :badge_error

magick.exe "assets\appicon\monochromatic.png" -resize 30x30 -background none -gravity center -extent 30x30 -fill white -colorize 100 "windows\msix_assets\BadgeLogo.scale-125.png"
IF ERRORLEVEL 1 GOTO :badge_error

magick.exe "assets\appicon\monochromatic.png" -resize 36x36 -background none -gravity center -extent 36x36 -fill white -colorize 100 "windows\msix_assets\BadgeLogo.scale-150.png"
IF ERRORLEVEL 1 GOTO :badge_error

magick.exe "assets\appicon\monochromatic.png" -resize 48x48 -background none -gravity center -extent 48x48 -fill white -colorize 100 "windows\msix_assets\BadgeLogo.scale-200.png"
IF ERRORLEVEL 1 GOTO :badge_error

magick.exe "assets\appicon\monochromatic.png" -resize 96x96 -background none -gravity center -extent 96x96 -fill white -colorize 100 "windows\msix_assets\BadgeLogo.scale-400.png"
IF ERRORLEVEL 1 GOTO :badge_error

ECHO [OK] BadgeLogo assets generated with white foreground and transparent background.

:badge_done

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