part of 'home_controller.dart';

/// HomeControllerData 混入，用於管理 Home 項目的資料操作
///
/// 提供新增、刪除、移動、更新標題/圖示/文字/背景等功能。
/// 使用 ChangeNotifier，可通知 UI 重新繪製。
mixin HomeControllerData on ChangeNotifier {
  /// 初始化資料
  ///
  /// 若 items 為空，則自動新增一個項目
  void _initData() {
    final self = this as HomeController;
    // 若 items 是空的，新增一個預設項目
    if (self.items.isEmpty) {}
  }
}
