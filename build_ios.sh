rm -f flutter_*.log
sh build_pre.sh
cd ios
pod install
cd ..
rm -rf "$PWD/build/ios"
flutter build "ios" --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"
flutter build "ipa" --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"
echo "$PWD/build/ios/iphoneos/Runner.app"
open "$PWD/build/ios/iphoneos"
echo "$PWD/build/ios/archive/Runner.xcarchive"
open "$PWD/build/ios/archive"
echo "$PWD/build/ios/ipa/EvernightBoard.ipa"
open "$PWD/build/ios/ipa"
