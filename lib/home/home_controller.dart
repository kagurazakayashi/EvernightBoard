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

/// 匯入檔案服務，用於本機檔案讀寫。
import 'file_service.dart';

/// 匯入 JSON 編碼功能，用於將資料轉為 JSON 字串。
import 'dart:convert';

/// 匯入本機簡單資料儲存套件，用於儲存設定與狀態。
import 'package:shared_preferences/shared_preferences.dart';

/// 匯入平台與檔案系統相關 API。
import 'dart:io';

/// 匯入 Flutter 基礎工具，例如判斷是否在 Web 平台。
import 'package:flutter/foundation.dart';

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

/// 導航方向列舉，用來表示操作或切換的方向。
enum NavSide {
  /// 左側方向。
  left,

  /// 右側方向。
  right,
}

/// 首頁控制器，負責管理首頁 UI 與邏輯。
///
/// 包含資料初始化、感測器監聽、音量控制與導航操作。
/// 繼承自 `ChangeNotifier`，可在資料更新時通知 UI。
class HomeController extends ChangeNotifier
    with HomeControllerData, HomeControllerSensors, HomeControllerVolume {
  /// 控制器是否已初始化完成。
  @override
  bool _isInitialized = false;

  /// 控制器初始化狀態的 getter。
  @override
  bool get isInitialized => _isInitialized;

  /// 儲存首頁所有可顯示的項目清單。
  List<HomeItem> items = [];

  /// 目前顯示的項目索引。
  int _currentIndex = 0;

  /// 目前導覽所在的側邊，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 記錄上一個音量值，預設為 `0.5`。
  double _lastVolume = 0.5;

  /// 加速度感測器的訂閱物件，用於取消監聽。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 目前顯示項目的索引。
  int get currentIndex => _currentIndex;

  /// 目前導覽所在的側邊。
  NavSide get currentSide => _currentSide;

  /// 建立首頁控制器並啟動初始化流程。
  ///
  /// 初始化流程依序完成：
  /// 1. 資料內容初始化
  /// 2. 感測器監聽初始化
  /// 3. 音量控制初始化
  HomeController() {
    _setup();
  }

  /// 執行控制器初始化流程。
  ///
  /// 初始化資料後，更新狀態並通知 UI。
  /// 若目前平台為 Web 或非 Android/iOS，則略過感測器與音量控制。
  Future<void> _setup() async {
    // clearAllData(); // 可選：清除歷史資料
    await initData(); // 等待資料初始化完成
    _isInitialized = true; // 標記初始化完成
    notifyListeners(); // 通知監聽者更新畫面

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return; // 非支援平台略過感測器與音量初始化
    }

    _initSensors(); // 初始化感測器監聽
    _initVolumeControl(); // 初始化音量控制
  }

  /// 取得目前應顯示的首頁項目。
  ///
  /// 若 [items] 尚未有資料，回傳暫時的載入中佔位項目，避免 UI 錯誤。
  HomeItem get currentItem {
    if (items.isEmpty) {
      // 回傳暫時的載入中佔位項目
      return HomeItem(
        title: 'Loading...',
        content: '',
        icon: Icons.hourglass_empty,
      );
    }
    // 邊界保護，避免索引超出清單範圍
    final index = _currentIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);
    return items[index];
  }

  /// 切換到下一個項目，循環顯示。
  void nextItem() {
    _currentIndex = (_currentIndex + 1) % items.length; // 循環切換
    notifyListeners(); // 通知 UI 更新
  }

  /// 切換到前一個項目，循環顯示。
  void previousItem() {
    _currentIndex = (_currentIndex - 1 + items.length) % items.length; // 循環切換
    notifyListeners(); // 通知 UI 更新
  }

  /// 直接切換到指定索引的項目。
  ///
  /// 只有當指定索引與目前索引不同時，才更新狀態並通知 UI。
  ///
  /// [index] 目標項目索引。
  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index; // 更新索引
      notifyListeners(); // 通知 UI 更新
    }
  }

  /// 釋放控制器資源。
  ///
  /// 會取消感測器訂閱、移除音量監聽器，最後呼叫父類別 [dispose]。
  @override
  void dispose() {
    _sensorSub?.cancel(); // 取消感測器訂閱
    FlutterVolumeController.removeListener(); // 移除音量監聽
    super.dispose(); // 呼叫父類別釋放資源
  }
}
