rm -f flutter_*.log
flutter clean
rm -rf "$PWD/build"
flutter pub get
sh generate_icons.sh
dart run flutter_native_splash:create
dart run flutter_iconpicker:generate_packs --packs material
flutter gen-l10n
