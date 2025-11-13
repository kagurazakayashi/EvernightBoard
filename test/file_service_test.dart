import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/home/file_service.dart';

void main() {
  // 初始化測試環境绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('檔案服務', () {
    group('刪除檔案', () {
      test('當檔名為空值時不執行任何操作', () async {
        expect(() => FileService.deleteFile(null), returnsNormally);
      });

      test('當檔名為空字串時不執行任何操作', () async {
        expect(() => FileService.deleteFile(''), returnsNormally);
      });

      test('當檔名以 assets/ 開頭時不執行任何操作', () async {
        expect(
          () => FileService.deleteFile('assets/image.png'),
          returnsNormally,
        );
      });
    });

    group('取得 Base64 圖片', () {
      test('當檔名為空值時回傳 null', () async {
        final result = await FileService.getBase64Image(null);
        expect(result, isNull);
      });

      test('當檔名為空字串時回傳 null', () async {
        final result = await FileService.getBase64Image('');
        expect(result, isNull);
      });

      test('當檔名以 assets/ 開頭時回傳 null', () async {
        final result = await FileService.getBase64Image('assets/image.png');
        expect(result, isNull);
      });
    });

    group('儲存 Base64 圖片', () {
      test('當 Base64 字串無效時回傳 null', () async {
        final result = await FileService.saveBase64Image(
          'invalid_base64!!!',
          'test.png',
        );
        expect(result, isNull);
      });
    });
  });
}
