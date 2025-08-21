import 'package:flutter/material.dart';

/// 觸控分區圖層元件。
///
/// 此元件會在畫面上建立兩個可點擊的透明區塊，
/// 並依照畫面方向決定排列方式：
///
/// - 直向（`isPortrait == true`）時：以上下排列
/// - 橫向（`isPortrait == false`）時：以左右排列
///
/// 常見用途是作為翻頁、上一頁 / 下一頁、圖片切換等互動區域。
class TouchLayer extends StatelessWidget {
  /// 是否為直向畫面。
  ///
  /// - `true`：使用 `Column`，按鈕以上下排列
  /// - `false`：使用 `Row`，按鈕以左右排列
  final bool isPortrait;

  /// 主題顏色。
  ///
  /// 會用來產生點擊時的水波紋顏色（`splashColor`）
  /// 與高亮顏色（`highlightColor`）。
  final Color themeColor;

  /// 點擊上一區塊時觸發的回呼函式。
  final VoidCallback onPrevious;

  /// 點擊下一區塊時觸發的回呼函式。
  final VoidCallback onNext;

  /// 建立 [TouchLayer]。
  const TouchLayer({
    super.key,
    required this.isPortrait,
    required this.themeColor,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // 依主題色建立較明顯的點擊水波紋顏色。
    final Color splash = themeColor.withValues(alpha: 0.1);

    // 依主題色建立較淡的按下高亮顏色。
    final Color highlight = themeColor.withValues(alpha: 0.05);

    // 建立單一可點擊區塊。
    //
    // 使用 Expanded 讓每個區塊平均分配剩餘空間，
    // 並透過 InkWell 提供點擊事件與觸控視覺回饋。
    Widget buildButton(VoidCallback tap) => Expanded(
      child: InkWell(
        // 使用者點擊區塊時執行對應動作。
        onTap: tap,

        // 點擊時的水波紋顏色。
        splashColor: splash,

        // 按壓時的高亮顏色。
        highlightColor: highlight,

        // 讓子元件撐滿可用空間，使整個區塊都可點擊。
        child: const SizedBox.expand(),
      ),
    );

    return Material(
      // 使用透明背景，僅保留觸控層與 InkWell 效果。
      color: Colors.transparent,

      child: isPortrait
          // 直向模式：以上下兩區排列。
          ? Column(children: [buildButton(onPrevious), buildButton(onNext)])
          // 橫向模式：以左右兩區排列。
          : Row(children: [buildButton(onPrevious), buildButton(onNext)]),
    );
  }
}
