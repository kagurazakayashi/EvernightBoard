part of 'home_controller.dart';

/// 感測器相關控制邏輯的 Mixin。
///
/// 負責：
/// - 初始化加速度感測器事件監聽
/// - 根據裝置左右傾斜方向切換導覽側邊狀態
///
/// 此 Mixin 設計為掛載在 [HomeController] 上，
/// 因此內部會透過 `this as HomeController` 取得實際控制器實例。
mixin HomeControllerSensors on ChangeNotifier {
  /// 初始化感測器監聽。
  ///
  /// 目前透過加速度感測器事件流 `accelerometerEventStream()` 監聽裝置傾斜：
  /// - 當 `event.x > 2.5` 時，判定為切換到左側
  /// - 當 `event.x < -1` 時，判定為切換到右側
  ///
  /// 監聽訂閱會儲存在 `HomeController` 的 `_sensorSub` 中，
  /// 以便後續由控制器生命週期統一管理與釋放。
  void _initSensors() {
    // 取得實際的 HomeController 實例，
    // 以便存取其私有欄位與方法。
    final self = this as HomeController;

    // 建立加速度感測器事件監聽，並保存訂閱物件。
    self._sensorSub = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // 當 X 軸數值大於門檻時，視為裝置往特定方向傾斜，
        // 這裡對應切換為左側導覽。
        if (event.x > 2.5) {
          _updateSide(NavSide.left);

          // 當 X 軸數值小於負向門檻時，
          // 視為裝置往另一側傾斜，切換為右側導覽。
        } else if (event.x < -1) {
          _updateSide(NavSide.right);
        }
      },
      // 感測器事件流發生例外時輸出除錯訊息。
      onError: (error) {
        debugPrint('传感器流异常: $error');
      },
      // 發生錯誤後自動取消監聽，避免持續接收異常事件。
      cancelOnError: true,
    );
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

      // 通知所有監聽者（例如 UI）重新建構畫面。
      notifyListeners();
    }
  }
}
