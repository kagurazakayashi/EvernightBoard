part of 'home_controller.dart';

mixin HomeControllerData on ChangeNotifier {
  // 是否已完成初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool useVolumeKeys = false; // 預設停用音量鍵
  bool useSideTap = true; // 預設開啟半屏點選

  // 本機儲存資料的 Key
  static const String _storageKey = 'demo_master_items';
  static const String _configKey = 'demo_config_options';
  bool get _isVolumeSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ===============================
  // 初始化與資料持久化流程
  // ===============================

  /// 啟動時載入本機儲存的資料。
  /// 若沒有資料或發生錯誤，會建立預設資料。
  Future<void> initData() async {
    final self = this as HomeController;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        // 將 JSON 字串解析為 HomeItem 列表
        final List<dynamic> jsonData = jsonDecode(jsonStr);
        self.items.clear();
        self.items.addAll(
          jsonData.map((item) => HomeItem.fromJson(item)).toList(),
        );
      } else {
        // 若本地沒有資料，初始化預設項目
        _setDefaultData();
      }
      final String? configJson = prefs.getString(_configKey);
      if (configJson != null) {
        final Map<String, dynamic> config = jsonDecode(configJson);
        useVolumeKeys = _isVolumeSupported
            ? (config['useVolumeKeys'] ?? false)
            : false;
        useSideTap = config['useSideTap'] ?? true;
      }
    } catch (e) {
      // 發生任何錯誤時，初始化預設資料
      _setDefaultData();
    } finally {
      _isInitialized = true; // 標記初始化完成
      notifyListeners();
    }
  }

  Future<void> _syncConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _configKey,
      jsonEncode({'useVolumeKeys': useVolumeKeys, 'useSideTap': useSideTap}),
    );
  }

  void toggleVolumeKeys(bool value) {
    if (!_isVolumeSupported) return;
    useVolumeKeys = value;
    notifyListeners();
    _syncConfig();
  }

  void toggleSideTap(bool value) {
    useSideTap = value;
    _syncConfig();
    notifyListeners();
  }

  /// 清除所有使用者資料，並還原為預設狀態。
  Future<void> clearAllData() async {
    final self = this as HomeController;

    // 1. 刪除所有項目的物理圖片檔案
    for (var item in self.items) {
      await FileService.deleteFile(item.backgroundImagePath);
    }

    // 2. 清除 SharedPreferences 中的儲存 Key
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    // 3. 重置內存資料與索引
    self.items.clear();
    _setDefaultData();
    self._currentIndex = 0;

    useVolumeKeys = false;
    useSideTap = true;
    await _syncConfig();

    notifyListeners();
    debugPrint('所有資料與物理檔案已清理完成。');
  }

  /// 內部方法：建立初始預設資料。
  void _setDefaultData() {
    addItem(); // 建立第一個預設項目
  }

  /// 將目前項目資料同步寫入本機儲存。
  Future<void> _syncToDisk() async {
    final self = this as HomeController;
    final prefs = await SharedPreferences.getInstance();

    // 將 items 列表序列化成 JSON 字串
    final String encoded = jsonEncode(
      self.items.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  // ===============================
  // 列表管理（新增、複製、刪除、移動）
  // ===============================

  /// 新增一個項目，並自動切換到新建立的項目。
  void addItem() {
    final self = this as HomeController;

    self.items.add(
      HomeItem(
        title: '新屏幕',
        content: '',
        icon: Icons.add_box_outlined,
        backgroundImagePath: '', // 初始背景為空
      ),
    );

    // 更新目前索引到新建立項目
    self._currentIndex = self.items.length - 1;

    notifyListeners();
    _syncToDisk();
  }

  /// 複製目前項目，並將副本插入在原項目後方。
  void copyCurrentItem() {
    final self = this as HomeController;
    final current = self.currentItem;

    // 建立副本並修改標題
    final newItem = current.copyWith(title: current.title);

    // 插入到原項目後方
    self.items.insert(self._currentIndex + 1, newItem);
    self._currentIndex++;
    notifyListeners();
    _syncToDisk();
  }

  /// 刪除目前項目，必要時自動修正索引或補回預設資料。
  void deleteCurrentItem() async {
    final self = this as HomeController;
    final String? pathToDelete = self.currentItem.backgroundImagePath;

    // 检查是否还有其他项在使用这个路径
    if (pathToDelete != null && pathToDelete.isNotEmpty) {
      // 统计列表中使用该路径的总次数
      int usageCount = self.items
          .where((item) => item.backgroundImagePath == pathToDelete)
          .length;

      // 只有当使用次数等于 1 时（即只有当前这一项在用），才执行物理删除
      if (usageCount == 1) {
        await FileService.deleteFile(pathToDelete);
        debugPrint('这是该图片的最后一个引用，已执行物理删除。');
      } else {
        debugPrint('该图片仍被其他项目使用（剩余 ${usageCount - 1} 个引用），跳过物理删除。');
      }
    }

    // 执行内存删除
    self.items.removeAt(self._currentIndex);

    if (self.items.isEmpty) {
      await clearAllData();
    } else {
      if (self._currentIndex >= self.items.length) {
        self._currentIndex = self.items.length - 1;
      }
      notifyListeners();
      _syncToDisk();
    }
  }

  /// 將目前項目往上移動一格，採循環式排序。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;

    final int len = self.items.length;

    // 循環位移算法，首項可移到最後
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

  // ===============================
  // 屬性編輯（標題、圖示、文字/圖片模式）
  // ===============================

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
      backgroundImagePath: '', // 切換文字模式時清空圖片路徑
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
      // 1. 刪除舊的圖片檔案
      await FileService.deleteFile(self.currentItem.backgroundImagePath);

      // 2. 儲存新圖片檔案（僅存檔名）
      final String? savedFileName = await FileService.saveImageToDocs(
        image.path,
      );

      if (savedFileName != null) {
        self.items[self._currentIndex] = self.currentItem.copyWith(
          content: '',
          backgroundImagePath: savedFileName, // 儲存檔名
        );
        notifyListeners();
        _syncToDisk();
      }
    }
  }

  // ===============================
  // 顏色管理
  // ===============================

  /// 設定文字顏色；若為 null，表示清除自訂文字顏色。
  void setTextColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 設定背景顏色；若為 null，表示清除自訂背景顏色。
  void setBgColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 檢查兩個顏色是否過於接近（依據 WCAG 相對亮度差）。
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;

    // 若 ARGB 完全相同，直接判定
    if (a.toARGB32() == b.toARGB32()) return true;

    // 計算相對亮度差，差距小於 0.15 判定為過於相似
    final double diff = (a.computeLuminance() - b.computeLuminance()).abs();
    return diff < 0.15;
  }

  /// 計算反相色。
  ///
  /// 可用於特殊提示、對比輔助或自動配色調整等情境。
  Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 1.0 - color.r,
      green: 1.0 - color.g,
      blue: 1.0 - color.b,
    );
  }

  /// 判斷兩個顏色是否為完全相同。
  bool isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
}
