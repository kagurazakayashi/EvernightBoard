import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// 本地檔案服務工具類別。
///
/// 負責處理應用程式文件目錄中的圖片檔案保存與刪除流程，
/// 主要用途包含：
/// 1. 將暫存圖片複製到可長期保存的文件目錄。
/// 2. 依檔名刪除先前已保存的本地檔案。
///
/// 此類別僅提供靜態方法，不需要建立實例。
class FileService {
  /// 將圖片從暫存路徑複製到應用程式文件目錄中。
  ///
  /// 會使用目前時間戳記搭配原始副檔名產生唯一檔名，
  /// 以避免同名檔案互相覆蓋。
  ///
  /// [tempPath] 為暫存檔案的完整路徑。
  ///
  /// 成功時回傳新檔名（不含完整路徑）；
  /// 若來源檔案不存在或處理失敗，則回傳 `null`。
  static Future<String?> saveImageToDocs(String tempPath) async {
    try {
      // 取得應用程式可持久化保存檔案的文件目錄。
      final directory = await getApplicationDocumentsDirectory();

      // 以時間戳記建立唯一檔名，並保留原始副檔名。
      final String fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';

      // 組合目標檔案的完整保存路徑。
      final String permanentPath = p.join(directory.path, fileName);

      final File tempFile = File(tempPath);

      // 僅在來源暫存檔確實存在時才執行複製。
      if (await tempFile.exists()) {
        // 將暫存檔複製到應用程式文件目錄，作為長期保存版本。
        await tempFile.copy(permanentPath);
        debugPrint('[FileService] 檔案已成功持久化至: $permanentPath');

        // 僅回傳檔名，讓呼叫端可自行決定後續如何組合完整路徑。
        return fileName;
      }

      // 來源檔案不存在時輸出除錯資訊，協助追查來源路徑異常問題。
      debugPrint('[FileService] 找不到暫存檔案: $tempPath');
    } catch (e) {
      // 捕捉保存過程中的例外，避免中斷呼叫端流程。
      debugPrint('[FileService] 持久化檔案失敗: $e');
    }

    return null;
  }

  /// 安全刪除應用程式文件目錄中的指定檔案。
  ///
  /// [fileName] 應為先前保存後取得的檔名，而非完整路徑。
  ///
  /// 以下情況會直接略過，不執行刪除：
  /// 1. [fileName] 為 `null`
  /// 2. [fileName] 為空字串
  /// 3. [fileName] 指向 `assets/` 目錄資源
  ///
  /// 這樣可避免誤刪應用程式內建資源，並降低無效路徑操作。
  static Future<void> deleteFile(String? fileName) async {
    // 避免刪除空值、空字串，或誤刪內建資源檔。
    if (fileName == null ||
        fileName.isEmpty ||
        fileName.startsWith('assets/')) {
      return;
    }

    try {
      // 取得應用程式文件目錄，供組合實際檔案路徑使用。
      final directory = await getApplicationDocumentsDirectory();

      // 將文件目錄與檔名組合成完整路徑。
      final path = p.join(directory.path, fileName);
      final file = File(path);

      // 僅在檔案存在時才執行刪除，避免不必要的例外。
      if (await file.exists()) {
        await file.delete();
        debugPrint('[FileService] 已刪除本地檔案: $path');
      } else {
        // 補上不存在時的除錯資訊，方便確認是否為重複刪除或路徑錯誤。
        debugPrint('[FileService] 欲刪除的檔案不存在: $path');
      }
    } catch (e) {
      // 捕捉刪除過程中的例外，避免影響其他業務流程。
      debugPrint('[FileService] 刪除檔案失敗: $e');
    }
  }
}
