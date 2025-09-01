/// 匯入 Dart 非同步功能，例如 [StreamSubscription]。
library;

import 'dart:async';

/// 匯入 Flutter Material 元件庫。
import 'package:flutter/material.dart';

/// 匯入感測器套件，用於監聽加速度感測器事件。
import 'package:sensors_plus/sensors_plus.dart';

/// 匯入系統音量控制套件，用於監聽或調整裝置音量。
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

/// 匯入圖片選擇器套件，用於選取裝置中的圖片。
import 'package:image_picker/image_picker.dart';

/// 匯入首頁資料模型定義。
import 'home_model.dart';

import 'dart:convert'; // 用於將資料轉為 JSON 字串，例如 jsonEncode
import 'package:shared_preferences/shared_preferences.dart'; // 用於本機儲存簡單設定與資料
import 'dart:io'; // 用於存取平台與檔案系統相關 API
import 'package:flutter/foundation.dart'; // 用於 kIsWeb 判斷目前是否執行於 Web 平台

/// 使用 `part` 將控制器拆分為多個檔案，以便共用私有成員。
///
/// 將資料邏輯拆分到獨立的 part 檔案，
/// 但仍與目前檔案屬於同一個 library，
/// 因此可以共用私有成員（例如 `_currentIndex`、`_currentSide` 等）。
part 'home_controller_data.part.dart';

/// 感測器相關邏輯模組。
part 'home_controller_sensors.part.dart';

/// 音量控制相關邏輯模組。
part 'home_controller_volume.part.dart';

/// 導航方向列舉。
///
/// 用來表示目前操作或切換的方向是左側還是右側。
enum NavSide {
  /// 左側方向。
  left,

  /// 右側方向。
  right,
}

/// 首頁控制器。
///
/// 負責管理首頁目前顯示的項目、左右側狀態與音量控制狀態，
/// 並整合資料初始化、感測器初始化與音量控制初始化等功能。
///
/// 透過 `ChangeNotifier` 提供狀態通知能力，讓 UI 在資料變動時可即時更新。
class HomeController extends ChangeNotifier
    with HomeControllerData, HomeControllerSensors, HomeControllerVolume {
  /// 是否已完成控制器初始化。
  bool _isInitialized = false;

  /// 是否已完成控制器初始化。
  bool get isInitialized => _isInitialized;

  /// 儲存首頁所有可顯示的項目清單。
  List<HomeItem> items = [];

  /// 目前顯示中的項目索引。
  int _currentIndex = 0;

  /// 目前導覽所在的側邊，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 記錄上一個音量值，預設為 `0.5`。
  double _lastVolume = 0.5;

  /// 加速度感測器的訂閱物件，用於後續取消監聽。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 目前顯示項目的索引。
  int get currentIndex => _currentIndex;

  /// 目前導覽所在的側邊。
  NavSide get currentSide => _currentSide;

  /// 建立首頁控制器並啟動初始化流程。
  ///
  /// 建立控制器時，會依序初始化：
  /// 1. 資料內容
  /// 2. 感測器監聽
  /// 3. 音量控制邏輯
  HomeController() {
    _setup();
  }

  /// 執行控制器初始化流程。
  ///
  /// 會先完成資料初始化，更新初始化狀態並通知 UI。
  /// 若目前平台為 Web，或不是 Android / iOS，則不啟用感測器與音量控制功能。
  Future<void> _setup() async {
    await initData(); // 等待 `home_controller_data.part.dart` 中的資料初始化完成
    _isInitialized = true; // 標記初始化完成
    notifyListeners(); // 通知監聽者更新初始化後的畫面狀態
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return; // 非支援平台時直接略過感測器與音量控制初始化
    }
    _initSensors(); // 初始化感測器監聽
    _initVolumeControl(); // 初始化音量控制監聽
  }

  /// 取得目前應顯示的首頁項目。
  ///
  /// 當 [items] 尚未有資料時，會回傳一個暫時的載入中佔位項目，
  /// 以避免 UI 在初始化期間發生錯誤。
  ///
  /// 同時會對目前索引進行邊界保護，避免索引超出清單範圍。
  HomeItem get currentItem {
    if (items.isEmpty) {
      // 回傳暫時的載入中佔位項目，避免清單為空時發生錯誤
      return HomeItem(
        title: 'Loading...',
        content: '',
        icon: Icons.hourglass_empty,
      );
    }
    // 確保索引不會超出目前項目清單範圍
    final index = _currentIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);
    return items[index];
  }

  /// 切換到下一個項目。
  ///
  /// 若目前已是最後一個項目，則會回到第一個項目。
  /// 供 Mixin 共用呼叫的基礎翻頁方法。
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length; // 以循環方式切換到下一個項目
    notifyListeners(); // 通知監聽者更新 UI
  }

  /// 切換到前一個項目。
  ///
  /// 若目前已是第一個項目，則會跳到最後一個項目。
  void previousItem() {
    _currentIndex =
        (_currentIndex - 1 + items.length) % items.length; // 以循環方式切換到前一個項目
    notifyListeners(); // 通知監聽者更新 UI
  }

  /// 直接切換到指定索引的項目。
  ///
  /// 只有當指定索引與目前索引不同時，才會更新狀態並通知 UI。
  ///
  /// [index] 要切換到的目標項目索引。
  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index; // 更新目前項目索引
      notifyListeners(); // 通知監聽者重新整理畫面
    }
  }

  /// 釋放控制器所使用的資源。
  ///
  /// 會取消感測器訂閱、移除音量監聽器，最後呼叫父類別的 [dispose]。
  @override
  void dispose() {
    _sensorSub?.cancel(); // 取消感測器訂閱，避免資源未釋放
    FlutterVolumeController.removeListener(); // 移除音量監聽器
    super.dispose(); // 呼叫父類別釋放資源
  }
}
