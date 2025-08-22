part of 'home_controller.dart';

/// 提供 HomeController 所需的資料初始化與項目管理功能。
///
/// 設計重點：
/// - 使用 `mixin` 讓功能可被混入主控制器。
/// - 透過 `on ChangeNotifier` 限制此 mixin 只能套用在
///   `ChangeNotifier` 的子類別上。
/// - 因此在 mixin 內可以直接呼叫 `notifyListeners()`，
///   以通知 UI 或其他監聽者進行更新。
///
/// 注意：
/// 由於此檔案使用 `part of 'home_controller.dart';`，且最終會混入
/// `HomeController`，所以可透過型別轉型存取 `HomeController` 的私有成員。
mixin HomeControllerData on ChangeNotifier {
  /// 初始化首頁資料。
  ///
  /// 此方法會建立預設的 `items` 清單，提供初始畫面顯示內容。
  void _initData() {
    // 因為此檔案屬於 `home_controller.dart` 的 part，
    // 且此 mixin 最終會混入 `HomeController`，
    // 所以這裡可透過型別轉型存取 `HomeController` 的私有欄位。
    final self = this as HomeController;
    // 初始化時如果列表為空，自動加一個
    if (self.items.isEmpty) {
      addItem();
    }
  }

  /// 新增一個項目到清單尾端。
  ///
  /// 新增完成後，會將目前索引切換到新加入的項目，
  /// 並呼叫 `notifyListeners()` 讓外部更新畫面。
  void addItem() {
    // 轉型為 `HomeController`，以便存取其狀態與私有成員。
    final self = this as HomeController;

    // 新增一筆預設項目。
    self.items.add(
      HomeItem(
        title: '新增项',
        content: '', // 文字内容为空
        icon: Icons.add_to_photos,
        textColor: null, // 使用系统默认
        backgroundColor: null, // 使用系统默认
        backgroundImagePath: '', // 路径为空，触发默认图回退
      ),
    );

    // 將目前選取索引移到最新加入的項目。
    self._currentIndex = self.items.length - 1;

    // 由於此 mixin 受 `on ChangeNotifier` 約束，
    // 因此這裡可安全呼叫 `notifyListeners()` 而不會報錯。
    notifyListeners();
  }

  /// 刪除目前選取的項目。
  ///
  /// 保留至少一個項目，避免清單被刪空。
  /// 若刪除後目前索引超出範圍，會自動修正到最後一個有效位置。
  void deleteCurrentItem() {
    final self = this as HomeController;

    // 執行刪除
    self.items.removeAt(self._currentIndex);

    // 如果刪完後沒項了，自動加一個
    if (self.items.isEmpty) {
      addItem();
    } else {
      // 如果還有項，調整索引防止溢位
      if (self._currentIndex >= self.items.length) {
        self._currentIndex = self.items.length - 1;
      }
      // 通知所有監聽者（例如 UI）進行刷新。
      notifyListeners();
    }
  }
}
