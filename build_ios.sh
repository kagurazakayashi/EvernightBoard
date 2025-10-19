flutter clean
flutter pub get
cd ios
pod install
cd ..
bash generate_icons.sh
dart run flutter_native_splash:create
dart run flutter_iconpicker:generate_packs --packs material
flutter gen-l10n
rm -rf "`pwd`/build/ios"
flutter build "ios" --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"
flutter build "ipa" --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"
echo "`pwd`/build/ios/iphoneos/Runner.app"
open "`pwd`/build/ios/iphoneos"
echo "`pwd`/build/ios/archive/Runner.xcarchive"
open "`pwd`/build/ios/archive"
echo "`pwd`/build/ios/ipa/EvernightBoard.ipa"
open "`pwd`/build/ios/ipa"
