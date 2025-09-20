part of 'home_controller.dart';

/// 首頁控制器的資料管理混入 (Mixin)。
///
/// 負責處理應用的持久化資料、組態設定、項目列表管理以及檔案的匯入匯出邏輯。
/// 此混入必須應用於繼承自 [ChangeNotifier] 且能轉型為 [HomeController] 的類別。
mixin HomeControllerData on ChangeNotifier {
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;

  /// 標記資料是否已完成初始化載入。
  bool _isInitialized = false;

  /// 對外暴露目前的初始化狀態。
  bool get isInitialized => _isInitialized;

  /// 是否啟用音量鍵進行頁面切換的功能。
  bool useVolumeKeys = false;

  /// 是否啟用點擊螢幕左右半邊進行頁面切換的功能。
  bool useSideTap = true;

  /// 橫向顯示模式 (Landscape) 下的導覽列位置。
  LandscapeNavPosition landscapeNavPosition = LandscapeNavPosition.bottom;

  /// 縱向顯示模式 (Portrait) 下的導覽列位置。
  PortraitNavPosition portraitNavPosition = PortraitNavPosition.auto;

  /// 儲存首頁項目列表資料的本地持久化鍵值 (Storage Key)。
  static const String _storageKey = 'evernight_board_storage';

  /// 儲存應用程式控制選項的本地持久化鍵值 (Config Key)。
  static const String _configKey = 'evernight_board_config';

  /// 判斷當前平台是否支援音量鍵監聽邏輯。
  /// 僅限 Android 與 iOS 平台，且不支援 Web 環境。
  bool get _isVolumeSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// 切換語系並儲存
  void changeLocale(Locale? locale) {
    _appLocale = locale;
    debugPrint('[HomeControllerData] 變更語系為: ${locale?.languageCode ?? "自動"}');
    notifyListeners();
    _syncConfig(); // 儲存到本地
  }

  /// 顯示統一風格的 SnackBar 提示訊息。
  ///
  /// [context] 建構上下文。
  /// [message] 要顯示的訊息文字。
  /// [isError] 是否為錯誤狀態，會影響圖示與顏色呈現。
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;

    debugPrint('[HomeControllerData] 觸發 SnackBar 提示: $message');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.info_outline : Icons.check_circle_outline,
              color: isError ? Colors.orangeAccent : Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[900]?.withOpacity(0.9),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  // ===============================
  // 初始化與資料持久化流程
  // ===============================

  /// 執行資料初始化程序，從 SharedPreferences 載入項目資料與組態。
  Future<void> initData() async {
    debugPrint('[HomeControllerData] 開始執行資料初始化程序...');
    final self = this as HomeController;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 載入項目清單
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(jsonStr);
        self.items.clear();
        self.items.addAll(
          jsonData.map((item) => HomeItem.fromJson(item)).toList(),
        );
        debugPrint('[HomeControllerData] 已成功載入 ${self.items.length} 個項目。');
      } else {
        debugPrint('[HomeControllerData] 查無本地項目資料，載入預設值。');
        _setDefaultData();
      }

      // 載入使用者組態設定
      final String? configJson = prefs.getString(_configKey);
      if (configJson != null) {
        final Map<String, dynamic> config = jsonDecode(configJson);
        final String? langCode = config['languageCode'];
        final String? scriptCode = config['scriptCode'];
        if (langCode != null) {
          _appLocale = Locale.fromSubtags(
            languageCode: langCode,
            scriptCode: scriptCode,
          );
        }
        useVolumeKeys = _isVolumeSupported
            ? (config['useVolumeKeys'] ?? false)
            : false;
        useSideTap = config['useSideTap'] ?? true;
        landscapeNavPosition =
            LandscapeNavPosition.values[config['landscapeNavPosition'] ??
                LandscapeNavPosition.bottom.index];
        portraitNavPosition =
            PortraitNavPosition.values[config['portraitNavPosition'] ??
                PortraitNavPosition.auto.index];
        debugPrint('[HomeControllerData] 組態設定載入完成，目前語言: ${_appLocale ?? "自動"}');
      }
    } catch (e) {
      debugPrint('[HomeControllerData] 初始化過程發生例外錯誤: $e');
      self.items.clear();
      _setDefaultData();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 將當前的組態設定同步至本地儲存體。
  Future<void> _syncConfig() async {
    debugPrint('[HomeControllerData] 正在同步組態設定至本地儲存...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _configKey,
      jsonEncode({
        'useVolumeKeys': useVolumeKeys,
        'useSideTap': useSideTap,
        'landscapeNavPosition': landscapeNavPosition.index,
        'portraitNavPosition': portraitNavPosition.index,
        'languageCode': _appLocale?.languageCode,
        'scriptCode': _appLocale?.scriptCode,
      }),
    );
  }

  /// 切換音量鍵控制功能開關。
  void toggleVolumeKeys(bool value) {
    if (!_isVolumeSupported) {
      debugPrint('[HomeControllerData] 當前平台不支援音量鍵切換。');
      return;
    }
    useVolumeKeys = value;
    debugPrint('[HomeControllerData] 音量鍵切換狀態更新為: $value');
    notifyListeners();
    _syncConfig();
  }

  /// 切換側邊點擊功能開關。
  void toggleSideTap(bool value) {
    useSideTap = value;
    debugPrint('[HomeControllerData] 側邊點擊狀態更新為: $value');
    _syncConfig();
    notifyListeners();
  }

  /// 清空所有應用程式資料與設定，並刪除相關的實體檔案。
  ///
  /// [context] 用於顯示結果提示與導航回退。
  Future<void> clearAllData(BuildContext context) async {
    debugPrint('[HomeControllerData] 正在執行全域資料清空程序...');
    final self = this as HomeController;

    // 遞迴刪除所有項目關聯的背景圖片檔案
    for (var item in self.items) {
      await FileService.deleteFile(item.backgroundImagePath);
    }

    self.items.clear();
    self._currentIndex = 0;
    _setDefaultData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    useVolumeKeys = false;
    useSideTap = true;
    await _syncConfig();

    notifyListeners();

    if (context.mounted) {
      _showSnackBar(context, t.allcleared);
      Navigator.pop(context);
    }
  }

  /// 設定預設資料（添加一個空項目）。
  void _setDefaultData() {
    addItem();
  }

  /// 將目前的項目列表狀態同步至本地磁碟。
  Future<void> _syncToDisk() async {
    debugPrint('[HomeControllerData] 正在同步項目列表至磁碟...');
    final self = this as HomeController;
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      self.items.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  // ===============================
  // 列表管理
  // ===============================

  /// 在列表末尾添加一個新的預設項目。
  void addItem() {
    debugPrint('[HomeControllerData] 執行添加新項目操作。');
    final self = this as HomeController;
    self.items.add(
      HomeItem(
        title: t.newscreen,
        content: '',
        icon: Icons.add_box_outlined,
        backgroundImagePath: '',
      ),
    );
    self._currentIndex = self.items.length - 1;
    notifyListeners();
    _syncToDisk();
  }

  /// 複製當前選中的項目並插入至下一位。
  void copyCurrentItem() {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    debugPrint('[HomeControllerData] 正在複製索引為 ${self._currentIndex} 的項目。');
    final newItem = self.currentItem.copyWith(title: self.currentItem.title);
    self.items.insert(self._currentIndex + 1, newItem);
    self._currentIndex++;
    notifyListeners();
    _syncToDisk();
  }

  /// 刪除當前選中的項目，並自動處理實體圖片檔案的引用計數與刪除邏輯。
  void deleteCurrentItem() async {
    final self = this as HomeController;
    if (self.items.isEmpty) return;

    final String? pathToDelete = self.currentItem.backgroundImagePath;
    if (pathToDelete != null && pathToDelete.isNotEmpty) {
      // 檢查該圖片檔案是否被多個項目共用
      int usageCount = self.items
          .where((item) => item.backgroundImagePath == pathToDelete)
          .length;
      if (usageCount == 1) {
        debugPrint('[HomeControllerData] 該圖片為唯一引用，執行實體檔案刪除: $pathToDelete');
        await FileService.deleteFile(pathToDelete);
      }
    }

    self.items.removeAt(self._currentIndex);
    if (self.items.isEmpty) {
      _setDefaultData();
      self._currentIndex = 0;
    } else if (self._currentIndex >= self.items.length) {
      self._currentIndex = self.items.length - 1;
    }

    debugPrint('[HomeControllerData] 項目已刪除，剩餘數量: ${self.items.length}');
    notifyListeners();
    _syncToDisk();
  }

  /// 將當前項目在列表中向上移動（循環移動）。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;
    final int len = self.items.length;
    int newIndex = (self._currentIndex - 1 + len) % len;
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);
    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
  }

  /// 將當前項目在列表中向下移動（循環移動）。
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
  // 屬性編輯
  // ===============================

  /// 更新當前項目的標題。
  void updateTitle(String newTitle) {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    self.items[self._currentIndex] = self.currentItem.copyWith(title: newTitle);
    notifyListeners();
    _syncToDisk();
  }

  /// 更新當前項目的圖示。
  void updateIcon(IconData newIcon) {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    self.items[self._currentIndex] = self.currentItem.copyWith(icon: newIcon);
    notifyListeners();
    _syncToDisk();
  }

  /// 設定橫屏導覽列位置並持久化。
  void setLandscapeNavPosition(LandscapeNavPosition pos) {
    landscapeNavPosition = pos;
    _syncConfig();
    notifyListeners();
  }

  /// 設定豎屏導覽列位置並持久化。
  void setPortraitNavPosition(PortraitNavPosition pos) {
    portraitNavPosition = pos;
    _syncConfig();
    notifyListeners();
  }

  /// 將當前項目設定為純文字模式，並清空關聯圖片。
  void setAsText(String text) {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      content: text,
      backgroundImagePath: '',
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 從圖庫選取圖片並儲存至應用程式文件目錄。
  ///
  /// [maxDimension] 設定圖片的最大寬高，避免記憶體溢出。
  Future<void> pickImage(double maxDimension) async {
    final self = this as HomeController;
    final ImagePicker picker = ImagePicker();
    if (self.items.isEmpty) return;

    debugPrint('[HomeControllerData] 正在開啟圖庫選擇器...');
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
    );

    if (image != null) {
      // 刪除舊圖片以節省空間
      await FileService.deleteFile(self.currentItem.backgroundImagePath);
      final String? savedFileName = await FileService.saveImageToDocs(
        image.path,
      );

      if (savedFileName != null) {
        debugPrint('[HomeControllerData] 圖片選取並儲存成功: $savedFileName');
        self.items[self._currentIndex] = self.currentItem.copyWith(
          content: '',
          backgroundImagePath: savedFileName,
        );
        notifyListeners();
        _syncToDisk();
      }
    } else {
      debugPrint('[HomeControllerData] 使用者取消了圖片選取。');
    }
  }

  // ===============================
  // 顏色管理
  // ===============================

  /// 設定當前項目的文字顏色。
  void setTextColor(Color? color) {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 設定當前項目的背景顏色。
  void setBgColor(Color? color) {
    final self = this as HomeController;
    if (self.items.isEmpty) return;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 檢查兩個顏色是否過於接近，用於對比度檢測。
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;
    if (a.toARGB32() == b.toARGB32()) return true;
    final double diff = (a.computeLuminance() - b.computeLuminance()).abs();
    return diff < 0.15;
  }

  /// 計算顏色的反轉色。
  Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 1.0 - color.r,
      green: 1.0 - color.g,
      blue: 1.0 - color.b,
    );
  }

  /// 比較兩個顏色是否完全相同。
  bool isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

  // ===============================
  // 匯入匯出
  // ===============================

  /// 匯出當前所有項目資料，並將背景圖片轉碼為 Base64 嵌入 JSON 檔案中。
  Future<void> exportData(BuildContext context) async {
    debugPrint('[HomeControllerData] 正在準備匯出資料...');
    final self = this as HomeController;
    List<Map<String, dynamic>> exportList = [];

    for (var item in self.items) {
      Map<String, dynamic> itemJson = item.toJson();
      if (item.backgroundImagePath != null &&
          item.backgroundImagePath!.isNotEmpty) {
        String? base64Data = await FileService.getBase64Image(
          item.backgroundImagePath,
        );
        if (base64Data != null) {
          itemJson['image_data_base64'] = base64Data;
        }
      }
      exportList.add(itemJson);
    }

    final String jsonStr = jsonEncode(exportList);
    final bool success = await DataExportService.exportJson(jsonStr);

    if (context.mounted) {
      if (success) {
        debugPrint('[HomeControllerData] 匯出成功。');
        _showSnackBar(context, t.exportok);
      } else {
        debugPrint('[HomeControllerData] 匯出被使用者取消。');
        _showSnackBar(context, t.exportcancel, isError: true);
      }
    }
  }

  /// 匯入外部 JSON 設定檔，並將 Base64 圖片資料還原為本地檔案。
  Future<void> importData(BuildContext context) async {
    debugPrint('[HomeControllerData] 啟動資料匯入流程...');
    final self = this as HomeController;
    final String? jsonStr = await DataExportService.importJson();

    if (jsonStr == null) {
      debugPrint('[HomeControllerData] 匯入取消：未選擇檔案。');
      if (context.mounted)
        _showSnackBar(context, t.nofileselected, isError: true);
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<HomeItem> newItems = [];

      for (var itemData in decoded) {
        if (itemData is Map<String, dynamic>) {
          Map<String, dynamic> map = Map<String, dynamic>.from(itemData);
          String? base64 = map['image_data_base64'];
          String? originalPath = map['imagePath'];

          if (base64 != null &&
              originalPath != null &&
              originalPath.isNotEmpty) {
            String? newFileName = await FileService.saveBase64Image(
              base64,
              originalPath,
            );
            if (newFileName != null) map['imagePath'] = newFileName;
          }
          newItems.add(HomeItem.fromJson(map));
        }
      }

      if (newItems.isNotEmpty) {
        self.items.clear();
        self.items.addAll(newItems);
        self._currentIndex = 0;
        notifyListeners();
        _syncToDisk();
        debugPrint('[HomeControllerData] 成功匯入 ${newItems.length} 個項目。');

        if (context.mounted) {
          _showSnackBar(
            context,
            '${t.importok1} ${newItems.length} ${t.importok2}',
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint('[HomeControllerData] 匯入失敗：檔案內容為空或無效。');
        if (context.mounted) {
          _showSnackBar(context, t.invalidconffile, isError: true);
        }
      }
    } catch (e) {
      debugPrint('[HomeControllerData] 匯入解析過程中發生錯誤: $e');
      if (context.mounted) {
        _showSnackBar(context, t.conffileparsingfailed, isError: true);
      }
    }
  }
}
