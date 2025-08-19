/// HomeController
///
/// 此控制器負責管理首頁資料與互動邏輯，包含：
/// 1. 初始化首頁預設項目資料
/// 2. 管理目前選取的項目索引
/// 3. 透過音量鍵切換上一筆 / 下一筆項目
/// 4. 透過加速度感測器判斷目前導覽方向
/// 5. 提供新增、刪除、更新項目的操作
///
/// 搭配 [ChangeNotifier] 使用，當狀態變更時會呼叫 [notifyListeners]，
/// 讓 UI 可以即時更新畫面。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'home_model.dart';

/// 導覽方向列舉。
///
/// 用於表示目前裝置傾斜或導覽顯示的方向。
enum NavSide { left, right }

/// 首頁控制器。
///
/// 管理首頁資料清單、目前選取項目、音量控制事件與感測器事件。
class HomeController extends ChangeNotifier {
  /// 首頁項目清單。
  List<HomeItem> items = [];

  /// 目前選取的項目索引。
  int _currentIndex = 0;

  /// 目前導覽方向，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 記錄上一次的系統音量，用於比對音量增減方向。
  double _lastVolume = 0.5;

  /// 加速度感測器訂閱物件，用於後續釋放資源。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 取得目前項目索引。
  int get currentIndex => _currentIndex;

  /// 取得目前導覽方向。
  NavSide get currentSide => _currentSide;

  /// 取得目前選取的項目。
  HomeItem get currentItem => items[_currentIndex];

  /// 建構子。
  ///
  /// 建立控制器時，依序初始化：
  /// - 預設資料
  /// - 感測器監聽
  /// - 音量鍵控制
  HomeController() {
    _initData();
    _initSensors();
    _initVolumeControl();
  }

  /// 初始化首頁預設資料。
  ///
  /// 建立兩筆預設 [HomeItem]：
  /// - 一筆圖片項
  /// - 一筆文字項
  void _initData() {
    items = [
      HomeItem(
        title: '图片项',
        content: '',
        icon: Icons.image,
        backgroundColor: Colors.indigo[900]!,
        textColor: Colors.amberAccent,
        backgroundImagePath: 'assets/default.png',
      ),
      HomeItem(
        title: '文字项',
        content: 'Demo\nText',
        icon: Icons.text_fields,
        backgroundColor: Colors.teal[900]!,
        textColor: Colors.white,
      ),
    ];
  }

  /// 新增一筆項目，並自動切換到新項目。
  void addItem() {
    items.add(
      HomeItem(
        title: '新增项',
        content: '新内容',
        icon: Icons.add_circle_outline,
        backgroundColor: Colors.blueGrey[900]!,
        textColor: Colors.white,
      ),
    );

    // 將目前索引移到最後一筆，也就是剛新增的項目。
    _currentIndex = items.length - 1;

    // 通知監聽者更新 UI。
    notifyListeners();
  }

  /// 刪除目前選取的項目。
  ///
  /// 為避免清單為空，至少保留一筆資料，因此當僅剩一筆時不執行刪除。
  void deleteCurrentItem() {
    // 若只剩最後一筆，則不允許刪除。
    if (items.length <= 1) return;

    // 刪除目前索引對應的項目。
    items.removeAt(_currentIndex);

    // 若刪除後索引超出範圍，將索引調整到最後一筆。
    if (_currentIndex >= items.length) {
      _currentIndex = items.length - 1;
    }

    // 通知 UI 更新。
    notifyListeners();
  }

  /// 更新目前項目的標題與內容。
  ///
  /// [newTitle] 為新的標題。
  /// [newContent] 為新的內容。
  ///
  /// 其餘樣式屬性會沿用目前項目的設定。
  void updateCurrentItem(String newTitle, String newContent) {
    items[_currentIndex] = HomeItem(
      title: newTitle,
      content: newContent,
      icon: currentItem.icon,
      backgroundColor: currentItem.backgroundColor,
      textColor: currentItem.textColor,
      backgroundImagePath: currentItem.backgroundImagePath,
    );

    // 通知 UI 重新渲染。
    notifyListeners();
  }

  /// 切換目前索引。
  ///
  /// 僅當目標索引與目前索引不同時才更新，以避免不必要的通知。
  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 切換到下一筆項目。
  ///
  /// 使用取餘數實作循環切換，超過最後一筆時會回到第一筆。
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length;
    notifyListeners();
  }

  /// 切換到上一筆項目。
  ///
  /// 使用循環索引，當目前在第一筆時會切換到最後一筆。
  void previousItem() {
    _currentIndex = (_currentIndex - 1 + items.length) % items.length;
    notifyListeners();
  }

  /// 初始化音量鍵控制邏輯。
  ///
  /// 功能說明：
  /// - 隱藏系統音量 UI
  /// - 監聽音量變化
  /// - 音量增加時切換到上一筆
  /// - 音量減少時切換到下一筆
  /// - 避免音量停在 0 或 1，降低邊界值造成的操作問題
  void _initVolumeControl() async {
    // 關閉系統原生音量 UI，避免干擾畫面顯示。
    await FlutterVolumeController.updateShowSystemUI(false);

    // 讀取目前系統音量，若取得失敗則預設為 0.5。
    _lastVolume = await FlutterVolumeController.getVolume() ?? 0.5;

    // 監聽音量變化事件。
    FlutterVolumeController.addListener((volume) {
      // 若音量上升，切換到上一筆。
      if (volume > _lastVolume) {
        previousItem();
      }
      // 若音量下降，切換到下一筆。
      else if (volume < _lastVolume) {
        nextItem();
      }

      // 更新最後一次音量值。
      _lastVolume = volume;

      // 若音量達到上限，稍微往下拉回，避免卡在最大值無法再觸發增加事件。
      if (volume >= 1.0) {
        FlutterVolumeController.setVolume(0.9);
        _lastVolume = 0.9;
      }
      // 若音量達到下限，稍微往上拉回，避免卡在最小值無法再觸發減少事件。
      else if (volume <= 0.0) {
        FlutterVolumeController.setVolume(0.1);
        _lastVolume = 0.1;
      }
    });
  }

  /// 初始化加速度感測器監聽。
  ///
  /// 根據 X 軸數值判斷裝置偏向左或右，並更新導覽方向。
  void _initSensors() {
    _sensorSub = accelerometerEventStream().listen((event) {
      // 當 X 軸大於門檻值，視為偏向左側。
      if (event.x > 2.5) {
        _updateSide(NavSide.left);
      }
      // 當 X 軸小於負門檻值，視為偏向右側。
      else if (event.x < -2.5) {
        _updateSide(NavSide.right);
      }
    });
  }

  /// 更新目前導覽方向。
  ///
  /// 僅在方向有實際變更時才通知 UI 更新。
  void _updateSide(NavSide side) {
    if (_currentSide != side) {
      _currentSide = side;
      notifyListeners();
    }
  }

  /// 釋放控制器資源。
  ///
  /// 包含：
  /// - 取消加速度感測器監聽
  /// - 移除音量監聽器
  @override
  void dispose() {
    // 取消感測器串流訂閱，避免記憶體洩漏。
    _sensorSub?.cancel();

    // 移除音量監聽器。
    FlutterVolumeController.removeListener();

    // 呼叫父類別的 dispose。
    super.dispose();
  }
}
