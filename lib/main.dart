import 'package:flutter/material.dart';

/// 應用程式進入點。
///
/// 透過 [runApp] 啟動 Flutter 應用，並載入根元件 [MyApp]。
void main() => runApp(const MyApp());

/// 應用程式根元件。
///
/// 負責建立最外層的 [MaterialApp]，並將首頁設定為顯示
/// [FullScreenText] 的畫面。
class MyApp extends StatelessWidget {
  /// 建立 [MyApp]。
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 建立 Material Design 應用，首頁直接顯示全螢幕文字元件。
    return const MaterialApp(home: Scaffold(body: FullScreenText()));
  }
}

/// 全螢幕自適應文字顯示元件。
///
/// 此元件會根據可用畫面尺寸，自動計算文字縮放比例，
/// 讓多行文字在不超出螢幕範圍的前提下，盡可能放大並置中顯示。
class FullScreenText extends StatelessWidget {
  /// 建立 [FullScreenText]。
  const FullScreenText({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Scaffold 提供基本頁面結構。
    return Scaffold(
      body: LayoutBuilder(
        // 透過 LayoutBuilder 取得目前可用的版面尺寸限制。
        builder: (context, constraints) {
          // 要顯示的多行文字內容。
          const String text = "神楽坂雅詩\nかぐらざか みやび\nKagurazakaMiyabi";

          // 定義文字的基礎樣式，後續會在此基礎上調整字體大小與顏色。
          const TextStyle baseStyle = TextStyle(
            fontWeight: FontWeight.bold,
            height: 1.1,
          );

          // 使用 TextPainter 先以基準字級量測文字實際繪製後的寬高。
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 取得基準字級下的文字寬度。
          double textWidth = textPainter.width;

          // 取得基準字級下的文字高度。
          double textHeight = textPainter.height;

          // 計算在目前容器寬度下，可水平放大的比例。
          double scaleX = constraints.maxWidth / textWidth;

          // 計算在目前容器高度下，可垂直放大的比例。
          double scaleY = constraints.maxHeight / textHeight;

          // 取寬高縮放比例中較小者，確保文字完整顯示且不會溢出。
          double scale = scaleX < scaleY ? scaleX : scaleY;

          // 以基準字級 100 為基礎，套用縮放比例後再保留一些邊界空間。
          double finalFontSize = (100 * scale) * 0.8;

          // 建立全螢幕容器，將文字置中顯示。
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            alignment: Alignment.center,
            color: Colors.blueGrey[900],
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: baseStyle.copyWith(
                fontSize: finalFontSize,
                color: Colors.redAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
