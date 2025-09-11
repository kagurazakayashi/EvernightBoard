import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class DataExportService {
  static Future<bool> exportJson(String jsonContent) async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '请选择保存位置',
        fileName:
            'evernight_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonContent);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('导出失败: $e');
      return false;
    }
  }

  static Future<String?> importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('导入失败: $e');
      return null;
    }
  }
}
