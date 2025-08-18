import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'home_model.dart';

/// 導航方向列舉。
///
/// 用於表示目前導覽提示或切換方向位於左側或右側。
enum NavSide { left, right }

/// 首頁控制器。
///
/// 負責管理首頁展示資料、目前選取項目、裝置感測器監聽、
/// 音量鍵切換項目，以及狀態變更通知給 View。
class HomeController extends ChangeNotifier {
  /// 定義單一 Demo 項目資料清單。
  ///
  /// 目前以 `late final` 建立，會在建構時透過 `_initData()` 完成初始化。
  late final List<HomeItem> items;

  /// 目前顯示中的項目索引。
  int _currentIndex = 0;

  /// 目前導覽方向，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 上一次記錄的音量值。
  ///
  /// 用來判斷使用者是按了音量增加還是減少。
  double _lastVolume = 0.5;

  /// 加速度感測器訂閱物件。
  ///
  /// 在 `dispose()` 時需要取消訂閱，避免資源洩漏。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 取得目前項目索引。
  int get currentIndex => _currentIndex;

  /// 取得目前導覽方向。
  NavSide get currentSide => _currentSide;

  /// 方便 View 直接取得目前顯示中的項目。
  HomeItem get currentItem => items[_currentIndex];

  /// 建構子。
  ///
  /// 建立控制器時，會依序初始化：
  /// 1. 畫面資料
  /// 2. 感測器監聽
  /// 3. 音量控制監聽
  HomeController() {
    _initData(); // 初始化展示資料
    _initSensors(); // 初始化加速度感測器監聽
    _initVolumeControl(); // 初始化音量鍵控制
  }

  /// 初始化首頁資料。
  ///
  /// 目前僅建立一筆 Demo 資料，可後續擴充為多筆項目。
  void _initData() {
    // 實例化 Demo 項目，設定標題、內容、圖示、文字顏色、背景顏色與背景圖片。
    items = [
      HomeItem(
        title: 'Demo',
        content: 'Demo',
        icon: Icons.widgets_rounded,
        textColor: Colors.white, // 有背景圖時此顏色可能不會顯示，仍保留以提升程式健壯性。
        backgroundColor: Colors.grey[900]!, // 當圖片使用 contain 顯示時，兩側露出的底色。
        backgroundImagePath: 'assets/default.png', // 指定測試用背景圖片路徑。
      ),
    ];
  }

  // --- 邏輯部分 (保持不變，已修復 if block) ---

  /// 初始化音量控制監聽。
  ///
  /// 功能說明：
  /// - 隱藏系統原生音量 UI
  /// - 讀取目前音量作為初始基準值
  /// - 監聽音量變化，並依音量增減切換上一個或下一個項目
  /// - 避免音量到達 0 或 1，防止後續無法持續觸發切換
  void _initVolumeControl() async {
    // 關閉系統預設音量顯示 UI，避免影響畫面體驗。
    await FlutterVolumeController.updateShowSystemUI(false);

    // 取得目前系統音量，若讀取失敗則使用 0.5 作為預設值。
    _lastVolume = await FlutterVolumeController.getVolume() ?? 0.5;

    // 監聽音量變化。
    FlutterVolumeController.addListener((volume) {
      // 音量上升時，切換到前一個項目。
      if (volume > _lastVolume) {
        previousItem();
      }
      // 音量下降時，切換到下一個項目。
      else if (volume < _lastVolume) {
        nextItem();
      }

      // 更新最後一次記錄的音量值。
      _lastVolume = volume;

      // 若音量已到最大值，稍微拉回 0.9，保留之後繼續增加的空間。
      if (volume >= 1.0) {
        FlutterVolumeController.setVolume(0.9);
        _lastVolume = 0.9;
      }
      // 若音量已到最小值，稍微拉回 0.1，保留之後繼續降低的空間。
      else if (volume <= 0.0) {
        FlutterVolumeController.setVolume(0.1);
        _lastVolume = 0.1;
      }
    });
  }

  /// 切換到下一個項目。
  ///
  /// 使用循環索引，超過最後一項時會回到第一項。
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length;
    notifyListeners(); // 通知畫面更新
  }

  /// 切換到上一個項目。
  ///
  /// 使用循環索引，當前為第一項時會回到最後一項。
  void previousItem() {
    _currentIndex = (_currentIndex - 1 + items.length) % items.length;
    notifyListeners(); // 通知畫面更新
  }

  /// 依指定索引切換目前項目。
  ///
  /// 只有當索引與目前索引不同時，才會更新並通知監聽者。
  ///
  /// [index] 欲切換的目標索引。
  void changeIndex(int index) {
    // 避免重複設定相同索引，減少不必要的畫面更新。
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners(); // 通知畫面更新
    }
  }

  /// 初始化加速度感測器監聽。
  ///
  /// 根據裝置 X 軸傾斜方向，更新目前導覽方向：
  /// - X 軸大於 2.5：判定為左側
  /// - X 軸小於 -2.5：判定為右側
  void _initSensors() {
    // 訂閱加速度感測器資料流。
    _sensorSub = accelerometerEventStream().listen((event) {
      // 裝置朝某一方向傾斜時，更新為左側導覽。
      if (event.x > 2.5) {
        _updateSide(NavSide.left);
      }
      // 裝置朝相反方向傾斜時，更新為右側導覽。
      else if (event.x < -2.5) {
        _updateSide(NavSide.right);
      }
    });
  }

  /// 更新目前導覽方向。
  ///
  /// 僅在方向真的改變時才通知監聽者，避免多餘重繪。
  ///
  /// [side] 新的導覽方向。
  void _updateSide(NavSide side) {
    // 只有在方向變更時才更新狀態。
    if (_currentSide != side) {
      _currentSide = side;
      notifyListeners(); // 通知畫面更新
    }
  }

  @override
  void dispose() {
    // 取消感測器訂閱，避免記憶體洩漏。
    _sensorSub?.cancel();

    // 移除音量監聽器。
    FlutterVolumeController.removeListener();

    // 呼叫父類別釋放資源。
    super.dispose();
  }
}
