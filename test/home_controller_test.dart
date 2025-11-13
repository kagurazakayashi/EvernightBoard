import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/home/home_controller.dart';
import 'package:evernight_board/home/home_model.dart';

void main() {
  // 初始化測試環境绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('首页控制器', () {
    // 使用清單集中管理控制器實體
    final List<HomeController> controllers = [];

    // 所有測試結束後釋放資源
    tearDownAll(() {
      for (final c in controllers) {
        try {
          c.dispose();
        } catch (_) {}
      }
    });

    // 輔助方法：建立控制器並加入管理清單
    HomeController createController() {
      final c = HomeController();
      controllers.add(c);
      return c;
    }

    group('項目切換', () {
      // 測試下一項目循環切換
      test('下一項目循環切換', () {
        final controller = createController();
        controller.items.addAll([
          HomeItem(title: '項目一', content: '', icon: Icons.home),
          HomeItem(title: '項目二', content: '', icon: Icons.star),
          HomeItem(title: '項目三', content: '', icon: Icons.favorite),
        ]);

        controller.changeIndex(0);
        expect(controller.currentIndex, 0);

        controller.nextItem();
        expect(controller.currentIndex, 1);

        controller.nextItem();
        expect(controller.currentIndex, 2);

        controller.nextItem();
        expect(controller.currentIndex, 0);
      });

      // 測試上一項目反向循環切換
      test('上一項目反向循環切換', () {
        final controller = createController();
        controller.items.addAll([
          HomeItem(title: '項目一', content: '', icon: Icons.home),
          HomeItem(title: '項目二', content: '', icon: Icons.star),
          HomeItem(title: '項目三', content: '', icon: Icons.favorite),
        ]);

        controller.changeIndex(0);
        controller.previousItem();
        expect(controller.currentIndex, 2);

        controller.previousItem();
        expect(controller.currentIndex, 1);

        controller.previousItem();
        expect(controller.currentIndex, 0);
      });
    });

    group('直接切換索引', () {
      late HomeController controller;
      setUp(() {
        controller = createController();
        controller.items.addAll([
          HomeItem(title: '項目一', content: '', icon: Icons.home),
          HomeItem(title: '項目二', content: '', icon: Icons.star),
          HomeItem(title: '項目三', content: '', icon: Icons.favorite),
        ]);
      });

      // 測試切換到有效索引
      test('可切換到有效索引', () {
        controller.changeIndex(2);
        expect(controller.currentIndex, 2);
      });

      // 測試忽略無效索引
      test('忽略無效索引', () {
        controller.changeIndex(-1);
        expect(controller.currentIndex, 0);
        controller.changeIndex(10);
        expect(controller.currentIndex, 0);
      });
    });

    group('監聽器通知', () {
      // 測試下一項目會通知監聽器
      test('下一項目會通知監聽器', () {
        final controller = createController();
        controller.items.addAll([
          HomeItem(title: '項目一', content: '', icon: Icons.home),
          HomeItem(title: '項目二', content: '', icon: Icons.star),
        ]);

        var notified = false;
        controller.addListener(() => notified = true);
        controller.nextItem();
        expect(notified, isTrue);
      });

      // 測試索引相同時不通知監聽器
      test('索引相同時不通知監聽器', () {
        final controller = createController();
        controller.items.add(
          HomeItem(title: '項目', content: '', icon: Icons.home),
        );

        var notified = false;
        controller.addListener(() => notified = true);
        controller.changeIndex(0);
        expect(notified, isFalse);
      });
    });

    group('語系設定', () {
      // 測試切換語系
      test('切換語系更新 appLocale', () {
        final controller = createController();
        controller.changeLocale(const Locale('en'));
        expect(controller.appLocale?.languageCode, 'en');

        controller.changeLocale(null);
        expect(controller.appLocale, isNull);
      });

      // 測試切換語系會通知監聽器
      test('切換語系會通知監聽器', () {
        final controller = createController();
        var notified = false;
        controller.addListener(() => notified = true);
        controller.changeLocale(const Locale('ja'));
        expect(notified, isTrue);
      });
    });

    group('功能設定', () {
      // 測試側邊點擊翻頁切換
      test('側邊點擊翻頁切換', () {
        final controller = createController();
        controller.toggleSideTap(false);
        expect(controller.useSideTap, isFalse);
        controller.toggleSideTap(true);
        expect(controller.useSideTap, isTrue);
      });

      // 測試橫向導覽列位置設定
      test('橫向導覽列位置設定', () {
        final controller = createController();
        controller.setLandscapeNavPosition(LandscapeNavPosition.left);
        expect(controller.landscapeNavPosition, LandscapeNavPosition.left);
      });

      // 測試直向導覽列位置設定
      test('直向導覽列位置設定', () {
        final controller = createController();
        controller.setPortraitNavPosition(PortraitNavPosition.bottom);
        expect(controller.portraitNavPosition, PortraitNavPosition.bottom);
      });
    });

    group('顏色工具方法', () {
      late HomeController controller;
      setUp(() => controller = createController());

      // 測試空值顏色比較
      test('空值顏色比較回傳 false', () {
        expect(controller.isTooSimilar(null, Colors.red), isFalse);
        expect(controller.isTooSimilar(Colors.red, null), isFalse);
      });

      // 測試相同顏色相似度
      test('相同顏色回傳 true', () {
        expect(controller.isTooSimilar(Colors.red, Colors.red), isTrue);
      });

      // 測試對比顏色相似度
      test('對比顏色回傳 false', () {
        expect(controller.isTooSimilar(Colors.black, Colors.white), isFalse);
      });

      // 測試顏色反轉
      test('顏色反轉 RGB 通道', () {
        final color = const Color.fromARGB(255, 100, 150, 200);
        final inverted = controller.invertColor(color);
        expect(inverted.a, color.a);
        expect((inverted.r * 255).round(), 155);
      });

      // 測試顏色相同比較
      test('比較 ARGB 值判斷顏色是否相同', () {
        expect(
          controller.isSameColor(
            const Color(0xFFFF0000),
            const Color(0xFFFF0000),
          ),
          isTrue,
        );
        expect(
          controller.isSameColor(
            const Color(0xFFFF0000),
            const Color(0xFF00FF00),
          ),
          isFalse,
        );
      });
    });
  });
}
