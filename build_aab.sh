flutter clean
flutter pub get
bash generate_icons.sh
dart run flutter_native_splash:create
dart run flutter_iconpicker:generate_packs --packs material
flutter gen-l10n
rm -rf "`pwd`\build"
flutter build "aab" --no-tree-shake-icons
echo "`pwd`\build\app\outputs\bundle\release\app-release.aab"
