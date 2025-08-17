/// 控制首頁狀態與互動邏輯的控制器。
///
/// 功能包含：
/// 1. 管理目前顯示的 `HomeItem`。
/// 2. 監聽裝置音量變化，切換上一個或下一個項目。
/// 3. 監聽加速度感測器資料，更新目前導航顯示方向。
/// 4. 透過 `ChangeNotifier` 通知 UI 重新繪製。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'home_model.dart';

/// 導航列所在側邊。
enum NavSide { left, right }

/// 首頁控制器。
///
/// 此類別負責：
/// - 維護首頁資料清單
/// - 記錄目前選中的索引
/// - 根據裝置音量鍵切換項目
/// - 根據加速度感測器判斷目前導覽側邊
class HomeController extends ChangeNotifier {
  /// 首頁可顯示的項目清單。
  final List<HomeItem> items = [
    HomeItem(title: 'Demo', content: 'Demo', icon: Icons.widgets_rounded),
  ];

  /// 目前選中的項目索引。
  int _currentIndex = 0;

  /// 目前導航所在側邊，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 上一次記錄的音量值，用於比較音量增減方向。
  double _lastVolume = 0.5;

  /// 加速度感測器監聽訂閱物件，用於釋放資源。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 取得目前選中的項目索引。
  int get currentIndex => _currentIndex;

  /// 取得目前導航所在側邊。
  NavSide get currentSide => _currentSide;

  /// 取得目前選中項目的內容。
  String get currentContent => items[_currentIndex].content;

  /// 建構子。
  ///
  /// 建立控制器時，會立即初始化：
  /// - 感測器監聽
  /// - 音量控制監聽
  HomeController() {
    _initSensors();
    _initVolumeControl();
  }

  /// 初始化音量控制相關功能。
  ///
  /// 流程說明：
  /// 1. 關閉系統原生音量 UI。
  /// 2. 讀取目前音量作為初始比較基準。
  /// 3. 監聽音量變化：
  ///    - 音量增加時切換到上一個項目
  ///    - 音量減少時切換到下一個項目
  /// 4. 為避免音量到達極值後無法繼續觸發，
  ///    當音量到 1.0 或 0.0 時，會稍微拉回。
  void _initVolumeControl() async {
    // 隱藏系統預設音量 UI，避免操作時跳出原生音量提示。
    await FlutterVolumeController.updateShowSystemUI(false);

    // 讀取目前系統音量，若取得失敗則預設為 0.5。
    _lastVolume = await FlutterVolumeController.getVolume() ?? 0.5;

    // 監聽音量變化事件。
    FlutterVolumeController.addListener((volume) {
      // 若音量比上次大，視為使用者按了音量增加鍵，
      // 切換到上一個項目。
      if (volume > _lastVolume) {
        previousItem();
      }
      // 若音量比上次小，視為使用者按了音量減少鍵，
      // 切換到下一個項目。
      else if (volume < _lastVolume) {
        nextItem();
      }

      // 更新最後一次音量記錄值。
      _lastVolume = volume;

      // 若音量已達上限，稍微往下降一點，
      // 避免卡在最大值時後續無法再觸發增加事件。
      if (volume >= 1.0) {
        FlutterVolumeController.setVolume(0.9);
        _lastVolume = 0.9;
      }
      // 若音量已達下限，稍微往上調一點，
      // 避免卡在最小值時後續無法再觸發減少事件。
      else if (volume <= 0.0) {
        FlutterVolumeController.setVolume(0.1);
        _lastVolume = 0.1;
      }
    });
  }

  /// 切換到下一個項目。
  ///
  /// 使用取餘數方式，讓索引超過尾端後回到開頭，
  /// 形成循環切換效果。
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length;

    // 通知所有監聽者更新畫面。
    notifyListeners();
  }

  /// 切換到上一個項目。
  ///
  /// 使用循環索引方式，讓索引減到 0 以下時回到最後一個項目。
  void previousItem() {
    _currentIndex = (_currentIndex - 1 + items.length) % items.length;

    // 通知所有監聽者更新畫面。
    notifyListeners();
  }

  /// 直接切換到指定索引的項目。
  ///
  /// [index] 為欲切換的目標索引。
  void changeIndex(int index) {
    _currentIndex = index;

    // 通知所有監聽者更新畫面。
    notifyListeners();
  }

  /// 初始化加速度感測器監聽。
  ///
  /// 依據裝置在 X 軸方向的傾斜程度判斷導航位置：
  /// - `event.x > 2.5`：切換為左側
  /// - `event.x < -2.5`：切換為右側
  void _initSensors() {
    // 開始監聽加速度感測器事件流。
    _sensorSub = accelerometerEventStream().listen((event) {
      // 裝置往某一方向傾斜時，更新導航側邊。
      if (event.x > 2.5) {
        _updateSide(NavSide.left);
      } else if (event.x < -2.5) {
        _updateSide(NavSide.right);
      }
    });
  }

  /// 更新目前導航側邊。
  ///
  /// 僅當側邊真的發生變化時才通知 UI，
  /// 避免不必要的重繪。
  void _updateSide(NavSide side) {
    // 只有在新側邊與目前側邊不同時才更新。
    if (_currentSide != side) {
      _currentSide = side;

      // 通知所有監聽者更新畫面。
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // 取消感測器監聽，避免記憶體洩漏。
    _sensorSub?.cancel();

    // 移除音量監聽器，釋放相關資源。
    FlutterVolumeController.removeListener();

    // 呼叫父類別的 dispose。
    super.dispose();
  }
}
