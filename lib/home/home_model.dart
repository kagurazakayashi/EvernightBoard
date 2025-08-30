import 'package:flutter/material.dart';

/// 首頁項目資料模型。
///
/// 用來描述單一首頁／導覽項目的顯示資訊，包含：
/// - 導覽列標題
/// - 畫面主要內容文字
/// - 導覽列圖示
/// - 文字顏色
/// - 背景顏色
/// - 背景圖片路徑（可選）
///
/// 此類別通常會搭配清單使用，讓 UI 可依據不同項目動態產生對應畫面。
class HomeItem {
  /// 導覽列上顯示的標題文字。
  final String title; // 导航栏标签

  /// 畫面中顯示的主要文字內容。
  ///
  /// 當未提供背景圖片，或畫面需要顯示文字說明時使用。
  final String content; // 屏幕显示文字 (如果没图片)

  /// 導覽列或對應功能項目的圖示。
  final IconData icon; // 导航栏图标

  /// 畫面文字顏色。
  ///
  /// 預設為 [Colors.cyanAccent]，以維持深色主題下的可讀性與科技感。
  final Color? textColor; // 文字颜色

  /// 畫面背景顏色。
  ///
  /// 當未設定背景圖片，或背景圖片未完整覆蓋畫面時，會顯示此背景色。
  final Color? backgroundColor; // 背景颜色 (没图片或图片没填满时显示)

  /// 背景圖片路徑。
  ///
  /// 可為空值，表示不使用背景圖片。
  /// 若有提供，通常會搭配 `AssetImage` 或其他圖片載入方式使用。
  final String? backgroundImagePath; // 背景图片路径 (可选)

  /// 建立一個 [HomeItem] 實例。
  ///
  /// [title]、[content]、[icon] 為必填欄位。
  ///
  /// 其餘視覺相關欄位提供預設值：
  /// - [textColor] 預設為 `Colors.cyanAccent`
  /// - [backgroundColor] 預設為 `Colors.black87`
  /// - [backgroundImagePath] 為可選欄位
  HomeItem({
    required this.title,
    required this.content,
    required this.icon,
    // 設定預設值，以維持深色主題風格與一致的視覺表現
    this.textColor,
    this.backgroundColor,
    this.backgroundImagePath,
  });

  HomeItem copyWith({
    String? title,
    String? content,
    IconData? icon,
    Color? textColor,
    // 注意：这里我们允许传入 null，所以内部逻辑不使用 ??
    // 我们手动处理“想要设为 null”的情况
    bool clearTextColor = false,
    Color? backgroundColor,
    bool clearBgColor = false,
    String? backgroundImagePath,
  }) {
    return HomeItem(
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      // 如果 clear 为 true，强制设为 null，否则才取传入的值或原值
      textColor: clearTextColor ? null : (textColor ?? this.textColor),
      backgroundColor: clearBgColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }
}
