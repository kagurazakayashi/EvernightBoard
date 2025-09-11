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

// 匯入匯出
import '../settings/data_export_service.dart';

/// 使用 `part` 將控制器拆分為多個檔案，以利將不同職責的邏輯模組化。
///
/// 這些 `part` 檔案與目前檔案屬於同一個 library，
/// 因此可以直接存取彼此的私有成員，適合拆分控制器內部實作。
part 'home_controller_data.part.dart';

/// 感測器相關邏輯模組。
part 'home_controller_sensors.part.dart';

/// 音量控制相關邏輯模組。
part 'home_controller_volume.part.dart';

/// 導覽方向列舉，用來表示目前操作或切換所屬的側別。
enum NavSide {
  /// 左側方向。
  left,

  /// 右側方向。
  right,
}

/// 首頁控制器，負責管理首頁畫面狀態與互動邏輯。
///
/// 主要職責包含：
/// - 初始化首頁資料
/// - 管理目前顯示項目與切換索引
/// - 初始化感測器與音量監聽
/// - 在狀態改變時通知 UI 更新
///
/// 透過混入（mixin）將資料、感測器與音量邏輯拆分到不同 part 檔案中，
/// 讓主控制器保留一致的對外操作介面。
class HomeController extends ChangeNotifier
    with HomeControllerData, HomeControllerSensors, HomeControllerVolume {
  /// 表示控制器是否已完成初始化。
  ///
  /// 此欄位會在 [_setup] 完成資料初始化後設為 `true`。
  @override
  bool _isInitialized = false;

  /// 控制器初始化狀態。
  ///
  /// 可供 UI 判斷是否已可安全讀取控制器中的主要資料。
  @override
  bool get isInitialized => _isInitialized;

  /// 首頁所有可顯示項目的集合。
  ///
  /// 內容通常會在初始化資料流程中載入與更新。
  List<HomeItem> items = [];

  /// 目前顯示中的項目索引。
  int _currentIndex = 0;

  /// 目前導覽所在側別，預設為右側。
  NavSide _currentSide = NavSide.right;

  /// 記錄上一個系統音量值。
  ///
  /// 可用於比對音量變化方向或避免重複處理相同音量事件。
  double _lastVolume = 0.5;

  /// 加速度感測器訂閱物件。
  ///
  /// 控制器釋放時需取消訂閱，以避免資源洩漏。
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  /// 目前顯示項目的索引。
  int get currentIndex => _currentIndex;

  /// 目前導覽所在側別。
  NavSide get currentSide => _currentSide;

  /// 建立首頁控制器並立即啟動初始化流程。
  ///
  /// 初始化流程包含：
  /// 1. 載入首頁資料
  /// 2. 標記初始化完成並通知 UI
  /// 3. 在支援的平台上啟用感測器與音量控制
  HomeController() {
    debugPrint('[HomeController] 建立控制器並開始初始化流程');
    _setup();
  }

  /// 執行控制器初始化流程。
  ///
  /// 會先完成資料初始化，再更新初始化狀態並通知 UI。
  /// 若目前平台為 Web，或不是 Android / iOS，則略過感測器與音量控制初始化。
  Future<void> _setup() async {
    debugPrint('[HomeController] 開始執行初始化');

    await initData(); // 等待首頁資料初始化完成

    _isInitialized = true; // 標記初始化完成
    notifyListeners(); // 通知監聽者更新畫面

    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('[HomeController] 目前平台不支援感測器或音量監聽，略過相關初始化');
      return; // 非支援平台略過感測器與音量初始化
    }

    _initSensors(); // 初始化感測器監聽
    _initVolumeControl(); // 初始化音量控制
    debugPrint('[HomeController] 初始化完成');
  }

  /// 取得目前應顯示的首頁項目。
  ///
  /// 當 [items] 尚未載入完成時，回傳暫時的佔位資料，
  /// 以避免 UI 在存取內容時發生錯誤。
  ///
  /// 同時會對索引做邊界保護，避免因索引超出範圍而拋出例外。
  HomeItem get currentItem {
    if (items.isEmpty) {
      debugPrint('[HomeController] 目前項目清單為空，回傳載入中佔位項目');

      return HomeItem(
        title: 'Loading...',
        content: '',
        icon: Icons.hourglass_empty,
      );
    }

    // 邊界保護，避免索引超出清單範圍。
    final index = _currentIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);
    return items[index];
  }

  /// 切換到下一個項目，並在尾端時循環回到第一個項目。
  void nextItem() {
    if (items.isEmpty) {
      debugPrint('[HomeController] 項目清單為空，無法切換到下一個項目');
      return;
    }

    _currentIndex = (_currentIndex + 1) % items.length; // 循環切換
    debugPrint('[HomeController] 切換到下一個項目，currentIndex=$_currentIndex');
    notifyListeners(); // 通知 UI 更新
  }

  /// 切換到前一個項目，並在開頭時循環回到最後一個項目。
  void previousItem() {
    if (items.isEmpty) {
      debugPrint('[HomeController] 項目清單為空，無法切換到前一個項目');
      return;
    }

    _currentIndex = (_currentIndex - 1 + items.length) % items.length; // 循環切換
    debugPrint('[HomeController] 切換到前一個項目，currentIndex=$_currentIndex');
    notifyListeners(); // 通知 UI 更新
  }

  /// 直接切換到指定索引的項目。
  ///
  /// 只有在目標索引與目前索引不同時才會更新狀態，
  /// 以避免不必要的重繪通知。
  ///
  /// [index] 目標項目索引。
  void changeIndex(int index) {
    if (items.isEmpty) {
      debugPrint('[HomeController] 項目清單為空，無法變更索引');
      return;
    }

    if (index < 0 || index >= items.length) {
      debugPrint('[HomeController] 索引超出範圍，忽略變更請求：index=$index');
      return;
    }

    if (_currentIndex != index) {
      _currentIndex = index; // 更新索引
      debugPrint('[HomeController] 已變更目前索引，currentIndex=$_currentIndex');
      notifyListeners(); // 通知 UI 更新
    }
  }

  /// 釋放控制器資源。
  ///
  /// 會取消感測器訂閱、移除音量監聽器，
  /// 最後呼叫父類別的 [dispose] 完成清理。
  @override
  void dispose() {
    debugPrint('[HomeController] 釋放控制器資源');

    _sensorSub?.cancel(); // 取消感測器訂閱
    FlutterVolumeController.removeListener(); // 移除音量監聽

    super.dispose(); // 呼叫父類別釋放資源
  }
}
