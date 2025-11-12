import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/restart_widget.dart';

void main() {
  group('重啟元件', () {
    // 測試子元件能正常渲染
    testWidgets('成功渲染子元件', (tester) async {
      await tester.pumpWidget(
        const RestartWidget(
          child: MaterialApp(
            home: Text('測試子元件'),
          ),
        ),
      );

      expect(find.text('測試子元件'), findsOneWidget);
    });

    // 測試重啟功能會重建元件樹
    testWidgets('重啟功能會重建元件樹', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        RestartWidget(
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                buildCount++;
                return Text('重建次數：$buildCount');
              },
            ),
          ),
        ),
      );

      expect(find.text('重建次數：1'), findsOneWidget);

      RestartWidget.restartApp(tester.element(find.byType(Text)));
      await tester.pump();

      expect(find.text('重建次數：2'), findsOneWidget);
    });

    // 測試找不到狀態時不拋出例外
    testWidgets('找不到狀態時不執行任何操作', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('無重啟元件'),
        ),
      );

      expect(() {
        RestartWidget.restartApp(tester.element(find.text('無重啟元件')));
      }, returnsNormally);
    });
  });
}
