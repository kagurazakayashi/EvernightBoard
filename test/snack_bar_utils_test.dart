import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/home/widgets/snack_bar_utils.dart';

void main() {
  group('提示訊息工具', () {
    // 測試成功提示訊息顯示
    testWidgets('顯示成功提示訊息', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarUtils.show(context, '操作成功');
                  },
                  child: const Text('顯示提示'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('顯示提示'));
      await tester.pump();

      expect(find.text('操作成功'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    // 測試錯誤提示訊息顯示
    testWidgets('顯示錯誤提示訊息', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarUtils.show(context, '操作失敗', isError: true);
                  },
                  child: const Text('顯示提示'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('顯示提示'));
      await tester.pump();

      expect(find.text('操作失敗'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    // 測試清除舊提示訊息後顯示新提示
    testWidgets('清除舊提示後顯示新提示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        SnackBarUtils.show(context, '第一則訊息');
                      },
                      child: const Text('顯示第一則'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        SnackBarUtils.show(context, '第二則訊息');
                      },
                      child: const Text('顯示第二則'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('顯示第一則'));
      await tester.pump();

      expect(find.text('第一則訊息'), findsOneWidget);

      await tester.tap(find.text('顯示第二則'));
      await tester.pump();

      expect(find.text('第一則訊息'), findsNothing);
      expect(find.text('第二則訊息'), findsOneWidget);
    });
  });
}
