part of 'home_controller.dart';

/// 感測器相關控制邏輯的 Mixin。
///
/// 主要負責：
/// - 初始化加速度感測器事件監聽
/// - 根據裝置傾斜方向更新目前導覽側別
///
/// 此 Mixin 會掛載在 [HomeController] 上，
/// 因此內部透過 `this as HomeController` 取得實際控制器實例，
/// 以便存取控制器中的狀態與私有成員。
mixin HomeControllerSensors on ChangeNotifier {
  /// 初始化加速度感測器監聽。
  ///
  /// 目前透過 `accelerometerEventStream()` 監聽裝置傾斜狀態
  /// - 當 `event.x > y` 時，判定為切換到左側
  /// - 當 `event.x < y` 時，判定為切換到右側
  ///
  /// 建立的訂閱會存放到 [HomeController] 的 `_sensorSub`，
  /// 以利控制器在 `dispose()` 時統一取消監聽，避免資源未釋放。
  void _initSensors() {
    // 取得實際的 HomeController 實例，
    // 以便存取其私有欄位與狀態。
    final self = this as HomeController;

    debugPrint('[HomeControllerSensors] 開始初始化加速度感測器監聽');

    // 建立加速度感測器事件監聽，並保存訂閱物件。
    self._sensorSub = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // 當 X 軸數值大於門檻時，
        // 視為裝置朝特定方向傾斜，對應切換為左側導覽。
        if (event.x > 1) {
          _updateSide(NavSide.left);

          // 當 X 軸數值小於負向門檻時，
          // 視為裝置朝另一方向傾斜，對應切換為右側導覽。
        } else if (event.x < -1) {
          _updateSide(NavSide.right);
        }
      },

      // 感測器事件流發生例外時輸出除錯訊息。
      onError: (error) {
        debugPrint('[HomeControllerSensors] 感測器事件流發生異常：$error');
      },

      // 發生錯誤後自動取消監聽，避免持續接收異常事件。
      cancelOnError: true,
    );
  }

  /// 更新目前顯示的導覽側別。
  ///
  /// 只有當目標側別與目前狀態不同時，才會：
  /// 1. 更新 `_currentSide`
  /// 2. 呼叫 [notifyListeners] 通知 UI 重建
  ///
  /// 這樣可以避免重複設定相同值，減少不必要的畫面刷新。
  void _updateSide(NavSide side) {
    // 取得實際的 HomeController 實例。
    final self = this as HomeController;

    // 僅在狀態實際改變時才更新並通知監聽者。
    if (self._currentSide != side) {
      // 更新目前導覽側別。
      self._currentSide = side;

      debugPrint('[HomeControllerSensors] 已切換導覽側別：$side');

      // 通知所有監聽者（例如 UI）重新建構畫面。
      notifyListeners();
    }
  }
}
