part of 'home_controller.dart';

/// 首頁控制器的資料管理混入（Mixin）。
///
/// 負責管理下列核心資料流程：
///
/// - 應用程式語系切換與保存
/// - 首頁項目清單的初始化、增刪與排序
/// - 使用者偏好設定的持久化
/// - 匯入／匯出前的資料準備
///
/// 此混入必須套用於可轉型為 [HomeController]，且繼承自 [ChangeNotifier]
/// 的類別，才能正確存取控制器狀態與觸發通知機制。
mixin HomeControllerData on ChangeNotifier {
  Locale? _appLocale;

  /// 目前應用程式使用中的語系設定。
  ///
  /// 若為 `null`，代表使用系統預設語系。
  Locale? get appLocale => _appLocale;

  /// 標記資料是否已完成初始化載入。
  bool _isInitialized = false;

  /// 目前資料初始化是否已完成。
  bool get isInitialized => _isInitialized;

  /// 是否啟用音量鍵切換頁面的功能。
  bool useVolumeKeys = false;

  /// 是否啟用點擊螢幕左右半側切換頁面的功能。
  bool useSideTap = true;

  /// 橫向模式下導覽列的位置設定。
  LandscapeNavPosition landscapeNavPosition = LandscapeNavPosition.bottom;

  /// 直向模式下導覽列的位置設定。
  PortraitNavPosition portraitNavPosition = PortraitNavPosition.auto;

  /// 首頁項目清單寫入本機持久化儲存時使用的鍵值。
  static const String _storageKey = 'evernight_board_storage';

  /// 應用程式偏好設定寫入本機持久化儲存時使用的鍵值。
  static const String _configKey = 'evernight_board_config';

  /// 判斷目前執行平台是否支援音量鍵監聽。
  ///
  /// 僅限 Android 與 iOS，且不支援 Web。
  bool get _isVolumeSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// 切換應用程式語系並同步儲存設定。
  ///
  /// [locale] 欲切換的語系；若為 `null`，則恢復為系統預設語系。
  void changeLocale(Locale? locale) {
    _appLocale = locale;
    debugPrint('[HomeControllerData] 已更新語系設定：${locale?.languageCode ?? "自動"}');
    notifyListeners();
    _syncConfig(); // 儲存至本機
  }

  /// 顯示統一樣式的 SnackBar 提示訊息。
  ///
  /// [context] 用於取得 [ScaffoldMessenger] 的建構上下文。
  /// [message] 要顯示的提示訊息內容。
  /// [isError] 是否為錯誤類型提示，會影響圖示與視覺樣式。
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;

    debugPrint('[HomeControllerData] 顯示 SnackBar 訊息：$message');

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
        backgroundColor: Colors.grey[900]?.withValues(alpha: 0.9),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  // ===============================
  // 初始化與資料持久化
  // ===============================

  /// 執行資料初始化流程，從本機儲存載入項目清單與使用者偏好設定。
  ///
  /// 若本機尚無資料，則自動建立預設項目內容。
  Future<void> initData() async {
    debugPrint('[HomeControllerData] 開始初始化資料...');
    final self = this as HomeController;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 載入首頁項目清單資料。
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(jsonStr);
        self.items.clear();
        self.items.addAll(
          jsonData.map((item) => HomeItem.fromJson(item)).toList(),
        );
        debugPrint('[HomeControllerData] 已載入 ${self.items.length} 筆首頁項目資料。');
      } else {
        debugPrint('[HomeControllerData] 本機查無首頁項目資料，改載入預設資料。');
        _setDefaultData();
      }

      // 載入使用者偏好設定。
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
        debugPrint(
          '[HomeControllerData] 使用者偏好設定載入完成，目前語系：${_appLocale ?? "自動"}',
        );
      } else {
        debugPrint('[HomeControllerData] 本機查無偏好設定，使用預設設定值。');
      }
    } catch (e) {
      debugPrint('[HomeControllerData] 初始化資料時發生例外：$e');
      self.items.clear();
      _setDefaultData();
    } finally {
      _isInitialized = true;
      debugPrint('[HomeControllerData] 資料初始化流程已完成。');
      notifyListeners();
    }
  }

  /// 將目前的應用程式偏好設定同步寫入本機儲存。
  Future<void> _syncConfig() async {
    debugPrint('[HomeControllerData] 正在同步偏好設定至本機儲存...');
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
    debugPrint('[HomeControllerData] 偏好設定同步完成。');
  }

  /// 切換音量鍵翻頁功能。
  ///
  /// 若目前平台不支援音量鍵監聽，則不進行任何設定變更。
  void toggleVolumeKeys(bool value) {
    if (!_isVolumeSupported) {
      debugPrint('[HomeControllerData] 目前平台不支援音量鍵翻頁功能。');
      return;
    }
    useVolumeKeys = value;
    debugPrint('[HomeControllerData] 音量鍵翻頁功能已更新為：$value');
    notifyListeners();
    _syncConfig();
  }

  /// 切換螢幕側邊點擊翻頁功能。
  void toggleSideTap(bool value) {
    useSideTap = value;
    debugPrint('[HomeControllerData] 側邊點擊翻頁功能已更新為：$value');
    _syncConfig();
    notifyListeners();
  }

  /// 清除所有應用程式資料與設定，並移除相關聯的實體檔案。
  ///
  /// [context] 用於顯示操作結果提示與關閉目前頁面。
  Future<void> clearAllData(BuildContext context) async {
    debugPrint('[HomeControllerData] 開始執行全部資料清除流程...');
    final self = this as HomeController;

    // 逐一刪除各項目所關聯的背景圖片檔案。
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

    debugPrint('[HomeControllerData] 全部資料與設定已清除完成。');
    notifyListeners();

    if (context.mounted) {
      _showSnackBar(context, t.allcleared);
      Navigator.pop(context);
    }
  }

  /// 建立預設資料。
  ///
  /// 目前預設行為為新增一筆空白項目。
  void _setDefaultData() {
    debugPrint('[HomeControllerData] 正在建立預設資料...');
    addItem();
  }

  /// 將目前項目清單狀態同步寫入本機磁碟。
  Future<void> _syncToDisk() async {
    debugPrint('[HomeControllerData] 正在同步項目清單至本機磁碟...');
    final self = this as HomeController;
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      self.items.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
    debugPrint('[HomeControllerData] 項目清單同步完成，目前共 ${self.items.length} 筆。');
  }

  // ===============================
  // 項目清單管理
  // ===============================

  /// 在清單尾端新增一筆預設項目。
  ///
  /// 新增完成後，會自動將目前索引切換至新建立的項目。
  void addItem() {
    debugPrint('[HomeControllerData] 準備新增首頁項目。');
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
    debugPrint('[HomeControllerData] 已新增首頁項目，目前總數：${self.items.length}。');
    notifyListeners();
    _syncToDisk();
  }

  /// 複製目前選取的項目，並插入至其後一個位置。
  void copyCurrentItem() {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 複製項目失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在複製索引 ${self._currentIndex} 的項目。');
    final newItem = self.currentItem.copyWith(title: self.currentItem.title);
    self.items.insert(self._currentIndex + 1, newItem);
    self._currentIndex++;
    debugPrint('[HomeControllerData] 項目複製完成，目前總數：${self.items.length}。');
    notifyListeners();
    _syncToDisk();
  }

  /// 刪除目前選取的項目。
  ///
  /// 若該項目關聯的背景圖片未被其他項目共用，則一併刪除實體檔案。
  /// 當刪除後清單為空時，會自動補上一筆預設項目。
  void deleteCurrentItem() async {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 刪除項目失敗：目前項目清單為空。');
      return;
    }

    final String? pathToDelete = self.currentItem.backgroundImagePath;
    if (pathToDelete != null && pathToDelete.isNotEmpty) {
      // 檢查該背景圖片是否仍被其他項目共用。
      int usageCount = self.items
          .where((item) => item.backgroundImagePath == pathToDelete)
          .length;
      if (usageCount == 1) {
        debugPrint('[HomeControllerData] 背景圖片僅此項目使用，將刪除實體檔案：$pathToDelete');
        await FileService.deleteFile(pathToDelete);
      } else {
        debugPrint('[HomeControllerData] 背景圖片仍被其他項目共用，略過檔案刪除：$pathToDelete');
      }
    }

    self.items.removeAt(self._currentIndex);
    if (self.items.isEmpty) {
      _setDefaultData();
      self._currentIndex = 0;
    } else if (self._currentIndex >= self.items.length) {
      self._currentIndex = self.items.length - 1;
    }

    debugPrint('[HomeControllerData] 項目刪除完成，剩餘數量：${self.items.length}。');
    notifyListeners();
    _syncToDisk();
  }

  /// 將目前選取的項目向上移動一格。
  ///
  /// 採循環移動邏輯：若目前位於首位，則移動後會成為最後一筆。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) {
      debugPrint('[HomeControllerData] 無法上移項目：項目數量不足。');
      return;
    }
    final int len = self.items.length;
    int newIndex = (self._currentIndex - 1 + len) % len;
    debugPrint('[HomeControllerData] 項目上移：${self._currentIndex} -> $newIndex');
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);
    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
  }

  /// 將目前選取的項目向下移動一格。
  ///
  /// 採循環移動邏輯：若目前位於末位，則移動後會成為第一筆。
  void moveDown() {
    final self = this as HomeController;
    if (self.items.length <= 1) {
      debugPrint('[HomeControllerData] 無法下移項目：項目數量不足。');
      return;
    }
    final int len = self.items.length;
    int newIndex = (self._currentIndex + 1) % len;
    debugPrint('[HomeControllerData] 項目下移：${self._currentIndex} -> $newIndex');
    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);
    self._currentIndex = newIndex;
    notifyListeners();
    _syncToDisk();
  }

  // ===============================
  // 屬性編輯
  // ===============================

  /// 更新目前選取項目的標題文字。
  ///
  /// [newTitle] 欲更新的新標題內容。
  void updateTitle(String newTitle) {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 更新標題失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在更新索引 ${self._currentIndex} 的標題。');
    self.items[self._currentIndex] = self.currentItem.copyWith(title: newTitle);
    notifyListeners();
    _syncToDisk();
  }

  /// 更新目前選取項目的圖示。
  ///
  /// [newIcon] 欲套用的新圖示資料。
  void updateIcon(IconData newIcon) {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 更新圖示失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在更新索引 ${self._currentIndex} 的圖示。');
    self.items[self._currentIndex] = self.currentItem.copyWith(icon: newIcon);
    notifyListeners();
    _syncToDisk();
  }

  /// 設定橫向模式下的導覽列位置，並同步保存設定。
  ///
  /// [pos] 欲設定的橫向導覽列位置。
  void setLandscapeNavPosition(LandscapeNavPosition pos) {
    landscapeNavPosition = pos;
    debugPrint('[HomeControllerData] 已更新橫向導覽列位置：$pos');
    _syncConfig();
    notifyListeners();
  }

  /// 設定直向模式下的導覽列位置，並同步保存設定。
  ///
  /// [pos] 欲設定的直向導覽列位置。
  void setPortraitNavPosition(PortraitNavPosition pos) {
    portraitNavPosition = pos;
    debugPrint('[HomeControllerData] 已更新直向導覽列位置：$pos');
    _syncConfig();
    notifyListeners();
  }

  /// 將目前選取項目設定為純文字模式。
  ///
  /// 設定後會清除原有背景圖片路徑，僅保留文字內容。
  ///
  /// [text] 要設定的文字內容。
  void setAsText(String text) {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 設定純文字模式失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在將索引 ${self._currentIndex} 設為純文字模式。');
    self.items[self._currentIndex] = self.currentItem.copyWith(
      content: text,
      backgroundImagePath: '',
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 從裝置圖庫選取圖片，並儲存至應用程式文件目錄。
  ///
  /// 成功選取後，會以新圖片覆蓋目前項目的背景內容，並清空文字欄位。
  ///
  /// [maxDimension] 圖片允許的最大寬或高，用於降低記憶體負擔並避免載入過大圖片。
  Future<void> pickImage(double maxDimension) async {
    final self = this as HomeController;
    final ImagePicker picker = ImagePicker();
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 選取圖片失敗：目前項目清單為空。');
      return;
    }

    debugPrint('[HomeControllerData] 正在開啟圖庫選擇器...');
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
    );

    if (image != null) {
      debugPrint('[HomeControllerData] 已選取圖片，準備儲存至應用程式目錄。');
      // 刪除舊圖片以節省儲存空間
      await FileService.deleteFile(self.currentItem.backgroundImagePath);
      final String? savedFileName = await FileService.saveImageToDocs(
        image.path,
      );

      if (savedFileName != null) {
        debugPrint('[HomeControllerData] 圖片選取並儲存成功：$savedFileName');
        self.items[self._currentIndex] = self.currentItem.copyWith(
          content: '',
          backgroundImagePath: savedFileName,
        );
        notifyListeners();
        _syncToDisk();
      } else {
        debugPrint('[HomeControllerData] 圖片儲存失敗：未取得有效檔名。');
      }
    } else {
      debugPrint('[HomeControllerData] 使用者已取消圖片選取。');
    }
  }

  // ===============================
  // 顏色管理
  // ===============================

  /// 設定目前選取項目的文字顏色。
  ///
  /// 當 [color] 為 `null` 時，會同時標記清除自訂文字顏色。
  void setTextColor(Color? color) {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 設定文字顏色失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在更新索引 ${self._currentIndex} 的文字顏色。');
    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 設定目前選取項目的背景顏色。
  ///
  /// 當 [color] 為 `null` 時，會同時標記清除自訂背景顏色。
  void setBgColor(Color? color) {
    final self = this as HomeController;
    if (self.items.isEmpty) {
      debugPrint('[HomeControllerData] 設定背景顏色失敗：目前項目清單為空。');
      return;
    }
    debugPrint('[HomeControllerData] 正在更新索引 ${self._currentIndex} 的背景顏色。');
    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
    _syncToDisk();
  }

  /// 判斷兩個顏色是否過於接近。
  ///
  /// 此方法主要用於對比度檢查，避免前景與背景顏色過於相似而影響可讀性。
  ///
  /// 當任一顏色為 `null` 時，回傳 `false`。
  /// 若兩色 ARGB 完全一致，則直接視為相同。
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;
    if (a.toARGB32() == b.toARGB32()) return true;
    final double diff = (a.computeLuminance() - b.computeLuminance()).abs();
    return diff < 0.15;
  }

  /// 計算並回傳指定顏色的反相色。
  ///
  /// 會保留原本的透明度（Alpha），僅反轉 RGB 三個色彩通道。
  Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 1.0 - color.r,
      green: 1.0 - color.g,
      blue: 1.0 - color.b,
    );
  }

  /// 比較兩個顏色是否完全相同。
  ///
  /// 透過 ARGB 整數值進行精確比對。
  bool isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

  // ===============================
  // 匯入匯出
  // ===============================

  /// 匯出目前所有項目資料。
  ///
  /// 匯出時會將背景圖片轉為 Base64 字串並內嵌於 JSON 中，以便在其他裝置匯入時可完整還原。
  ///
  /// [context] 用於顯示匯出結果提示訊息。
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
        } else {
          debugPrint(
            '[HomeControllerData] 背景圖片轉換 Base64 失敗，略過該圖片：${item.backgroundImagePath}',
          );
        }
      }
      exportList.add(itemJson);
    }

    final String jsonStr = jsonEncode(exportList);
    final bool success = await DataExportService.exportJson(jsonStr);

    if (context.mounted) {
      if (success) {
        debugPrint('[HomeControllerData] 資料匯出成功。');
        _showSnackBar(context, t.exportok);
      } else {
        debugPrint('[HomeControllerData] 資料匯出已取消或失敗。');
        _showSnackBar(context, t.exportcancel, isError: true);
      }
    }
  }

  /// 匯入外部 JSON 設定檔，並還原其中包含的圖片資料。
  ///
  /// 若 JSON 內含 Base64 圖片內容，會先轉存為本機檔案，再建立對應的 [HomeItem]。
  ///
  /// [context] 用於顯示匯入結果提示訊息與關閉目前頁面。
  Future<void> importData(BuildContext context) async {
    debugPrint('[HomeControllerData] 啟動資料匯入流程...');
    final self = this as HomeController;
    final String? jsonStr = await DataExportService.importJson();

    if (jsonStr == null) {
      debugPrint('[HomeControllerData] 匯入已取消：未選擇任何檔案。');
      if (context.mounted) {
        _showSnackBar(context, t.nofileselected, isError: true);
      }
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
            debugPrint('[HomeControllerData] 正在還原匯入圖片檔案：$originalPath');
            String? newFileName = await FileService.saveBase64Image(
              base64,
              originalPath,
            );
            if (newFileName != null) {
              map['imagePath'] = newFileName;
              debugPrint('[HomeControllerData] 圖片還原成功：$newFileName');
            } else {
              debugPrint('[HomeControllerData] 圖片還原失敗，保留原始路徑資訊。');
            }
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
        debugPrint('[HomeControllerData] 成功匯入 ${newItems.length} 筆項目資料。');

        if (context.mounted) {
          _showSnackBar(
            context,
            '${t.importok1} ${newItems.length} ${t.importok2}',
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint('[HomeControllerData] 匯入失敗：檔案內容為空或格式無效。');
        if (context.mounted) {
          _showSnackBar(context, t.invalidconffile, isError: true);
        }
      }
    } catch (e) {
      debugPrint('[HomeControllerData] 匯入解析過程發生錯誤：$e');
      if (context.mounted) {
        _showSnackBar(context, t.conffileparsingfailed, isError: true);
      }
    }
  }
}
