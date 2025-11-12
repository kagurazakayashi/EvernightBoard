import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evernight_board/home/home_model.dart';

void main() {
  group('首页項目模型', () {
    // 驗證建構函式能正確建立實體
    test('使用必要欄位建立實體', () {
      final item = HomeItem(
        title: '測試標題',
        content: '測試內容',
        icon: Icons.home,
      );

      expect(item.title, '測試標題');
      expect(item.content, '測試內容');
      expect(item.icon, Icons.home);
      expect(item.textColor, isNull);
      expect(item.backgroundColor, isNull);
      expect(item.backgroundImagePath, isNull);
    });

    // 驗證可選欄位能正常設定
    test('使用可選欄位建立實體', () {
      final item = HomeItem(
        title: '測試',
        content: '內容',
        icon: Icons.star,
        textColor: Colors.red,
        backgroundColor: Colors.blue,
        backgroundImagePath: 'path/to/image.png',
      );

      expect(item.textColor, Colors.red);
      expect(item.backgroundColor, Colors.blue);
      expect(item.backgroundImagePath, 'path/to/image.png');
    });

    group('轉換為 JSON', () {
      // 測試所有欄位轉換
      test('包含所有欄位轉換為 JSON', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          textColor: Colors.red,
          backgroundColor: Colors.blue,
          backgroundImagePath: 'image.png',
        );

        final json = item.toJson();

        expect(json['title'], '標題');
        expect(json['content'], '內容');
        expect(json['icon'], Icons.home.codePoint);
        expect(json['textColor'], Colors.red.toARGB32());
        expect(json['backgroundColor'], Colors.blue.toARGB32());
        expect(json['imagePath'], 'image.png');
      });

      // 測試空值欄位處理
      test('可選欄位為空值時轉換為 JSON', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
        );

        final json = item.toJson();

        expect(json['title'], '標題');
        expect(json['content'], '內容');
        expect(json['icon'], Icons.home.codePoint);
        expect(json['textColor'], isNull);
        expect(json['backgroundColor'], isNull);
        expect(json['imagePath'], isNull);
      });
    });

    group('從 JSON 建立', () {
      // 測試有效 JSON 轉換
      test('從有效 JSON 建立實體', () {
        final json = {
          'title': '標題',
          'content': '內容',
          'icon': Icons.home.codePoint,
          'textColor': Colors.red.toARGB32(),
          'backgroundColor': Colors.blue.toARGB32(),
          'imagePath': 'image.png',
        };

        final item = HomeItem.fromJson(json);

        expect(item.title, '標題');
        expect(item.content, '內容');
        expect(item.icon.codePoint, Icons.home.codePoint);
        expect(item.textColor?.toARGB32(), Colors.red.toARGB32());
        expect(item.backgroundColor?.toARGB32(), Colors.blue.toARGB32());
        expect(item.backgroundImagePath, 'image.png');
      });

      // 測試缺少欄位時使用預設值
      test('缺少欄位時使用預設值', () {
        final json = <String, dynamic>{};

        final item = HomeItem.fromJson(json);

        expect(item.title, '');
        expect(item.content, '');
        expect(item.icon.codePoint, Icons.help_outline.codePoint);
        expect(item.textColor, isNull);
        expect(item.backgroundColor, isNull);
        expect(item.backgroundImagePath, '');
      });

      // 測試空值顏色欄位處理
      test('顏色欄位為空值時正常處理', () {
        final json = {
          'title': '標題',
          'content': '內容',
          'icon': Icons.star.codePoint,
          'textColor': null,
          'backgroundColor': null,
        };

        final item = HomeItem.fromJson(json);

        expect(item.textColor, isNull);
        expect(item.backgroundColor, isNull);
      });
    });

    group('JSON 序列化往返測試', () {
      // 測試序列化後資料完整性
      test('序列化往返後保留所有資料', () {
        final original = HomeItem(
          title: '測試標題',
          content: '測試內容',
          icon: Icons.favorite,
          textColor: Colors.green,
          backgroundColor: Colors.yellow,
          backgroundImagePath: 'test.png',
        );

        final json = original.toJson();
        final restored = HomeItem.fromJson(json);

        expect(restored.title, original.title);
        expect(restored.content, original.content);
        expect(restored.icon.codePoint, original.icon.codePoint);
        expect(restored.textColor?.toARGB32(), original.textColor?.toARGB32());
        expect(restored.backgroundColor?.toARGB32(), original.backgroundColor?.toARGB32());
        expect(restored.backgroundImagePath, original.backgroundImagePath);
      });
    });

    group('複製並更新', () {
      // 測試不提供參數時回傳相同物件
      test('不提供參數時回傳相同物件', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          textColor: Colors.red,
          backgroundColor: Colors.blue,
          backgroundImagePath: 'image.png',
        );

        final copy = item.copyWith();

        expect(copy.title, item.title);
        expect(copy.content, item.content);
        expect(copy.icon, item.icon);
        expect(copy.textColor, item.textColor);
        expect(copy.backgroundColor, item.backgroundColor);
        expect(copy.backgroundImagePath, item.backgroundImagePath);
      });

      // 測試更新標題
      test('提供新標題時更新標題', () {
        final item = HomeItem(
          title: '舊標題',
          content: '內容',
          icon: Icons.home,
        );

        final copy = item.copyWith(title: '新標題');

        expect(copy.title, '新標題');
        expect(copy.content, item.content);
      });

      // 測試更新內容
      test('提供新內容時更新內容', () {
        final item = HomeItem(
          title: '標題',
          content: '舊內容',
          icon: Icons.home,
        );

        final copy = item.copyWith(content: '新內容');

        expect(copy.content, '新內容');
      });

      // 測試更新圖示
      test('提供新圖示時更新圖示', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
        );

        final copy = item.copyWith(icon: Icons.star);

        expect(copy.icon, Icons.star);
      });

      // 測試清除文字顏色
      test('clearTextColor 為 true 時清除文字顏色', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          textColor: Colors.red,
        );

        final copy = item.copyWith(clearTextColor: true);

        expect(copy.textColor, isNull);
      });

      // 測試清除背景顏色
      test('clearBgColor 為 true 時清除背景顏色', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          backgroundColor: Colors.blue,
        );

        final copy = item.copyWith(clearBgColor: true);

        expect(copy.backgroundColor, isNull);
      });

      // 測試更新文字顏色
      test('提供新文字顏色時更新顏色', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          textColor: Colors.red,
        );

        final copy = item.copyWith(textColor: Colors.green);

        expect(copy.textColor, Colors.green);
      });

      // 測試同時更新所有欄位
      test('同時更新所有欄位', () {
        final item = HomeItem(
          title: '標題',
          content: '內容',
          icon: Icons.home,
          textColor: Colors.red,
          backgroundColor: Colors.blue,
          backgroundImagePath: 'old.png',
        );

        final copy = item.copyWith(
          title: '新標題',
          content: '新內容',
          icon: Icons.star,
          textColor: Colors.green,
          backgroundColor: Colors.yellow,
          backgroundImagePath: 'new.png',
        );

        expect(copy.title, '新標題');
        expect(copy.content, '新內容');
        expect(copy.icon, Icons.star);
        expect(copy.textColor, Colors.green);
        expect(copy.backgroundColor, Colors.yellow);
        expect(copy.backgroundImagePath, 'new.png');
      });
    });
  });
}
