import 'package:flutter/material.dart';
import 'home_model.dart';

/// 首頁控制器。
///
/// 負責管理首頁相關的狀態與互動邏輯，包含：
/// 1. 提供頁面所需的資料來源。
/// 2. 追蹤目前選中的項目索引。
/// 3. 在索引變更時通知畫面重新整理。
class HomeController extends ChangeNotifier {
  /// 資料來源清單，內容為首頁要顯示的項目列表。
  ///
  /// 每個 [HomeItem] 包含標題、內容與圖示資訊，
  /// 供 View 層依目前索引進行顯示。
  final List<HomeItem> items = [
    // 首頁項目
    HomeItem(title: '111', content: '111\n111\n111', icon: Icons.home),

    // 訊息項目
    HomeItem(title: '222', content: '222\n222\n222', icon: Icons.message),

    // 設定項目
    HomeItem(title: '333', content: '333\n333\n333', icon: Icons.settings),
  ];

  /// 目前選中的項目索引，預設為第 0 個。
  int _currentIndex = 0;

  /// 取得目前選中的索引值。
  int get currentIndex => _currentIndex;

  /// 取得目前選中項目的內容文字。
  ///
  /// 會依照當前的 [_currentIndex] 從 [items] 中取出對應內容。
  String get currentContent => items[_currentIndex].content;

  /// 切換目前選中的項目索引。
  ///
  /// 當傳入的 [index] 與目前索引不同時，
  /// 才會更新狀態並呼叫 [notifyListeners]，
  /// 以避免不必要的畫面刷新。
  void changeIndex(int index) {
    // 僅在索引發生變化時才更新狀態
    if (_currentIndex != index) {
      // 更新目前選中的索引
      _currentIndex = index;

      // 通知監聽者（通常是 View）進行重新整理
      notifyListeners(); // 通知 View 刷新
    }
  }
}
