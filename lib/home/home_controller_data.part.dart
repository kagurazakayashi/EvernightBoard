part of 'home_controller.dart';

mixin HomeControllerData on ChangeNotifier {
  static const String _storageKey = 'demo_master_items';

  // 初始化與資料持久化的核心流程

  /// 啟動時載入本機儲存的資料。
  Future<void> initData() async {
    final self = this as HomeController;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(jsonStr);
        self.items.clear();
        self.items.addAll(
          jsonData.map((item) => HomeItem.fromJson(item)).toList(),
        );
        debugPrint('成功从硬盘加载了 ${self.items.length} 个项目');
      } else {
        _setDefaultData();
      }
    } catch (e) {
      debugPrint('加载数据失败，使用默认值: $e');
      _setDefaultData();
    }
    notifyListeners();
  }

  /// 清除所有使用者資料，並還原為預設狀態。
  Future<void> clearAllData() async {
    final self = this as HomeController;

    // 1. 取得持久化儲存實例並移除對應 key
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    // 2. 清空記憶體中的項目列表
    self.items.clear();

    // 3. 還原預設初始資料
    _setDefaultData();

    // 4. 重設目前索引並通知 UI 更新
    self._currentIndex = 0;
    notifyListeners();

    debugPrint('所有用户设置已清除，恢复至默认状态。');
  }

  /// 內部方法：建立初始預設資料。
  void _setDefaultData() {
    addItem();
  }

  /// 將目前項目資料同步寫入本機儲存。
  Future<void> _syncToDisk() async {
    final self = this as HomeController;
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      self.items.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  // 列表管理（新增、刪除、編輯、移動）

  /// 新增一個項目，並自動切換到新建立的項目。
  void addItem() {
    final self = this as HomeController;
    self.items.add(
      HomeItem(
        title: '新项目 ${self.items.length + 1}',
        content: '',
        icon: Icons.star_border,
        backgroundImagePath: '',
      ),
    );
    self._currentIndex = self.items.length - 1;
    notifyListeners();
    _syncToDisk();
  }

  /// 複製目前項目，並將副本插入在原項目後方。
  void copyCurrentItem() {
    final self = this as HomeController;
    final current = self.currentItem;
    final newItem = current.copyWith(title: "${current.title} (副本)");

    self.items.insert(self._currentIndex + 1, newItem);
    self._currentIndex++;
    notifyListeners();
    _syncToDisk();
  }

  /// 刪除目前項目，必要時自動修正索引或補回預設資料。
  void deleteCurrentItem() {
    final self = this as HomeController;
    self.items.removeAt(self._currentIndex);

    // 自動補齊資料的處理邏輯
    if (self.items.isEmpty) {
      clearAllData();
      _setDefaultData();
      self._currentIndex = 0;
    } else if (self._currentIndex >= self.items.length) {
      self._currentIndex = self.items.length - 1;
    }
    notifyListeners();
    _syncToDisk();
  }

  /// 將目前項目往上移動一格，採循環式排序。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;
    final int len = self.items.length;
    // 使用循環位移演算法，讓首項可移到最後一項
    int newIndex = (self._currentIndex - 1 + len) % len;
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);
    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
  }

  /// 將目前項目往下移動一格，採循環式排序。
  void moveDown() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;
    final int len = self.items.length;
    int newIndex = (self._currentIndex + 1) % len;
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);
    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
  }

  // 屬性編輯

  /// 更新目前項目的標題。
  void updateTitle(String newTitle) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(title: newTitle);
    notifyListeners();
    _syncToDisk();
  }

  /// 更新目前項目的圖示。
  void updateIcon(IconData newIcon) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(icon: newIcon);
    notifyListeners();
    _syncToDisk();
  }

  /// 將目前項目設為文字模式，並清空背景圖片路徑。
  void setAsText(String text) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      content: text,
      backgroundImagePath: '', // 切換為文字模式時，清空圖片路徑
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 從相簿選取圖片，並將目前項目切換為圖片模式。
  Future<void> pickImage(double maxDimension) async {
    final self = this as HomeController;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
    );

    if (image != null) {
      self.items[self._currentIndex] = self.currentItem.copyWith(
        content: '', // 切換為圖片模式時，清空文字內容
        backgroundImagePath: image.path,
      );
      notifyListeners();
      _syncToDisk();
    }
  }

  // 顏色管理與檢查

  /// 設定文字顏色；若為 `null`，則表示清除自訂文字顏色。
  void setTextColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 設定背景顏色；若為 `null`，則表示清除自訂背景顏色。
  void setBgColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 檢查兩個顏色是否過於接近（依據 WCAG 相對亮度差異）。
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;
    // 使用 toARGB32() 比對完整色彩值，可更準確判斷是否完全相同
    if (a.toARGB32() == b.toARGB32()) return true;
    // 以相對亮度差作為閾值判斷，差異越小代表越相近
    final double diff = (a.computeLuminance() - b.computeLuminance()).abs();
    return diff < 0.15;
  }

  /// 計算反相色。
  ///
  /// 可用於特殊提示、對比輔助或自動配色調整等情境，
  /// 目前先保留為通用工具方法。
  Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 1.0 - color.r,
      green: 1.0 - color.g,
      blue: 1.0 - color.b,
    );
  }

  /// 判斷兩個顏色是否為完全相同的色值。
  bool isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
}
