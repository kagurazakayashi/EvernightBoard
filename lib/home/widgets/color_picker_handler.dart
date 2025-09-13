import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// 負責處理顏色選擇器開啟流程與結果回傳的工具類。
///
/// 此類別主要封裝：
/// - 顏色選擇對話框的顯示流程
/// - 使用者選色時的即時回呼
/// - 確認／取消後的結果處理
/// - 必要的除錯輸出
class ColorPickerHandler {
  /// 顯示顏色選擇器對話框。
  ///
  /// [context] 用於顯示對話框。
  /// [title] 為對話框標題。
  /// [initialColor] 為目前已設定的顏色，可為 `null`。
  /// [isTextType] 用於區分預設顏色應採用文字色或背景色邏輯。
  /// [onColorChanged] 會在使用者調整顏色時即時回傳最新顏色，
  /// 並在取消操作時回復原始顏色。
  /// [checkSimilarity] 預留給顏色相似度檢查邏輯使用。
  /// [otherColor] 為另一個可用來比對對比度或相似度的顏色。
  ///
  /// 修正說明：
  /// 改用標準 showDialog 以避免非同步 Context 失效導致的 Null check 報錯。
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Color? initialColor,
    required bool isTextType,
    required Function(Color?) onColorChanged,
    required bool Function(Color?, Color?) checkSimilarity,
    Color? otherColor,
  }) async {
    // 保留開啟前的原始顏色，以便使用者取消時還原。
    final Color? originalColor = initialColor;

    // 建立初始顯示顏色：
    // 若外部已有傳入顏色則優先使用，
    // 否則依用途決定文字模式或背景模式的預設值。
    Color latestPickedColor =
        initialColor ?? (isTextType ? Colors.cyanAccent : Colors.black87);

    debugPrint('[ColorPickerHandler] 開啟顏色選擇器：$title');

    // 使用 Flutter 標準 showDialog，
    // 可確保 Navigator 的 pop 操作使用的是對話框自身的 BuildContext。
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              // 設定顏色選擇器初始顏色。
              color: latestPickedColor,

              // 使用者每次調整顏色時即時同步最新值，
              // 並回呼外部以更新預覽或暫存狀態。
              onColorChanged: (Color color) {
                latestPickedColor = color;
                debugPrint('[ColorPickerHandler] 顏色已變更：$color');
                onColorChanged(color);
              },
              width: 44,
              height: 44,
              borderRadius: 22,

              // 內部標題設為空，因為外層 AlertDialog 已提供 title。
              heading: null,
              subheading: const Text('选择色调'),
              pickersEnabled: const {
                ColorPickerType.primary: true,
                ColorPickerType.accent: false,
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    debugPrint('[ColorPickerHandler] 選擇器關閉，確認狀態：$isConfirmed');

    if (isConfirmed == true) {
      // 目前確認流程僅保留最終顏色，不額外覆寫。
      // 若未來重新啟用相似度檢查，可在此加入對比不足提示與還原邏輯。
      debugPrint('[ColorPickerHandler] 已確認顏色：$latestPickedColor');

      // 確認後的相似度檢查
      // if (checkSimilarity(latestPickedColor, otherColor)) {
      //   debugPrint('[ColorPickerHandler] 對比度不足，還原原始顏色');
      //   onColorChanged(originalColor);
      //   // 確保在對話框關閉後，原本的 context 仍然可用才顯示警告
      //   if (context.mounted) {
      //     _showWarning(context, '颜色对比度不足，请重新设置！');
      //   }
      // } else {
      //   debugPrint('[ColorPickerHandler] 最終確認顏色：$latestPickedColor');
      // }
    } else {
      // 使用者取消或點擊外部關閉時，將顏色還原為開啟前的原始值。
      debugPrint('[ColorPickerHandler] 取消操作，還原顏色');
      onColorChanged(originalColor);
    }
  }

  /// 顯示警告訊息。
  ///
  /// 目前此方法仍保留為註解，供未來重新啟用顏色對比不足提示時使用。
  // static void _showWarning(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message, style: const TextStyle(color: Colors.black)),
  //       backgroundColor: Colors.yellow.shade700,
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }
}
