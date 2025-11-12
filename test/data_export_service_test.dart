import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/settings/data_export_service.dart';

void main() {
  // 初始化測試環境绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('資料匯出服務', () {
    test('服務類別可正常引用', () {
      expect(DataExportService, isNotNull);
    });
  });
}
