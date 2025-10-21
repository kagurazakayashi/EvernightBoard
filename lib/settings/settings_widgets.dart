import 'package:flutter/material.dart';

/// 設定頁面中的區塊標題元件。
///
/// 此元件通常用於設定頁、偏好設定頁或其他分組式清單介面中，
/// 作為不同功能區塊之間的視覺分隔標題。
///
/// 透過一致的間距、字級、字重與主題色彩設定，可強化畫面資訊層次，
/// 協助使用者快速辨識目前所屬的設定群組。
class SettingsSectionTitle extends StatelessWidget {
  /// 區塊標題所顯示的文字內容。
  final String title;

  /// 建立一個設定區塊標題元件。
  ///
  /// [title] 為必要參數，用於指定目前區塊的標題文字。
  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    /// 控制標題與上下相鄰元件的外距，
    /// 讓各設定群組之間保有一致且清楚的分段視覺。
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,

        /// 套用區塊標題的文字樣式：
        /// - 使用較小但醒目的字級
        /// - 以粗體強化標題辨識度
        /// - 採用目前主題的主色，維持整體介面風格一致
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
