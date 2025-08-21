/// 顯示區元件。
///
/// 功能說明：
/// - 若 `item.backgroundImagePath` 有有效圖片路徑，則優先顯示圖片。
/// - 若圖片路徑為空字串，且 `content` 也為空，則顯示預設圖片。
/// - 否則顯示文字內容，並依可用空間自動縮放字體大小。
///
/// 設計重點：
/// - 使用 `LayoutBuilder` 取得目前可用的寬高限制。
/// - 透過 `TextPainter` 預先量測文字大小，計算最合適的縮放比例。
/// - 使用 `IgnorePointer` 讓此顯示區不攔截任何觸控事件。
library;

import 'package:flutter/material.dart';
import '../home_model.dart';

/// 用來顯示首頁項目內容的區域元件。
///
/// 依據 `HomeItem` 的資料內容，決定要顯示背景圖片或文字。
class DisplayArea extends StatelessWidget {
  /// 要顯示的首頁資料項目。
  final HomeItem item;

  /// 建構子。
  ///
  /// [item] 為必要參數，代表目前要渲染的資料內容。
  const DisplayArea({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // IgnorePointer：讓此區塊只負責顯示，不處理任何點擊或手勢事件。
    return IgnorePointer(
      child: LayoutBuilder(
        // LayoutBuilder 可取得父層提供的實際尺寸限制，方便做自適應排版。
        builder: (context, constraints) {
          // 讀取背景圖片路徑，可能為 null。
          final String? path = item.backgroundImagePath;

          // 讀取要顯示的文字內容。
          final String content = item.content;

          // 判斷是否應該顯示圖片：
          // 1. path 不為 null 且不為空字串時，顯示指定圖片。
          // 2. path 為空字串且 content 為空時，顯示預設圖片。
          bool shouldShowImage =
              (path != null && path.isNotEmpty) ||
              (path == '' && content.isEmpty);

          if (shouldShowImage) {
            // 若 path 為 null 或空字串，改用預設圖片。
            final String finalPath = (path == null || path.isEmpty)
                ? 'assets/default.png'
                : path;

            return Container(
              // 撐滿目前版面可用寬度。
              width: constraints.maxWidth,

              // 撐滿目前版面可用高度。
              height: constraints.maxHeight,

              // 內容置中。
              alignment: Alignment.center,

              // 顯示資產圖片，並以 contain 方式完整縮放進容器中。
              child: Image.asset(finalPath, fit: BoxFit.contain),
            );
          }

          // 建立文字的基礎樣式。
          // 後續會在此基礎上動態調整字體大小。
          final TextStyle baseStyle = TextStyle(
            // 控制行高，讓文字上下更緊湊。
            height: 1.1,

            // 文字顏色由 item 提供。
            color: item.textColor,
          );

          // 使用 TextPainter 預先量測文字在字體大小 100 時的實際寬高。
          // 這樣可以依容器大小動態計算最適合的縮放比例。
          final tp = TextPainter(
            text: TextSpan(
              text: content,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 依照寬度與高度限制，取較小的縮放比例，
          // 確保文字不會超出可用顯示區域。
          double scale =
              (constraints.maxWidth / tp.width) <
                  (constraints.maxHeight / tp.height)
              ? (constraints.maxWidth / tp.width)
              : (constraints.maxHeight / tp.height);

          return Center(
            child: Text(
              // 顯示文字內容。
              content,

              // 文字置中對齊。
              textAlign: TextAlign.center,

              // 以基礎樣式為基準，套用計算後的字體大小。
              // 額外乘上 0.85，保留一些安全邊界，避免文字太貼近容器邊緣。
              style: baseStyle.copyWith(fontSize: (100 * scale) * 0.85),
            ),
          );
        },
      ),
    );
  }
}
