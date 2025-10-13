import 'package:evernight_board/global.dart';
import 'package:flutter/material.dart';
import '../home_model.dart';
import 'local_image_display.dart';
import 'auto_scale_text.dart';

/// 顯示首頁項目內容的區域元件。
///
/// 此元件會依據 [item] 內的資料，自動決定目前區塊應顯示：
///
/// 1. 使用者或系統指定的背景圖片。
/// 2. 預設圖片。
/// 3. 純文字內容。
///
/// 顯示優先順序如下：
///
/// - 只要有可用的圖片路徑，就優先顯示圖片。
/// - 若沒有圖片路徑，且文字內容為空，則顯示預設圖片。
/// - 僅在「沒有圖片路徑」且「有文字內容」時，才顯示文字。
///
/// 此元件包在 [IgnorePointer] 中，表示其內容僅供顯示，
/// 不接收任何點擊、拖曳等互動事件。
class DisplayArea extends StatelessWidget {
  /// 要顯示的首頁項目資料。
  final HomeItem item;

  /// 建立顯示區域元件。
  const DisplayArea({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 若資料未指定背景色，則退回主題中的 surface 色彩。
    // final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 若資料未指定文字色，則退回主題中的 onSurface 色彩，
    // 以維持基本可讀性與主題一致性。
    final Color txtColor = item.textColor ?? theme.colorScheme.onSurface;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 背景圖片路徑，可能為：
          // 1. null
          // 2. 空字串
          // 3. assets/... 的內建資源路徑
          // 4. 使用者裝置上的本機檔案路徑
          final String? path = item.backgroundImagePath;

          // 判斷背景圖片路徑是否為空值或空字串。
          final bool isPathEmpty = path == null || path.isEmpty;

          // 分別處理內容文字
          final String displayContent = item.content.isEmpty
              ? t.newitemtext
              : item.content;

          // 修改顯示規則：
          // 1. 只要有圖片路徑，就優先顯示圖片。
          // 2. 如果沒有圖片路徑，則顯示文字（此時文字可能是使用者輸入的，也可能是預設的 t.newitemtext）。
          final bool shouldShowImage = !isPathEmpty;

          return Container(
            // ... (寬度、高度、背景色設定保持不變)
            child: shouldShowImage
                ? _buildImageContent(path)
                : AutoScaleText(
                    text: displayContent, // 使用處理後的內容
                    baseStyle: TextStyle(height: 1.1, color: txtColor),
                    constraints: constraints,
                  ),
          );
        },
      ),
    );
  }

  /// 建立圖片顯示內容。
  ///
  /// 當 [path] 為 `null`、空字串，或為 `assets/` 開頭的資源路徑時，
  /// 直接使用 [Image.asset] 載入。
  ///
  /// 若 [path] 為使用者選擇的本機檔案路徑，則交由 [LocalImageDisplay]
  /// 處理，並在檔案不存在時自動回退至預設圖片。
  ///
  /// 預設圖片固定使用 `assets/default.png`。
  Widget _buildImageContent(String? path) {
    const String defaultAsset = 'assets/default.png';

    // 若路徑明確指向 app 內建資源，或路徑為空，
    // 則直接載入資源圖片；空路徑時改用預設圖片。
    if (path == null || path.isEmpty || path.startsWith('assets/')) {
      final String assetPath = (path == null || path.isEmpty)
          ? defaultAsset
          : path;

      // 記錄目前實際要載入的資源圖片路徑，方便確認是否正確回退到預設圖。
      debugPrint('[DisplayArea] 載入資源圖片：$assetPath');

      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) {
          // 當資源圖片載入失敗時，輸出錯誤資訊以利追查。
          debugPrint('[DisplayArea] 資源圖片載入失敗：$assetPath, error=$e');
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    // 若為使用者選取的本機圖片，交由 LocalImageDisplay 處理。
    // 該元件內部已實作檔案不存在時回退為預設圖片的機制。
    debugPrint('[DisplayArea] 載入本機圖片：$path');
    return LocalImageDisplay(imagePath: path, defaultAsset: defaultAsset);
  }
}
