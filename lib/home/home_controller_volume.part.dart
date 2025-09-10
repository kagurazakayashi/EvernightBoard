part of 'home_controller.dart';

/// 音量控制相關功能的 Mixin。
///
/// 此 Mixin 提供透過系統音量鍵切換項目的控制邏輯：
/// - 音量增加時，切換到上一個項目
/// - 音量減少時，切換到下一個項目
///
/// 同時會嘗試關閉系統原生音量 UI，避免使用者在操作時看到系統音量提示，
/// 並在音量到達極限值時自動拉回到安全範圍內，讓音量鍵事件可持續被觸發。
mixin HomeControllerVolume on ChangeNotifier {
  /// 初始化音量鍵控制功能。
  ///
  /// 執行流程如下：
  /// 1. 取得 [HomeController] 實例
  /// 2. 關閉系統音量 UI 顯示
  /// 3. 讀取目前系統音量作為初始比較基準
  /// 4. 註冊音量變化監聽
  /// 5. 根據音量增加或減少來切換項目
  /// 6. 當音量達到 0.0 或 1.0 時，自動調整回中間區間，避免卡在邊界
  ///
  /// 此方法為非同步流程，但不需要由呼叫端等待完成。
  void _initVolumeControl() async {
    // 將目前 mixin 宿主轉型為 HomeController，以便存取控制器內部狀態與方法。
    final self = this as HomeController;

    debugPrint('[HomeControllerVolume] 開始初始化音量鍵控制');

    // 關閉系統原生音量 UI，避免使用音量鍵時跳出系統提示視窗。
    await FlutterVolumeController.updateShowSystemUI(false);

    // 取得目前系統音量作為初始值；若無法取得則預設為 0.5。
    self._lastVolume = await FlutterVolumeController.getVolume() ?? 0.5;
    debugPrint('[HomeControllerVolume] 目前初始音量：${self._lastVolume}');

    // 註冊音量變化監聽器。
    FlutterVolumeController.addListener((volume) {
      // 若未啟用音量鍵控制，僅同步記錄最新音量，不執行切換邏輯。
      if (!self.useVolumeKeys) {
        self._lastVolume = volume;
        return;
      }

      // 若目前音量大於前一次音量，表示使用者按了音量增加鍵。
      if (volume > self._lastVolume) {
        debugPrint('[HomeControllerVolume] 偵測到音量增加，切換到上一個項目');
        self.previousItem();

        // 若目前音量小於前一次音量，表示使用者按了音量減少鍵。
      } else if (volume < self._lastVolume) {
        debugPrint('[HomeControllerVolume] 偵測到音量減少，切換到下一個項目');
        self.nextItem();
      }

      // 更新最新音量值，作為下一次比較基準。
      self._lastVolume = volume;

      // 若音量已到最大值，主動往回調降一點，
      // 避免卡在 1.0 導致後續無法再觸發增加事件。
      if (volume >= 1.0) {
        debugPrint('[HomeControllerVolume] 音量已達上限，自動回調至 0.9');
        FlutterVolumeController.setVolume(0.9);
        self._lastVolume = 0.9;

        // 若音量已到最小值，主動往上調高一點，
        // 避免卡在 0.0 導致後續無法再觸發減少事件。
      } else if (volume <= 0.0) {
        debugPrint('[HomeControllerVolume] 音量已達下限，自動回調至 0.1');
        FlutterVolumeController.setVolume(0.1);
        self._lastVolume = 0.1;
      }

      // 通知監聽者狀態已更新。
      notifyListeners();
    });

    debugPrint('[HomeControllerVolume] 音量鍵控制初始化完成');
  }
}
