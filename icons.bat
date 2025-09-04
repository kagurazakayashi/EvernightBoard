DEL /Q "web\icons\*.png"
DEL /Q "macos\Runner\Assets.xcassets\AppIcon.appiconset\*.png"
DEL /Q "ios\Runner\Assets.xcassets\AppIcon.appiconset\*.png"
DEL /Q "web\favicon.png"
DEL /Q "windows\runner\resources\app_icon.ico"
DEL /Q "assets\appicon\*_*.png"
CD "android\app\src\main\res\"
FOR /D %%i IN (mipmap-*) DO (
    RD /S /Q "%%i"
)
FOR /D %%i IN (drawable-*) DO (
    RD /S /Q "%%i"
)
CD "..\..\..\..\..\"
CD "assets\appicon\"
magick.exe "iconbackground.png" -resize "1024x1024!" "adaptive_icon_background.png"
magick.exe "iconforeground.png" -resize "1024x1024!" "adaptive_icon_foreground.png"
magick.exe "adaptive_icon_background.png" "adaptive_icon_foreground.png" -gravity center -composite "launcher_icons.png"
magick.exe "launcher_icons.png" ( -size "1024x1024" xc:none -fill white -draw "circle 512,512 512,1" ) -compose dst-in -composite "web_round_icon.png"
CD "..\..\"
dart.bat run flutter_launcher_icons
