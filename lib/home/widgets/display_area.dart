import 'package:flutter/material.dart';
import '../home_model.dart';
import 'local_image_display.dart';
import 'auto_scale_text.dart';

/// 顯示首頁項目內容的區域元件。
///
/// 此元件會依據 [item] 的設定，自動決定要顯示文字內容、
/// 本機圖片，或預設圖片。
class DisplayArea extends StatelessWidget {
  /// 要顯示的首頁項目資料。
  final HomeItem item;

  /// 建立顯示區域元件。
  const DisplayArea({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;
    final Color txtColor = item.textColor ?? theme.colorScheme.onSurface;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final String? path = item.backgroundImagePath;
          final String content = item.content;

          // 判斷背景圖片路徑是否為空值或空字串。
          final bool isPathEmpty = path == null || path.isEmpty;

          // 判斷文字內容是否為空字串。
          final bool isContentEmpty = content.isEmpty;

          // 顯示規則：
          // 1. 只要有圖片路徑，就優先顯示圖片。
          // 2. 若沒有圖片路徑，且文字內容也為空，則顯示預設圖片。
          final bool shouldShowImage = !isPathEmpty || isContentEmpty;

          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: bgColor,
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: shouldShowImage
                ? _buildImageContent(path)
                : AutoScaleText(
                    text: content,
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
  Widget _buildImageContent(String? path) {
    const String defaultAsset = 'assets/default.png';

    // 若路徑明確指向 app 內建資源，或路徑為空，
    // 則直接載入資源圖片；空路徑時改用預設圖片。
    if (path == null || path.isEmpty || path.startsWith('assets/')) {
      return Image.asset(
        (path == null || path.isEmpty) ? defaultAsset : path,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50),
      );
    }

    // 若為使用者選取的本機圖片，交由 LocalImageDisplay 處理。
    // 該元件內部已實作檔案不存在時回退為預設圖片的機制。
    return LocalImageDisplay(imagePath: path, defaultAsset: defaultAsset);
  }
}
