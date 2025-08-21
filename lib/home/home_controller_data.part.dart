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

    // 建立首頁預設項目。
    self.items = [
      HomeItem(
        title: 'Default', // 导航栏显示的标题
        content: '', // 屏幕显示文字为空
        icon: Icons.blur_on, // 随便选一个默认图标
        backgroundImagePath: '', // 图片路径为空
        // backgroundColor 和 textColor 将使用 HomeItem 里的构造函数默认值
      ),
    ];
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
        content: '新内容',
        icon: Icons.add_circle_outline,
        backgroundColor: Colors.blueGrey[900]!,
        textColor: Colors.white,
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
    // 轉型為 `HomeController`，以便存取其狀態與私有成員。
    final self = this as HomeController;

    // 若目前只剩一個項目，則不執行刪除，
    // 以避免清單變成空集合。
    if (self.items.length <= 1) return;

    // 刪除目前索引對應的項目。
    self.items.removeAt(self._currentIndex);

    // 若刪除後目前索引已超出清單範圍，
    // 則將索引調整為最後一個有效位置。
    if (self._currentIndex >= self.items.length) {
      self._currentIndex = self.items.length - 1;
    }

    // 通知監聽者資料已更新。
    notifyListeners();
  }
}
