/// 顯示區域元件。
///
/// 此元件負責依照 [HomeItem] 的內容，決定要顯示：
/// 1. 背景圖片
/// 2. 預設圖片
/// 3. 自動縮放的置中文字
///
/// 顯示邏輯如下：
/// - 若有設定背景圖片路徑，優先顯示圖片。
/// - 若沒有背景圖片，且內容文字也為空，則顯示預設圖片。
/// - 若沒有圖片但有文字，則顯示會依容器大小自動縮放的文字。
///
/// 同時會根據 [item] 提供的顏色設定進行背景色與文字色顯示；
/// 若未提供，則回退使用目前主題的色彩設定。
import 'package:flutter/material.dart';
import '../home_model.dart';
import 'dart:io';

/// 用來顯示首頁單一項目內容的無互動展示元件。
class DisplayArea extends StatelessWidget {
  /// 要顯示的資料項目。
  final HomeItem item;

  /// 建立 [DisplayArea]。
  ///
  /// [item] 為必要參數，代表目前要渲染的首頁項目資料。
  const DisplayArea({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 取得目前系統／App 主題，作為顏色未指定時的回退來源。
    final theme = Theme.of(context);

    // 若 item 有指定背景色則使用之，否則回退到主題的 surface 顏色。
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 若 item 有指定文字色則使用之，否則回退到主題的 onSurface 顏色。
    final Color txtColor = item.textColor ?? theme.colorScheme.onSurface;

    // IgnorePointer 表示此區域僅供展示，不接收點擊或其他指標事件。
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 背景圖片路徑，可能為 null。
          final String? path = item.backgroundImagePath;

          // 顯示內容文字。
          final String content = item.content;

          // 判斷圖片路徑是否為空：
          // - null 視為空
          // - 空字串也視為空
          bool isPathEmpty = path == null || path.isEmpty;

          // 判斷內容文字是否為空字串。
          bool isContentEmpty = content.isEmpty;

          // 顯示圖片的條件：
          // 1. 有圖片時顯示圖片
          // 2. 沒有圖片且沒有文字時，顯示預設圖片
          bool shouldShowImage =
              !isPathEmpty || (isPathEmpty && isContentEmpty);

          if (shouldShowImage) {
            final String finalPath = isPathEmpty ? 'assets/default.png' : path;

            // 區分 Asset 和 File
            Widget imageWidget;
            if (finalPath.startsWith('assets/')) {
              imageWidget = Image.asset(finalPath, fit: BoxFit.contain);
            } else {
              // 使用者匯入的圖片是本地路徑，使用 Image.file
              imageWidget = Image.file(File(finalPath), fit: BoxFit.contain);
            }

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: bgColor,
              alignment: Alignment.center,
              child: imageWidget,
            );
          }

          // 建立基礎文字樣式。
          // 這裡先不直接決定最終字級，而是先以固定大字級進行量測，
          // 後續再依容器大小計算縮放比例。
          final TextStyle baseStyle = TextStyle(
            // 設定行高，避免多行文字過於鬆散。
            height: 1.1,

            // 套用最終文字顏色。
            color: txtColor,
          );

          // 使用 TextPainter 先量測文字在 fontSize = 100 時的實際尺寸。
          // 之後會根據容器可用空間計算等比縮放比例。
          final textPainter = TextPainter(
            text: TextSpan(
              text: content,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 計算寬度方向可縮放比例。
          double scaleX = constraints.maxWidth / textPainter.width;

          // 計算高度方向可縮放比例。
          double scaleY = constraints.maxHeight / textPainter.height;

          // 取較小值，確保文字可完整放入容器，不會超出邊界。
          double scale = scaleX < scaleY ? scaleX : scaleY;

          return Container(
            // 讓容器寬高填滿目前可用空間。
            width: constraints.maxWidth,
            height: constraints.maxHeight,

            // 設定背景色。
            color: bgColor,

            // 加入內距，避免文字貼齊邊界。
            padding: const EdgeInsets.all(24),

            // 將文字置中。
            alignment: Alignment.center,

            child: Text(
              content,

              // 文字本身置中對齊，適用於多行內容。
              textAlign: TextAlign.center,

              style: baseStyle.copyWith(
                // 以 100 為基準字級，再乘上縮放比例。
                // 額外乘上 0.85，保留一些安全邊界，避免在某些字型或字形下過度貼邊。
                fontSize: (100 * scale) * 0.85,
              ),
            ),
          );
        },
      ),
    );
  }
}
