import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// 本機檔案服務類別。
///
/// 負責處理圖片檔案於應用程式文件目錄中的保存、刪除，
/// 以及圖片檔案與 Base64 字串之間的轉換。
///
/// 注意事項：
/// - 僅處理儲存在 App 文件目錄中的檔案。
/// - 若路徑為 `assets/` 開頭，代表為應用程式內建資源，不應嘗試刪除或轉換。
class FileService {
  /// 將暫存路徑中的圖片複製到應用程式文件目錄，並回傳新檔名。
  ///
  /// [tempPath] 為來源圖片的暫存完整路徑。
  ///
  /// 執行流程：
  /// 1. 取得應用程式文件目錄。
  /// 2. 以目前時間戳建立唯一檔名，並保留原始副檔名。
  /// 3. 將暫存檔複製到正式保存位置。
  ///
  /// 成功時回傳新檔名；若來源檔不存在或發生例外，則回傳 `null`。
  static Future<String?> saveImageToDocs(String tempPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';
      final String permanentPath = p.join(directory.path, fileName);
      final File tempFile = File(tempPath);

      if (await tempFile.exists()) {
        await tempFile.copy(permanentPath);
        debugPrint('[FileService] 檔案已成功持久化至: $permanentPath');
        return fileName;
      }

      debugPrint('[FileService] 找不到暫存圖片檔案: $tempPath');
    } catch (e) {
      debugPrint('[FileService] 持久化檔案失敗: $e');
    }
    return null;
  }

  /// 安全刪除應用程式文件目錄中的指定檔案。
  ///
  /// [fileName] 應為儲存在 App 文件目錄中的檔名，而非完整路徑。
  ///
  /// 以下情況會直接略過，不執行刪除：
  /// - [fileName] 為 `null`
  /// - [fileName] 為空字串
  /// - [fileName] 以 `assets/` 開頭（代表為內建資源）
  static Future<void> deleteFile(String? fileName) async {
    if (fileName == null ||
        fileName.isEmpty ||
        fileName.startsWith('assets/')) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, fileName);
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
        debugPrint('[FileService] 已刪除本地檔案: $path');
      } else {
        debugPrint('[FileService] 欲刪除的檔案不存在，已略過: $path');
      }
    } catch (e) {
      debugPrint('[FileService] 刪除檔案失敗: $e');
    }
  }

  /// 讀取本機圖片檔案並轉換為 Base64 字串。
  ///
  /// 此方法常用於資料匯出、備份，或需以字串形式傳輸圖片內容的情境。
  ///
  /// [fileName] 應為儲存在 App 文件目錄中的檔名，而非完整路徑。
  ///
  /// 若 [fileName] 無效、為內建資源，或檔案不存在／讀取失敗，則回傳 `null`。
  static Future<String?> getBase64Image(String? fileName) async {
    if (fileName == null ||
        fileName.isEmpty ||
        fileName.startsWith('assets/')) {
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, fileName);
      final file = File(path);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }

      debugPrint('[FileService] 找不到欲轉換 Base64 的圖片檔案: $path');
    } catch (e) {
      debugPrint('[FileService] 讀取 Base64 失敗: $e');
    }
    return null;
  }

  /// 將匯入的 Base64 圖片字串還原為本機檔案，並回傳新檔名。
  ///
  /// [base64String] 為圖片的 Base64 編碼內容。
  /// [originalPath] 用於保留原始副檔名，避免遺失檔案格式資訊。
  ///
  /// 執行流程：
  /// 1. 將 Base64 字串解碼為位元組資料。
  /// 2. 取得應用程式文件目錄。
  /// 3. 依時間戳與雜湊值建立唯一檔名，降低重名風險。
  /// 4. 將圖片內容寫入本機檔案。
  ///
  /// 成功時回傳新檔名；失敗時回傳 `null`。
  static Future<String?> saveBase64Image(
    String base64String,
    String originalPath,
  ) async {
    try {
      final bytes = base64Decode(base64String);
      final directory = await getApplicationDocumentsDirectory();

      // 建立唯一檔名，並保留原始副檔名，避免匯入後遺失格式資訊。
      final String extension = p.extension(originalPath);
      final String fileName =
          'img_imp_${DateTime.now().millisecondsSinceEpoch}_${base64String.hashCode.abs()}$extension';
      final String permanentPath = p.join(directory.path, fileName);

      final file = File(permanentPath);
      await file.writeAsBytes(bytes);
      debugPrint('[FileService] 匯入圖片已儲存: $permanentPath');
      return fileName;
    } catch (e) {
      debugPrint('[FileService] 還原 Base64 圖片失敗: $e');
    }
    return null;
  }

  /// 徹底清除應用程式文件目錄下的所有檔案。
  ///
  /// 此操作不可逆，將刪除所有已保存的圖片與資料。
  static Future<void> deleteAllFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        // 取得目錄下所有檔案與子目錄
        final List<FileSystemEntity> entities = directory.listSync();
        for (var entity in entities) {
          // 避免刪除系統目錄（如 Android 的某些隱藏目錄）
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
        debugPrint('[FileService] 已清空應用程式文件目錄');
      }
    } catch (e) {
      debugPrint('[FileService] 清空文件目錄失敗: $e');
    }
  }
}
