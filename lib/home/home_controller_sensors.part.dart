part of 'home_controller.dart';

/// 感測器相關控制邏輯的 Mixin。
///
/// 負責：
/// - 初始化加速度感測器事件監聽
/// - 根據裝置左右傾斜方向切換導覽側邊狀態
///
/// 設計上此 Mixin 會掛載在 [HomeController] 上，
/// 因此內部會透過 `this as HomeController` 取得實際控制器實例。
mixin HomeControllerSensors on ChangeNotifier {
  /// 初始化感測器監聽。
  ///
  /// 目前使用加速度感測器事件流 `accelerometerEventStream()`：
  /// - 當 `event.x > 2.5` 時，判定為切換到左側
  /// - 當 `event.x < -2.5` 時，判定為切換到右側
  ///
  /// 監聽訂閱會儲存在 `HomeController` 的 `_sensorSub` 中，
  /// 以便後續可由控制器生命週期進行管理與釋放。
  void _initSensors() {
    // 將目前的 mixin 實例轉型為實際的 HomeController，
    // 以便存取其私有欄位與方法。
    final self = this as HomeController;

    // 建立加速度感測器事件監聽，並保存訂閱物件。
    self._sensorSub = accelerometerEventStream().listen((event) {
      // 當 X 軸數值大於門檻時，視為裝置往特定方向傾斜，
      // 這裡對應切換為左側導覽。
      if (event.x > 2.5) {
        _updateSide(NavSide.left);

        // 當 X 軸數值小於負向門檻時，
        // 視為裝置往另一側傾斜，切換為右側導覽。
      } else if (event.x < -2.5) {
        _updateSide(NavSide.right);
      }
    });
  }

  /// 更新目前顯示的導覽側邊。
  ///
  /// 只有在目標側邊與目前狀態不同時，才會：
  /// 1. 更新 `_currentSide`
  /// 2. 呼叫 [notifyListeners] 通知 UI 重建
  ///
  /// 這樣可避免重複設定相同值而造成不必要的畫面刷新。
  void _updateSide(NavSide side) {
    // 取得實際的 HomeController 實例。
    final self = this as HomeController;

    // 僅在狀態真的有變更時才更新並通知監聽者。
    if (self._currentSide != side) {
      // 更新目前側邊狀態。
      self._currentSide = side;

      // 通知所有監聽者（例如 UI）進行刷新。
      notifyListeners(); // 正常使用
    }
  }
}
