import 'package:flutter/material.dart';

/// 首頁項目資料模型。
///
/// 用來描述單一首頁卡片或導覽項目的基本資訊，包含：
/// - [title]：顯示在導覽列或介面上的標題文字
/// - [content]：頁面中要呈現的主要大型文字內容
/// - [icon]：對應此項目的 Material 圖示
class HomeItem {
  /// 導航欄標籤文字。
  final String title; // 導航欄標籤

  /// 要顯示的巨大文本內容。
  final String content; // 要顯示的巨大文本

  /// 此項目對應的圖示資料。
  final IconData icon;

  /// 建立一個 [HomeItem] 實例。
  ///
  /// 所有欄位皆為必填：
  /// - [title]：標題文字
  /// - [content]：內容文字
  /// - [icon]：圖示
  HomeItem({required this.title, required this.content, required this.icon});
}
