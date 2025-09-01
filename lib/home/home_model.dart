import 'package:flutter/material.dart';

/// 首頁項目資料模型。
///
/// 用於描述單一首頁／導覽項目的顯示資訊，包含：
/// - 導覽列標題
/// - 畫面主要內容文字
/// - 導覽列圖示
/// - 文字顏色
/// - 背景顏色
/// - 背景圖片路徑（可選）
///
/// 此類別通常會搭配清單使用，讓 UI 可依不同項目動態產生對應畫面。
class HomeItem {
  /// 導覽列上顯示的標題文字。
  final String title; // 導覽列標籤文字

  /// 畫面中顯示的主要文字內容。
  ///
  /// 當未提供背景圖片，或畫面需要顯示文字說明時使用。
  final String content; // 畫面顯示文字（未使用圖片時可作為主要內容）

  /// 導覽列或對應功能項目的圖示。
  final IconData icon; // 導覽列圖示

  /// 畫面文字顏色。
  ///
  /// 可用於自訂不同首頁項目的文字呈現效果。
  final Color? textColor; // 文字顏色

  /// 畫面背景顏色。
  ///
  /// 當未設定背景圖片，或背景圖片未完整覆蓋畫面時，會顯示此背景色。
  final Color? backgroundColor; // 背景顏色（無圖片或圖片未鋪滿時顯示）

  /// 背景圖片路徑。
  ///
  /// 可為空值，表示不使用背景圖片。
  /// 若有提供，通常會搭配 `AssetImage` 或其他圖片載入方式使用。
  final String? backgroundImagePath; // 背景圖片路徑（選填）

  /// 將目前物件轉換為 JSON 格式。
  ///
  /// 主要用於本機儲存、狀態持久化或資料傳輸。
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'icon': icon.codePoint, // 儲存圖示的 codePoint 以便後續還原
    'textColor': textColor?.toARGB32(), // 以 ARGB 32 位整數形式儲存顏色
    'backgroundColor': backgroundColor?.toARGB32(),
    'imagePath': backgroundImagePath,
  };

  /// 從 JSON 資料建立 [HomeItem] 實例。
  ///
  /// 用於將已序列化的資料還原成可供 UI 使用的物件。
  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      title: json['title'],
      content: json['content'],
      // 還原圖示：Material Design 預設使用 'MaterialIcons' 字型家族
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      // 還原顏色欄位；若對應值為 null，則保留為 null
      textColor: json['textColor'] != null ? Color(json['textColor']) : null,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'])
          : null,
      backgroundImagePath: json['imagePath'],
    );
  }

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
    // 視覺相關欄位可不傳入，由外部依需求決定是否指定
    this.textColor,
    this.backgroundColor,
    this.backgroundImagePath,
  });

  /// 建立目前物件的複本，並覆寫指定欄位。
  ///
  /// 適合用於不可變資料結構的更新情境。
  ///
  /// 其中 [clearTextColor] 與 [clearBgColor] 可明確將對應欄位設為 `null`，
  /// 避免僅靠 `??` 判斷時無法區分「未傳入」與「刻意清空」。
  HomeItem copyWith({
    String? title,
    String? content,
    IconData? icon,
    Color? textColor,
    // 這裡允許明確清空欄位，因此不能只依賴 ?? 進行判斷
    // 需透過旗標區分「不修改」與「設為 null」
    bool clearTextColor = false,
    Color? backgroundColor,
    bool clearBgColor = false,
    String? backgroundImagePath,
  }) {
    return HomeItem(
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      // 若 clear 為 true，則強制設為 null；否則才使用傳入值或原值
      textColor: clearTextColor ? null : (textColor ?? this.textColor),
      backgroundColor: clearBgColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }
}
