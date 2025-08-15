import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'home_model.dart';

/// 導覽列所在側邊列舉。
///
/// 用於表示目前導覽 UI 應顯示在左側或右側。
enum NavSide { left, right }

/// 首頁頁面控制器。
///
/// 負責管理：
/// 1. 首頁導覽項目的資料來源。
/// 2. 目前選中的頁籤索引。
/// 3. 根據加速度計資料判斷導覽顯示在左側或右側。
/// 4. 在狀態變更時通知 UI 重新繪製。
class HomeController extends ChangeNotifier {
  /// 導覽項目資料來源。
  ///
  /// 每個 [HomeItem] 包含標題、內容與圖示，
  /// 供畫面上的導覽列與內容區塊使用。
  final List<HomeItem> items = [
    HomeItem(title: '1', content: '1', icon: Icons.home),
    HomeItem(title: '2', content: '2', icon: Icons.search),
    HomeItem(title: '3', content: '3', icon: Icons.settings),
  ];

  /// 目前選中的導覽索引，預設為第 0 項。
  int _currentIndex = 0;

  /// 目前導覽所在側邊，預設顯示於右側。
  NavSide _currentSide = NavSide.right; // 默认在右侧

  /// 加速度計事件訂閱物件。
  ///
  /// 用於接收裝置感測器資料，並在控制器釋放時取消監聽。
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// 取得目前選中的導覽索引。
  int get currentIndex => _currentIndex;

  /// 取得目前導覽所在側邊。
  NavSide get currentSide => _currentSide;

  /// 取得目前選中項目對應的內容字串。
  String get currentContent => items[_currentIndex].content;

  /// 建立 [HomeController] 時自動初始化感測器監聽。
  HomeController() {
    _initSensors();
  }

  /// 初始化加速度計監聽。
  ///
  /// 透過裝置的加速度計資料判斷手機左右傾斜方向，
  /// 並依據 x 軸數值切換導覽列位置。
  void _initSensors() {
    // 監聽加速度計事件串流，持續接收裝置移動與傾斜資料。
    _subscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      // 在直向畫面邏輯下，x 軸可視為左右傾斜方向的判斷依據。
      // 設定閾值可避免感測器過於敏感造成畫面頻繁抖動切換。
      if (event.x > 1) {
        // 當 x 軸大於閾值時，視為裝置向右傾斜，將導覽切換至右側。
        _updateSide(NavSide.left);
      } else if (event.x < -1) {
        // 當 x 軸小於負閾值時，視為裝置向左傾斜，將導覽切換至左側。
        _updateSide(NavSide.right);
      }
    });
  }

  /// 更新目前導覽所在側邊。
  ///
  /// 僅當新側邊與目前側邊不同時才更新狀態，
  /// 以避免不必要的 UI 重建。
  void _updateSide(NavSide side) {
    // 只有在側邊發生變化時才更新，避免重複通知監聽者。
    if (_currentSide != side) {
      // 更新目前導覽位置。
      _currentSide = side;

      // 通知所有監聽者狀態已改變，觸發 UI 更新。
      notifyListeners();
    }
  }

  /// 切換目前選中的導覽索引。
  ///
  /// [index] 為欲切換的目標項目索引。
  void changeIndex(int index) {
    // 更新目前選中的頁籤索引。
    _currentIndex = index;

    // 通知監聽者重新繪製對應內容。
    notifyListeners();
  }

  // 翻到下一項
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length;
    notifyListeners();
  }

  // 翻到上一項
  void previousItem() {
    _currentIndex = (_currentIndex - 1 + items.length) % items.length;
    notifyListeners();
  }

  @override
  void dispose() {
    // 取消加速度計監聽，避免控制器釋放後仍持續接收事件，造成記憶體洩漏。
    _subscription?.cancel(); // 必须销毁监听器，防止内存泄漏

    // 呼叫父類別的 dispose，完成 ChangeNotifier 資源釋放流程。
    super.dispose();
  }
}
