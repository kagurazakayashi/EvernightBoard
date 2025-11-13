import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:evernight_board/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Linux 平台缺少文件对话框组件时的异常
class LinuxPortalMissingException implements Exception {
  final String message;
  LinuxPortalMissingException(this.message);
  @override
  String toString() => 'LinuxPortalMissingException: $message';
}

/// 数据导入／导出服务。
///
/// 负责处理 JSON 配置档的：
/// - 导出到使用者指定位置
/// - 从本机选取并读取内容
///
/// 此类别本身不负责数据结构转换，
/// 仅处理档案选择与档案内容读取。
class DataExportService {
  /// 检查 Linux 平台下 XDG Desktop Portal 是否可用
  static Future<void> _checkLinuxPortal() async {
    if (!Platform.isLinux) return;
    try {
      final result = await Process.run('which', ['xdg-desktop-portal']);
      if (result.exitCode != 0) {
        throw LinuxPortalMissingException(
          'System missing necessary components, cannot open dialog',
        );
      }
    } catch (e) {
      if (e is LinuxPortalMissingException) rethrow;
      throw LinuxPortalMissingException(
        'System missing necessary components, cannot open dialog',
      );
    }
  }

  /// 將 JSON 字串匯出為檔案。
  ///
  /// [jsonContent] 為欲寫入檔案的 JSON 文字內容。
  ///
  /// 執行流程：
  /// 1. 開啟另存新檔對話框，讓使用者選擇儲存位置。
  /// 2. 若使用者有選擇路徑，則將內容寫入指定檔案。
  /// 3. 若使用者取消操作或發生例外，則回傳 `false`。
  ///
  /// 回傳：
  /// - `true`：成功匯出
  /// - `false`：使用者取消或匯出失敗
  static Future<bool> exportJson(String jsonContent) async {
    try {
      await _checkLinuxPortal();
      debugPrint('[DataExportService] 開始導出 JSON');
      final String fileName =
          'evernight_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      // 判斷是否為行動端 (Android 或 iOS)
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // 1. 將數據寫入暫存目錄的臨時檔案中
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonContent);

        // 2. 使用最新的 SharePlus 實例方法呼叫系統分享/儲存面板
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'EvernightBoardConfig',
          ),
        );

        if (result.status == ShareResultStatus.success) {
          debugPrint('[DataExportService] 行動端導出成功');
          return true;
        }
        debugPrint('[DataExportService] 使用者取消操作');
        return false;
      }
      // 桌面端 (Windows, macOS, Linux) 邏輯保持不變
      else {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: t.savelocation,
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonContent);
          debugPrint('[DataExportService] 桌面端導出成功: $outputFile');
          return true;
        }

        debugPrint('[DataExportService] 使用者取消導出');
        return false;
      }
    } catch (e) {
      if (e is LinuxPortalMissingException ||
          (e.toString().contains('org.freedesktop.DBus') ||
              e.toString().contains('dbus'))) {
        rethrow;
      }
      debugPrint('[DataExportService] 導出失敗: $e');
      return false;
    }
  }

  /// 從本機選取 JSON 檔案並讀取其內容。
  ///
  /// 執行流程：
  /// 1. 開啟檔案選取視窗，僅允許選取 `.json` 檔案。
  /// 2. 若使用者選取成功且路徑有效，則讀取檔案文字內容。
  /// 3. 若使用者取消操作或發生例外，則回傳 `null`。
  ///
  /// 回傳：
  /// - JSON 文字內容：讀取成功
  /// - `null`：使用者取消、路徑無效或讀取失敗
  static Future<String?> importJson() async {
    try {
      await _checkLinuxPortal();
      debugPrint('[DataExportService] 開始匯入 JSON 檔案');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        debugPrint('[DataExportService] 已選取匯入檔案：${result.files.single.path!}');
        return await file.readAsString();
      }

      debugPrint('[DataExportService] 使用者取消匯入');
      return null;
    } catch (e) {
      if (e is LinuxPortalMissingException ||
          (e.toString().contains('org.freedesktop.DBus') ||
              e.toString().contains('dbus'))) {
        rethrow;
      }
      debugPrint('[DataExportService] 导入失败: $e');
      return null;
    }
  }
}
