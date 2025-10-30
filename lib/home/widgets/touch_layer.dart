import 'package:flutter/material.dart';
import 'package:evernight_board/global.dart';

/// 觸控分區圖層元件。
///
/// 此元件會在畫面上建立兩個可點擊的透明區塊，
/// 並依照畫面方向決定排列方式：
///
/// - 直向（`isPortrait == true`）時：以上下排列
/// - 橫向（`isPortrait == false`）時：以左右排列
///
/// 常見用途包含：
///
/// - 閱讀器上一頁 / 下一頁
/// - 圖片瀏覽切換
/// - 全螢幕模式下的左右或上下分區操作
///
/// 元件本身不負責顯示任何內容，僅提供透明的觸控區域
/// 與按壓時的視覺回饋效果。
class TouchLayer extends StatelessWidget {
  /// 是否為直向畫面。
  ///
  /// - `true`：使用 [Column]，將兩個觸控區塊以上下方式排列
  /// - `false`：使用 [Row]，將兩個觸控區塊以左右方式排列
  final bool isPortrait;

  /// 主題顏色。
  ///
  /// 此顏色會用來衍生點擊時的水波紋顏色（`splashColor`）
  /// 與按壓高亮顏色（`highlightColor`），
  /// 讓透明觸控層仍保有一致的互動視覺風格。
  final Color themeColor;

  /// 點擊前一個區塊時觸發的回呼函式。
  ///
  /// 在直向模式下通常代表「上方區塊」，
  /// 在橫向模式下通常代表「左側區塊」。
  ///
  /// 若為 `null`，該區塊仍會保留版面空間，
  /// 但不會觸發點擊事件，也不會顯示互動效果。
  final VoidCallback? onPrevious;

  /// 點擊下一個區塊時觸發的回呼函式。
  ///
  /// 在直向模式下通常代表「下方區塊」，
  /// 在橫向模式下通常代表「右側區塊」。
  ///
  /// 若為 `null`，該區塊仍會保留版面空間，
  /// 但不會觸發點擊事件，也不會顯示互動效果。
  final VoidCallback? onNext;

  /// 建立 [TouchLayer]。
  const TouchLayer({
    super.key,
    required this.isPortrait,
    required this.themeColor,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // 依據主題色建立較明顯的點擊水波紋顏色。
    final Color splash = themeColor.withValues(alpha: 0.1);

    // 依據主題色建立較淡的按壓高亮顏色。
    final Color highlight = themeColor.withValues(alpha: 0.05);

    /// 建立單一可點擊區塊。
    ///
    /// 透過 [Expanded] 讓兩個區塊平均分配可用空間，
    /// 並使用 [InkWell] 提供點擊事件與觸控回饋。
    ///
    /// [tap] 為 `null` 時：
    /// - 該區塊不會回應點擊
    /// - 不顯示 splash / highlight 效果
    Widget buildButton(VoidCallback? tap, {required String areaName}) =>
        Expanded(
          child: Semantics(
            label: areaName,
            child: InkWell(
              // 直接以 null 控制 InkWell 是否啟用，
              // 可避免建立不必要的空回呼，也能讓互動語意更清楚。
              onTap: tap == null
                  ? null
                  : () {
                      debugPrint('[TouchLayer] 點擊$areaName區塊');
                      tap();
                    },
              // 只有在可點擊時才顯示水波紋效果。
              splashColor: tap == null ? Colors.transparent : splash,
              // 只有在可點擊時才顯示按壓高亮效果。
              highlightColor: tap == null ? Colors.transparent : highlight,
              // 滑鼠懸停時不額外顯示顏色，維持透明觸控層設計。
              hoverColor: Colors.transparent,
              // 讓子元件撐滿可用空間，使整個分區都可作為點擊範圍。
              child: const SizedBox.expand(),
            ),
          ),
        );

    return Material(
      // 使用透明背景，僅承載觸控區與 InkWell 的互動效果。
      color: Colors.transparent,
      child: isPortrait
          // 直向模式：以上下兩區排列。
           ? Column(
              children: [
                buildButton(onPrevious, areaName: t.semanticsPreviousPage),
                buildButton(onNext, areaName: t.semanticsNextPage),
              ],
            )
          // 橫向模式：以左右兩區排列。
           : Row(
              children: [
                buildButton(onPrevious, areaName: t.semanticsPreviousPage),
                buildButton(onNext, areaName: t.semanticsNextPage),
              ],
            ),
    );
  }
}
