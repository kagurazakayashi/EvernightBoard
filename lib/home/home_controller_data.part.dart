part of 'home_controller.dart';

/// 首頁控制器的資料管理混入。
///
/// 主要負責：
/// - 初始化與載入本機資料
/// - 控制項設定持久化
/// - 項目新增、複製、刪除與排序
/// - 項目屬性編輯
/// - 顏色相關工具方法
/// - 設定資料的匯入與匯出
///
/// 此 mixin 依附於 [HomeController]，
/// 會透過 `this as HomeController` 存取主控制器中的狀態與資料。
mixin HomeControllerData on ChangeNotifier {
  /// 是否已完成資料初始化。
  ///
  /// 此旗標主要用於資料層初始化流程，
  /// 與主控制器中的初始化狀態相互配合。
  bool _isInitialized = false;

  /// 對外提供目前初始化狀態。
  bool get isInitialized => _isInitialized;

  /// 是否啟用音量鍵切換。
  ///
  /// 預設為停用，且僅在支援的平台上可啟用。
  bool useVolumeKeys = false;

  /// 是否啟用左右半屏點擊切換。
  ///
  /// 預設為啟用。
  bool useSideTap = true;

  /// 儲存首頁項目資料的本機 Key。
  static const String _storageKey = 'evernight_board_storage';

  /// 儲存控制選項的本機 Key。
  static const String _configKey = 'evernight_board_config';

  /// 目前平台是否支援音量控制相關功能。
  ///
  /// 僅在非 Web 且為 Android / iOS 時回傳 `true`。
  bool get _isVolumeSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ===============================
  // 初始化與資料持久化流程
  // ===============================

  /// 啟動時載入本機儲存的資料與設定。
  ///
  /// 流程包含：
  /// - 讀取已儲存的首頁項目資料
  /// - 還原音量鍵與半屏點擊等操作設定
  /// - 若資料不存在或解析失敗，則建立預設資料
  ///
  /// 無論成功或失敗，最後都會標記初始化完成並通知畫面更新。
  Future<void> initData() async {
    final self = this as HomeController;

    try {
      debugPrint('[HomeControllerData] 開始載入本機資料與設定');

      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        // 將 JSON 字串還原為 HomeItem 清單。
        final List<dynamic> jsonData = jsonDecode(jsonStr);
        self.items.clear();
        self.items.addAll(
          jsonData.map((item) => HomeItem.fromJson(item)).toList(),
        );
        debugPrint('[HomeControllerData] 已從本機載入項目資料，數量：${self.items.length}');
      } else {
        // 若本機尚無資料，建立預設項目。
        debugPrint('[HomeControllerData] 找不到既有項目資料，改用預設資料');
        _setDefaultData();
      }

      final String? configJson = prefs.getString(_configKey);
      if (configJson != null) {
        // 還原使用者設定；若平台不支援音量功能，則強制維持停用。
        final Map<String, dynamic> config = jsonDecode(configJson);
        useVolumeKeys = _isVolumeSupported
            ? (config['useVolumeKeys'] ?? false)
            : false;
        useSideTap = config['useSideTap'] ?? true;

        debugPrint(
          '[HomeControllerData] 已載入設定：useVolumeKeys=$useVolumeKeys, useSideTap=$useSideTap',
        );
      } else {
        debugPrint('[HomeControllerData] 找不到既有設定資料，使用預設設定');
      }
    } catch (e) {
      // 任一資料讀取或解析失敗時，回退到預設資料。
      debugPrint('[HomeControllerData] 載入資料失敗，改用預設資料：$e');
      self.items.clear();
      _setDefaultData();
    } finally {
      _isInitialized = true; // 標記資料初始化完成
      notifyListeners(); // 通知 UI 重新整理
      debugPrint('[HomeControllerData] 資料初始化流程結束');
    }
  }

  /// 將目前控制設定同步寫入本機儲存。
  ///
  /// 目前包含：
  /// - [useVolumeKeys]
  /// - [useSideTap]
  Future<void> _syncConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _configKey,
      jsonEncode({'useVolumeKeys': useVolumeKeys, 'useSideTap': useSideTap}),
    );
    debugPrint(
      '[HomeControllerData] 已同步設定：useVolumeKeys=$useVolumeKeys, useSideTap=$useSideTap',
    );
  }

  /// 切換是否使用音量鍵控制。
  ///
  /// 若目前平台不支援音量控制，則直接略過。
  void toggleVolumeKeys(bool value) {
    if (!_isVolumeSupported) {
      debugPrint('[HomeControllerData] 目前平台不支援音量鍵控制，忽略設定變更');
      return;
    }

    useVolumeKeys = value;
    notifyListeners();
    _syncConfig();
    debugPrint('[HomeControllerData] 已更新音量鍵控制設定：$useVolumeKeys');
  }

  /// 切換是否啟用半屏點擊操作。
  void toggleSideTap(bool value) {
    useSideTap = value;
    _syncConfig();
    notifyListeners();
    debugPrint('[HomeControllerData] 已更新半屏點擊設定：$useSideTap');
  }

  /// 清除所有使用者資料，並還原為預設狀態。
  ///
  /// 此流程會：
  /// - 刪除各項目對應的背景圖片檔案
  /// - 清除 SharedPreferences 中的項目資料
  /// - 保留設定頁面原本的關閉流程
  /// - 還原控制選項為預設值
  ///
  /// 注意：
  /// 目前此方法並未清空 `self.items` 記憶體資料，
  /// 而是保留既有程式流程與行為不變。
  Future<void> clearAllData(BuildContext context) async {
    final self = this as HomeController;

    debugPrint('[HomeControllerData] 開始清除所有資料');

    // 刪除所有項目對應的實體圖片檔案。
    for (var item in self.items) {
      await FileService.deleteFile(item.backgroundImagePath);
    }

    // 清空記憶體中的項目資料並重置索引
    self.items.clear();
    self._currentIndex = 0;
    // 還原為預設項目（這會自動 addItem 並同步到磁碟）
    _setDefaultData();

    // 清除 SharedPreferences 中儲存的項目資料。
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    debugPrint('[HomeControllerData] 已清除本機儲存的項目資料');

    // 還原操作設定為預設值。
    useVolumeKeys = false;
    useSideTap = true;
    await _syncConfig();

    // 通知所有監聽者（如主螢幕）刷新 UI
    notifyListeners();

    // 若畫面仍存在，顯示提示並關閉目前頁面。
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已清空数据'), duration: Duration(seconds: 1)),
      );
      Navigator.pop(context);
      // RestartWidget.restartApp(context);
    }

    // 還原操作設定為預設值。
    useVolumeKeys = false;
    useSideTap = true;
    await _syncConfig();

    notifyListeners();
    debugPrint('[HomeControllerData] 所有資料與實體檔案已清理完成');
  }

  /// 建立初始預設資料。
  ///
  /// 目前會建立一筆預設項目，作為畫面初始內容。
  void _setDefaultData() {
    debugPrint('[HomeControllerData] 建立預設資料');
    addItem();
  }

  /// 將目前項目資料同步寫入本機儲存。
  ///
  /// 會先將 [HomeItem] 清單序列化為 JSON 字串後再寫入。
  Future<void> _syncToDisk() async {
    final self = this as HomeController;
    final prefs = await SharedPreferences.getInstance();

    // 將項目清單序列化為 JSON 字串後寫入本機。
    final String encoded = jsonEncode(
      self.items.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
    debugPrint('[HomeControllerData] 已同步項目資料到本機，數量：${self.items.length}');
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
        backgroundImagePath: '', // 新項目預設沒有背景圖片
      ),
    );

    // 將目前索引切換到最新建立的項目。
    self._currentIndex = self.items.length - 1;

    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已新增項目，currentIndex=${self._currentIndex}');
  }

  /// 複製目前項目，並將副本插入在原項目後方。
  ///
  /// 目前採用淺層資料複製方式，
  /// 會保留原本項目的欄位內容。
  void copyCurrentItem() {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可複製的項目');
      return;
    }

    final current = self.currentItem;

    // 建立目前項目的副本。
    final newItem = current.copyWith(title: current.title);

    // 將副本插入到原項目後方，並切換選取位置。
    self.items.insert(self._currentIndex + 1, newItem);
    self._currentIndex++;
    notifyListeners();
    _syncToDisk();
    debugPrint(
      '[HomeControllerData] 已複製目前項目，currentIndex=${self._currentIndex}',
    );
  }

  /// 刪除目前項目，必要時一併刪除未被其他項目引用的圖片檔案。
  ///
  /// 若刪除後清單為空，會自動補回一筆預設資料。
  void deleteCurrentItem() async {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可刪除的項目');
      return;
    }

    final String? pathToDelete = self.currentItem.backgroundImagePath;

    // 檢查背景圖片是否仍被其他項目共用。
    if (pathToDelete != null && pathToDelete.isNotEmpty) {
      // 統計使用相同圖片路徑的項目總數。
      int usageCount = self.items
          .where((item) => item.backgroundImagePath == pathToDelete)
          .length;

      // 僅當目前項目是最後一個引用者時，才刪除實體檔案。
      if (usageCount == 1) {
        await FileService.deleteFile(pathToDelete);
        debugPrint('[HomeControllerData] 這是該圖片的最後一個引用，已執行實體刪除');
      } else {
        debugPrint(
          '[HomeControllerData] 該圖片仍被其他項目使用（剩餘 ${usageCount - 1} 個引用），略過實體刪除',
        );
      }
    }

    // 從記憶體中移除目前項目。
    self.items.removeAt(self._currentIndex);

    // 若刪除後清單為空，補回預設資料。
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 刪除後項目清單為空，建立預設資料');
      _setDefaultData();
      self._currentIndex = 0;
    } else if (self._currentIndex >= self.items.length) {
      // 若目前索引超出範圍，修正到最後一筆。
      self._currentIndex = self.items.length - 1;
    }

    notifyListeners();
    _syncToDisk();
    debugPrint(
      '[HomeControllerData] 已刪除目前項目，currentIndex=${self._currentIndex}',
    );
  }

  /// 將目前項目往上移動一格，採循環式排序。
  ///
  /// 若目前為第一項，則會移動到最後一項。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) {
      debugPrint('[HomeControllerData] 項目數量不足，無需上移');
      return;
    }

    final int len = self.items.length;

    // 採循環方式計算新索引，第一項可移到最後一項。
    int newIndex = (self._currentIndex - 1 + len) % len;
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);

    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
    debugPrint(
      '[HomeControllerData] 已將項目上移，currentIndex=${self._currentIndex}',
    );
  }

  /// 將目前項目往下移動一格，採循環式排序。
  ///
  /// 若目前為最後一項，則會移動到第一項。
  void moveDown() {
    final self = this as HomeController;
    if (self.items.length <= 1) {
      debugPrint('[HomeControllerData] 項目數量不足，無需下移');
      return;
    }

    final int len = self.items.length;
    int newIndex = (self._currentIndex + 1) % len;

    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);

    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
    debugPrint(
      '[HomeControllerData] 已將項目下移，currentIndex=${self._currentIndex}',
    );
  }

  // ===============================
  // 屬性編輯（標題、圖示、文字/圖片模式）
  // ===============================

  /// 更新目前項目的標題。
  void updateTitle(String newTitle) {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可更新標題的項目');
      return;
    }

    self.items[self._currentIndex] = self.currentItem.copyWith(title: newTitle);
    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已更新目前項目標題');
  }

  /// 更新目前項目的圖示。
  void updateIcon(IconData newIcon) {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可更新圖示的項目');
      return;
    }

    self.items[self._currentIndex] = self.currentItem.copyWith(icon: newIcon);
    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已更新目前項目圖示');
  }

  /// 將目前項目設為文字模式，並清空背景圖片路徑。
  ///
  /// 設定後會保留文字內容，並移除圖片模式相關路徑資料。
  void setAsText(String text) {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可切換為文字模式的項目');
      return;
    }

    self.items[self._currentIndex] = self.currentItem.copyWith(
      content: text,
      backgroundImagePath: '', // 切換為文字模式時移除圖片路徑
    );
    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已將目前項目切換為文字模式');
  }

  /// 從相簿選取圖片，並將目前項目切換為圖片模式。
  ///
  /// [maxDimension] 會同時套用到選圖時的最大寬度與最大高度，
  /// 用於降低圖片尺寸與儲存負擔。
  Future<void> pickImage(double maxDimension) async {
    final self = this as HomeController;
    final ImagePicker picker = ImagePicker();

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可設定圖片的項目');
      return;
    }

    debugPrint('[HomeControllerData] 開始從相簿選取圖片');

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
    );

    if (image != null) {
      // 1. 刪除目前項目舊有的背景圖片檔案。
      await FileService.deleteFile(self.currentItem.backgroundImagePath);

      // 2. 儲存新圖片到文件目錄，並取得儲存後的檔名。
      final String? savedFileName = await FileService.saveImageToDocs(
        image.path,
      );

      if (savedFileName != null) {
        self.items[self._currentIndex] = self.currentItem.copyWith(
          content: '',
          backgroundImagePath: savedFileName, // 僅儲存檔名供後續讀取
        );
        notifyListeners();
        _syncToDisk();
        debugPrint('[HomeControllerData] 已更新目前項目的背景圖片');
      } else {
        debugPrint('[HomeControllerData] 圖片儲存失敗，未更新目前項目');
      }
    } else {
      debugPrint('[HomeControllerData] 使用者取消選取圖片');
    }
  }

  // ===============================
  // 顏色管理
  // ===============================

  /// 設定文字顏色。
  ///
  /// 當 [color] 為 `null` 時，表示清除自訂文字顏色並回復預設。
  void setTextColor(Color? color) {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可設定文字顏色的項目');
      return;
    }

    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已更新文字顏色設定');
  }

  /// 設定背景顏色。
  ///
  /// 當 [color] 為 `null` 時，表示清除自訂背景顏色並回復預設。
  void setBgColor(Color? color) {
    final self = this as HomeController;

    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 目前沒有可設定背景顏色的項目');
      return;
    }

    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
    debugPrint('[HomeControllerData] 已更新背景顏色設定');
  }

  /// 檢查兩個顏色是否過於接近。
  ///
  /// 判定方式如下：
  /// - 若任一顏色為 `null`，視為不相近
  /// - 若兩者 ARGB 完全一致，直接視為相同
  /// - 否則依據相對亮度差判斷，若差距小於 `0.15` 則視為過於接近
  ///
  /// 此方法可用於避免文字與背景色之間的對比不足。
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;

    // 若 ARGB 值完全一致，直接判定為相同顏色。
    if (a.toARGB32() == b.toARGB32()) return true;

    // 以相對亮度差做簡易判斷，避免文字與背景對比不足。
    final double diff = (a.computeLuminance() - b.computeLuminance()).abs();
    return diff < 0.15;
  }

  /// 計算指定顏色的反相色。
  ///
  /// 可用於提示色、自動對比或輔助配色等情境。
  Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 1.0 - color.r,
      green: 1.0 - color.g,
      blue: 1.0 - color.b,
    );
  }

  /// 判斷兩個顏色是否完全相同。
  ///
  /// 比較依據為 ARGB 整數值。
  bool isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

  // ===============================
  // 匯入匯出
  // ===============================

  /// 匯出所有資料為 JSON 字串，並視需要嵌入圖片 Base64 資料。
  ///
  /// 每個項目若存在背景圖片，會先讀取本機檔案並轉成 Base64，
  /// 再附加至輸出 JSON 中。
  Future<void> exportData(BuildContext context) async {
    final self = this as HomeController;

    debugPrint('[HomeControllerData] 開始匯出資料');

    // 建立一個包含圖片 Base64 的匯出列表。
    List<Map<String, dynamic>> exportList = [];

    for (var item in self.items) {
      Map<String, dynamic> itemJson = item.toJson();

      // 檢查是否有背景圖片，並將其編碼。
      if (item.backgroundImagePath != null &&
          item.backgroundImagePath!.isNotEmpty) {
        String? base64Data = await FileService.getBase64Image(
          item.backgroundImagePath,
        );
        if (base64Data != null) {
          itemJson['image_data_base64'] = base64Data;
        } else {
          debugPrint('[HomeControllerData] 背景圖片轉 Base64 失敗，略過嵌入圖片資料');
        }
      }
      exportList.add(itemJson);
    }

    final String jsonStr = jsonEncode(exportList);
    final bool success = await DataExportService.exportJson(jsonStr);

    debugPrint('[HomeControllerData] 匯出流程結束，success=$success');

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success ? '已成功导出配置文件' : '导出已取消')));
    }
  }

  /// 從 JSON 檔案匯入資料，還原圖片並顯示匯入結果。
  ///
  /// 若匯入資料包含 `image_data_base64`，會先嘗試還原為本機檔案，
  /// 再將對應的路徑寫回資料結構。
  Future<void> importData(BuildContext context) async {
    final self = this as HomeController;
    final String? jsonStr = await DataExportService.importJson();

    if (jsonStr == null) {
      debugPrint('[HomeControllerData] 匯入流程取消或未取得資料');
      return;
    }

    debugPrint('[HomeControllerData] 開始匯入資料');

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<HomeItem> newItems = [];

      for (var itemData in decoded) {
        if (itemData is Map<String, dynamic>) {
          Map<String, dynamic> map = Map<String, dynamic>.from(itemData);

          String? base64 = map['image_data_base64'];
          String? originalPath = map['imagePath'];

          // 若包含 Base64，則先還原為本機文件，再更新路徑。
          if (base64 != null &&
              originalPath != null &&
              originalPath.isNotEmpty) {
            String? newFileName = await FileService.saveBase64Image(
              base64,
              originalPath,
            );
            if (newFileName != null) {
              map['imagePath'] = newFileName;
            } else {
              debugPrint('[HomeControllerData] 圖片 Base64 還原失敗，保留原始路徑資料');
            }
          }

          newItems.add(HomeItem.fromJson(map));
        } else {
          debugPrint('[HomeControllerData] 偵測到非預期的匯入資料格式，已略過一筆資料');
        }
      }

      if (newItems.isNotEmpty) {
        self.items.clear();
        self.items.addAll(newItems);
        self._currentIndex = 0;
        notifyListeners();
        _syncToDisk();
        debugPrint('[HomeControllerData] 匯入成功，項目數量：${newItems.length}');

        // 匯入成功後的提示。
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导入了 ${newItems.length} 个屏幕设置'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
          Navigator.pop(context);
          // RestartWidget.restartApp(context);
        }
      } else {
        debugPrint('[HomeControllerData] 匯入完成，但未取得有效項目資料');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('无效的配置文件')));
        }
      }
    } catch (e) {
      debugPrint('[HomeControllerData] 匯入解析失敗: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无效的配置文件'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
