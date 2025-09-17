import 'package:flutter/material.dart';

/// 提供全域統一格式的 SnackBar 顯示工具類別。
///
/// 此類別封裝了 ScaffoldMessenger 的操作，旨在確保應用程式內部
/// 各個頁面的提示訊息樣式一致，並減少重複代碼。
class SnackBarUtils {
  /// 顯示統一風格的提示訊息。
  ///
  /// [context] 用於查找 ScaffoldMessenger 的構建上下文。
  /// [message] 要呈現給使用者的文字訊息內容。
  /// [isError] 用於切換成功或失敗的視覺樣式。若為 `true`，則顯示錯誤圖示與紅色背景。
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    // 輸出調試資訊，追蹤訊息觸發狀態
    debugPrint('[SnackBarUtils] 正在顯示訊息: "$message" (錯誤狀態: $isError)');

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 立即清除當前的 SnackBar，防止多個提示在佇列中排隊導致的顯示延遲
    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // 根據狀態切換圖示與顏色
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            // 使用 Expanded 確保長訊息能正確換行而不溢出
            Expanded(child: Text(message)),
          ],
        ),
        // 若為錯誤提示則覆寫為深紅色背景，否則套用系統主題預設色
        backgroundColor: isError ? const Color(0xFFC62828) : null,
        // 設定較短的顯示時間，提升使用者體驗的流暢度
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
