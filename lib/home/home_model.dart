import 'package:flutter/material.dart';
import 'package:evernight_board/global.dart';

/// 首頁項目資料模型。
///
/// 用於描述單一首頁或導覽項目的顯示資訊，包含：
///
/// - 導覽列標題
/// - 畫面主要內容文字
/// - 導覽列圖示
/// - 文字顏色
/// - 背景顏色
/// - 背景圖片路徑（選填）
///
/// 此類別通常會搭配清單使用，讓 UI 可依不同項目動態產生對應畫面。
class HomeItem {
  /// 導覽列上顯示的標題文字。
  final String title;

  /// 畫面中顯示的主要文字內容。
  ///
  /// 當未提供背景圖片，或畫面需要顯示文字說明時使用。
  final String content;

  /// 導覽列或功能項目對應的圖示。
  final IconData icon;

  /// 畫面文字顏色。
  ///
  /// 可用於自訂不同首頁項目的文字呈現效果。
  /// 若為 `null`，通常表示交由上層主題或預設樣式決定。
  final Color? textColor;

  /// 畫面背景顏色。
  ///
  /// 當未設定背景圖片，或背景圖片未完整覆蓋畫面時，
  /// 會顯示此背景色。
  final Color? backgroundColor;

  /// 背景圖片路徑。
  ///
  /// 可為空值，表示不使用背景圖片。
  /// 若有提供，通常會搭配 `AssetImage` 或其他圖片載入方式使用。
  final String? backgroundImagePath;

  /// 建立一個 [HomeItem] 實例。
  ///
  /// [title]、[content]、[icon] 為必填欄位。
  ///
  /// [textColor]、[backgroundColor]、[backgroundImagePath] 為選填欄位，
  /// 可依畫面需求自訂視覺樣式。
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
  /// 主要用於本機儲存、狀態持久化或資料傳輸。
  ///
  /// 注意事項：
  /// - [icon] 會以 `codePoint` 形式儲存，後續需搭配正確字型家族還原。
  /// - 顏色會轉為 32 位元 ARGB 整數格式，以利序列化保存。
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
  /// 用於將已序列化的資料還原成可供 UI 使用的物件。
  ///
  /// 還原規則：
  /// - `icon` 使用 `MaterialIcons` 字型家族建立 [IconData]
  /// - `textColor` 與 `backgroundColor` 若為 `null`，則保留為 `null`
  /// - `imagePath` 對應到 [backgroundImagePath]
  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      title: json['title'] ?? t.unnamed,
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
  /// 可在保留原始物件內容的前提下，僅修改部分欄位。
  ///
  /// 特別說明：
  /// - [clearTextColor] 為 `true` 時，會強制將 [textColor] 設為 `null`
  /// - [clearBgColor] 為 `true` 時，會強制將 [backgroundColor] 設為 `null`
  ///
  /// 這樣的設計可避免單純使用 `??` 判斷時，
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
