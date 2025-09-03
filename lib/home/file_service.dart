import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// 本地檔案服務工具類
/// 提供圖片持久化存儲與安全刪除功能
class FileService {
  /// 將圖片從臨時路徑搬移到應用程式文件目錄
  ///
  /// [tempPath]：臨時檔案的完整路徑
  /// 回傳：若成功則回傳檔案名稱，失敗則回傳 null
  static Future<String?> saveImageToDocs(String tempPath) async {
    try {
      // 取得應用程式文件目錄
      final directory = await getApplicationDocumentsDirectory();

      // 使用當前時間戳生成唯一檔名，防止同名衝突
      final String fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';

      // 組合完整儲存路徑
      final String permanentPath = p.join(directory.path, fileName);

      final File tempFile = File(tempPath);
      if (await tempFile.exists()) {
        // 將臨時檔案複製到永久路徑
        await tempFile.copy(permanentPath);
        debugPrint('檔案已成功持久化至: $permanentPath');
        return fileName; // 僅回傳檔名，不含絕對路徑
      }
    } catch (e) {
      // 捕捉並列印錯誤
      debugPrint('持久化檔案失敗: $e');
    }
    return null;
  }

  /// 安全刪除應用程式文件目錄中的檔案
  ///
  /// [fileName]：欲刪除的檔案名稱
  /// 注意：若檔名為 null、空字串或 assets 目錄下的檔案，將不執行刪除
  static Future<void> deleteFile(String? fileName) async {
    if (fileName == null ||
        fileName.isEmpty ||
        fileName.startsWith('assets/')) {
      return;
    }

    try {
      // 取得應用程式文件目錄
      final directory = await getApplicationDocumentsDirectory();

      // 組合完整檔案路徑
      final file = File(p.join(directory.path, fileName));
      if (await file.exists()) {
        // 刪除檔案
        await file.delete();
        debugPrint('已刪除本地檔案: $fileName');
      }
    } catch (e) {
      // 捕捉並列印錯誤
      debugPrint('刪除檔案失敗: $e');
    }
  }
}
