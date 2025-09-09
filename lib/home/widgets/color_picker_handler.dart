import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// 负责处理颜色选择器开启流程与结果回传的工具类。
///
/// 主要职责包含：
/// - 显示颜色选择对话框。
/// - 即时回传使用者目前挑选的颜色。
/// - 在确认时检查与另一颜色是否过于相近。
/// - 若使用者取消选择，则还原为原始颜色。
class ColorPickerHandler {
  /// 显示颜色选择器对话框。
  ///
  /// 参数说明：
  /// - [context]：当前页面的 `BuildContext`，用于开启对话框与显示提示讯息。
  /// - [title]：颜色选择器标题。
  /// - [initialColor]：初始颜色，若为 `null` 会依 [isTextType] 提供预设值。
  /// - [isTextType]：是否为文字颜色类型，用于决定预设颜色。
  /// - [onColorChanged]：当颜色变更时触发的回呼，包含即时选择、取消还原与确认后回写。
  /// - [checkSimilarity]：用于检查目前选择颜色与 [otherColor] 是否过于接近的函数。
  /// - [otherColor]：用于进行相似度／对比度检查的另一颜色。
  ///
  /// 流程说明：
  /// 1. 开启颜色选择器。
  /// 2. 使用者每次选色时，立即更新 [latestPickedColor] 并透过 [onColorChanged] 通知外部。
  /// 3. 若使用者按下确认，则检查与 [otherColor] 的相似度。
  /// 4. 若对比度不足，则还原原始颜色并显示警告。
  /// 5. 若使用者取消，则直接还原原始颜色。
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Color? initialColor,
    required bool isTextType,
    required Function(Color?) onColorChanged,
    required bool Function(Color?, Color?) checkSimilarity,
    Color? otherColor,
  }) async {
    /// 记录开启选择器前的原始颜色，供取消或验证失败时还原。
    final Color? originalColor = initialColor;

    /// 记录目前最新一次被挑选的颜色。
    ///
    /// 初始值先沿用 [initialColor]，后续会在 `onColorChanged` 中持续更新。
    Color? latestPickedColor = initialColor;

    debugPrint(
      '[ColorPickerHandler] 開啟顏色選擇器：title=$title, initialColor=$initialColor, isTextType=$isTextType',
    );

    final bool isConfirmed =
        await ColorPicker(
          // 若未提供初始颜色，则依类型提供较合理的预设值。
          color:
              initialColor ?? (isTextType ? Colors.cyanAccent : Colors.black87),

          // 使用者每次调整颜色时都会即时触发。
          onColorChanged: (Color color) {
            latestPickedColor = color;
            debugPrint('顏色已變更：$color');
            onColorChanged(color);
          },

          // 颜色方块宽度。
          width: 44,

          // 颜色方块高度。
          height: 44,

          // 颜色方块圆角半径。
          borderRadius: 22,

          // 对话框标题。
          heading: Text(title),

          // 仅启用主色盘，不启用强调色盘。
          pickersEnabled: const {
            ColorPickerType.primary: true,
            ColorPickerType.accent: false,
          },
        ).showPickerDialog(
          context,

          // 限制对话框尺寸，避免在不同装置上显示过大或过小。
          constraints: const BoxConstraints(
            minHeight: 400,
            minWidth: 300,
            maxWidth: 320,
          ),
        );

    debugPrint(
      '[ColorPickerHandler] 顏色選擇器已關閉，是否確認：$isConfirmed，latestPickedColor=$latestPickedColor',
    );

    if (isConfirmed == true) {
      // 使用者确认后，检查当前选择颜色与另一颜色是否过于相近。
      if (checkSimilarity(latestPickedColor, otherColor)) {
        debugPrint('[ColorPickerHandler] 顏色相似度檢查未通過，還原為原始顏色：$originalColor');
        onColorChanged(originalColor);
        _showWarning(context, '颜色对比度不足，请重新设置！');
      } else {
        debugPrint('[ColorPickerHandler] 顏色確認完成，最終顏色：$latestPickedColor');
      }
    } else {
      // 使用者取消选择时，还原为原始颜色。
      debugPrint('[ColorPickerHandler] 使用者取消顏色選擇，還原為原始顏色：$originalColor');
      onColorChanged(originalColor);
    }
  }

  /// 显示警告用的浮动式 `SnackBar`。
  ///
  /// 通常用于提示颜色对比度不足等需要使用者重新操作的情况。
  static void _showWarning(BuildContext context, String message) {
    debugPrint('[ColorPickerHandler] 顯示警告訊息：$message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
