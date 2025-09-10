import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 顯示儲存在應用程式文件目錄中的本機圖片元件。
///
/// 此元件會先從 [imagePath] 取出檔名，再到應用程式文件目錄中尋找同名檔案。
/// 若找到且檔案存在，則顯示該本機圖片；若找不到，則改為顯示 [defaultAsset]
/// 指定的預設資產圖片。
class LocalImageDisplay extends StatelessWidget {
  /// 原始圖片路徑。
  ///
  /// 傳入的值可以是任意路徑，但實際比對時只會取出檔名部分，
  /// 並與應用程式文件目錄中的檔案名稱進行組合。
  final String imagePath;

  /// 圖片在可用空間中的縮放方式。
  final BoxFit fit;

  /// 找不到本機圖片時要顯示的預設資產圖片路徑。
  final String defaultAsset; // 可指定預設圖片資產路徑

  /// 建立本機圖片顯示元件。
  ///
  /// [imagePath] 為必要參數。
  /// [fit] 預設為 [BoxFit.contain]。
  /// [defaultAsset] 預設使用 `assets/default.png`。
  const LocalImageDisplay({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.defaultAsset = 'assets/default.png', // 預設使用 assets/default.png
  });

  /// 取得實際存在於應用程式文件目錄中的圖片檔案。
  ///
  /// 流程如下：
  /// 1. 取得應用程式文件目錄。
  /// 2. 從 [imagePath] 擷取檔名。
  /// 3. 以該檔名組合出目標本機檔案路徑。
  /// 4. 若檔案存在則回傳 [File]，否則回傳 `null`。
  ///
  /// 若查找過程中發生例外，也會回傳 `null`。
  Future<File?> _getRealFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imagePath);
      final file = File(p.join(directory.path, fileName));

      // 確認目標檔案是否實際存在於本機儲存空間中。
      if (await file.exists()) {
        return file;
      }

      debugPrint('[LocalImageDisplay] 找不到本機圖片，將改用預設圖片：${file.path}');
    } catch (e) {
      debugPrint('[LocalImageDisplay] 查詢本機檔案時發生錯誤：$e');
    }

    // 檔案不存在或發生例外時，回傳 null，交由備援顯示處理。
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _getRealFile(),
      builder: (context, snapshot) {
        // 已完成讀取，且成功取得可用的本機檔案。
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            fit: fit,
            // 若圖片建立後讀取失敗（例如檔案被即時刪除或內容損壞），
            // 則改顯示備援內容，避免畫面出現空白。
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[LocalImageDisplay] 本機圖片載入失敗，改用預設圖片：$error');
              return _buildFallback();
            },
          );
        }

        // 已完成讀取，但未找到對應檔案時，顯示預設圖片。
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildFallback();
        }

        // 尚在非同步讀取磁碟檔案時，顯示載入中的指示器。
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  /// 建立找不到本機圖片時使用的備援顯示元件。
  ///
  /// 會優先顯示 [defaultAsset] 指定的資產圖片；
  /// 若連預設資產圖片也載入失敗，則顯示損毀圖片圖示。
  Widget _buildFallback() {
    return Image.asset(
      defaultAsset,
      fit: fit,
      // 若預設資產圖片本身不存在、路徑錯誤或載入失敗，
      // 則顯示通用的損毀圖片圖示作為最後備援。
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[LocalImageDisplay] 預設資產圖片載入失敗：$error');
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  }
}
