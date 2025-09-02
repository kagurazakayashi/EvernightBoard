import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 顯示儲存在應用程式文件目錄中的本機圖片。
///
/// 會先依據 [imagePath] 取出檔名，並到應用程式文件目錄中尋找同名檔案；
/// 若檔案存在則顯示該圖片，否則改為顯示 [defaultAsset] 指定的預設資產圖片。
class LocalImageDisplay extends StatelessWidget {
  /// 原始圖片路徑。
  ///
  /// 實際使用時只會取出檔名，並到應用程式文件目錄中組合成真正的檔案路徑。
  final String imagePath;

  /// 圖片在可用空間中的縮放方式。
  final BoxFit fit;

  /// 找不到本機圖片時要顯示的預設資產圖片路徑。
  final String defaultAsset; // 可指定預設圖片資產路徑

  /// 建立本機圖片顯示元件。
  const LocalImageDisplay({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.defaultAsset = 'assets/default.png', // 預設使用 assets/default.png
  });

  /// 取得實際存在於應用程式文件目錄中的圖片檔案。
  ///
  /// 若檔案存在則回傳 [File]；若不存在或查找過程發生錯誤，則回傳 `null`。
  Future<File?> _getRealFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(imagePath);
      final file = File(p.join(directory.path, fileName));

      // 確認目標檔案是否實際存在於本機儲存空間中
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('查找本地文件出错: $e');
    }
    return null; // 檔案不存在或發生例外時，回傳 null
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _getRealFile(),
      builder: (context, snapshot) {
        // 已完成讀取，且成功取得可用的本機檔案
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            fit: fit,
            // 若圖片建立後讀取失敗（例如檔案被即時刪除），則改顯示備援內容
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        }

        // 已完成讀取，但未找到對應檔案時，顯示預設圖片
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildFallback();
        }

        // 尚在非同步讀取磁碟檔案時，顯示載入中的指示器
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  /// 建立找不到本機圖片時使用的備援顯示元件。
  Widget _buildFallback() {
    return Image.asset(
      defaultAsset,
      fit: fit,
      // 若連預設資產圖片也載入失敗，則顯示損毀圖片圖示
      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50),
    );
  }
}
