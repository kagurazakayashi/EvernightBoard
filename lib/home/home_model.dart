import 'package:flutter/material.dart';

/// 首頁項目資料模型。
///
/// 用於描述單一首頁項目的顯示資料，包含導覽列與頁面內容所需的核心欄位，例如：
///
/// - 導覽列標題
/// - 畫面主要文字內容
/// - 對應圖示
/// - 文字顏色
/// - 背景顏色
/// - 背景圖片路徑（選填）
///
/// 此模型通常會以清單形式被控制器管理，供 UI 依不同項目動態產生對應畫面。
class HomeItem {
  /// 導覽列上顯示的標題文字。
  final String title;

  /// 畫面中顯示的主要文字內容。
  ///
  /// 當未提供背景圖片，或目前頁面需顯示文字說明時使用。
  final String content;

  /// 導覽列或功能項目對應的圖示。
  final IconData icon;

  /// 畫面文字顏色。
  ///
  /// 可用於自訂不同首頁項目的文字呈現效果。
  /// 若為 `null`，通常代表交由上層主題或預設樣式決定。
  final Color? textColor;

  /// 畫面背景顏色。
  ///
  /// 當未設定背景圖片，或背景圖片未完整覆蓋畫面時，
  /// 會顯示此背景色作為底層背景。
  final Color? backgroundColor;

  /// 背景圖片路徑。
  ///
  /// 可為空值，表示目前項目不使用背景圖片。
  /// 若有提供，通常會交由圖片載入元件依實際路徑進行顯示。
  final String? backgroundImagePath;

  /// 建立一個 [HomeItem] 實例。
  ///
  /// [title]、[content] 與 [icon] 為必要欄位。
  ///
  /// [textColor]、[backgroundColor] 與 [backgroundImagePath] 為選填欄位，
  /// 可依畫面需求自訂視覺呈現方式。
  HomeItem({
    required this.title,
    required this.content,
    required this.icon,
    this.textColor,
    this.backgroundColor,
    this.backgroundImagePath,
  });

  /// 將目前物件轉換為 JSON 格式。
  ///
  /// 主要用於本機儲存、狀態持久化或資料匯入／匯出。
  ///
  /// 轉換規則如下：
  /// - [icon] 以 `codePoint` 形式儲存，還原時需搭配正確字型家族
  /// - 顏色會轉為 32 位元 ARGB 整數格式，以利序列化保存
  /// - [backgroundImagePath] 會以 `imagePath` 欄位名稱寫入 JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'icon': icon.codePoint,
    'textColor': textColor?.toARGB32(),
    'backgroundColor': backgroundColor?.toARGB32(),
    'imagePath': backgroundImagePath,
  };

  /// 從 JSON 資料建立 [HomeItem] 實例。
  ///
  /// 用於將已序列化的資料還原為可供 UI 與控制器使用的物件。
  ///
  /// 還原規則如下：
  /// - `icon` 以 `MaterialIcons` 字型家族建立 [IconData]
  /// - `textColor` 與 `backgroundColor` 若為 `null`，則保留為 `null`
  /// - `imagePath` 會對應至 [backgroundImagePath]
  /// - 若 `icon` 欄位不存在，則改用 `Icons.help_outline` 作為預設圖示
  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      // 如果 icon 轉換失敗，給一個預設圖示
      icon: IconData(
        json['icon'] ?? Icons.help_outline.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      textColor: json['textColor'] != null ? Color(json['textColor']) : null,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'])
          : null,
      backgroundImagePath: json['imagePath'] ?? '',
    );
  }

  /// 建立目前物件的複本，並覆寫指定欄位。
  ///
  /// 適合用於不可變資料結構的更新情境，
  /// 可在保留原始資料的前提下，僅調整部分欄位內容。
  ///
  /// 特別說明：
  /// - [clearTextColor] 為 `true` 時，會強制將 [textColor] 清為 `null`
  /// - [clearBgColor] 為 `true` 時，會強制將 [backgroundColor] 清為 `null`
  ///
  /// 此設計可避免單純使用 `??` 判斷時，
  /// 無法區分「未傳入新值」與「刻意清空欄位」兩種情境。
  HomeItem copyWith({
    String? title,
    String? content,
    IconData? icon,
    Color? textColor,
    bool clearTextColor = false,
    Color? backgroundColor,
    bool clearBgColor = false,
    String? backgroundImagePath,
  }) {
    return HomeItem(
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      textColor: clearTextColor ? null : (textColor ?? this.textColor),
      backgroundColor: clearBgColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }
}
