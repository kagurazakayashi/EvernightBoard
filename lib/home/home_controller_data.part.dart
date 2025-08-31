part of 'home_controller.dart';

/// HomeControllerData 混入，用於管理 Home 項目的資料操作
///
/// 提供新增、刪除、複製、移動、更新標題、圖示、文字與背景等功能。
/// 使用 ChangeNotifier，可在資料更新時通知 UI 重新繪製。
mixin HomeControllerData on ChangeNotifier {
  /// 初始化資料
  ///
  /// 若 items 為空，會自動新增一個預設項目以確保至少有一個項目存在。
  void _initData() {
    final self = this as HomeController;
    // 若 items 是空的，新增一個預設項目
    if (self.items.isEmpty) {
      addItem();
    }
  }

  /// 新增一個 HomeItem 項目
  ///
  /// 預設標題為「新屏幕」，內容為空，圖示為 Icons.fullscreen。
  void addItem() {
    final self = this as HomeController;
    // 建立新的 HomeItem 並加入 items 清單
    self.items.add(
      HomeItem(
        title: '新屏幕', // 預設標題
        content: '', // 內容預設為空
        icon: Icons.fullscreen, // 預設圖示
        textColor: null, // 文字顏色預設為 null
        backgroundColor: null, // 背景顏色預設為 null
        backgroundImagePath: '', // 背景圖片預設為空
      ),
    );
    // 將當前索引設為新增項目的位置
    self._currentIndex = self.items.length - 1;
    // 通知 UI 更新
    notifyListeners();
  }

  /// 刪除當前選中的項目
  ///
  /// 若刪除後 items 為空，會自動新增一個預設項目。
  void deleteCurrentItem() {
    final self = this as HomeController;
    // 移除當前索引的項目
    self.items.removeAt(self._currentIndex);

    if (self.items.isEmpty) {
      // 若刪完後沒項目，新增一個預設項目
      addItem();
    } else {
      // 若當前索引超過範圍，調整為最後一個
      if (self._currentIndex >= self.items.length) {
        self._currentIndex = self.items.length - 1;
      }
      // 通知 UI 更新
      notifyListeners();
    }
  }

  /// 複製當前項目
  ///
  /// 會在當前項目之後插入一個完全相同的副本。
  void copyCurrentItem() {
    final self = this as HomeController;
    final current = self.currentItem;

    // 建立一個完全一致的新物件
    final newItem = HomeItem(
      title: "${current.title} (副本)", // 標題加上副本標示
      content: current.content,
      icon: current.icon,
      textColor: current.textColor,
      backgroundColor: current.backgroundColor,
      backgroundImagePath: current.backgroundImagePath,
    );

    // 在當前位置之後插入副本
    self.items.insert(self._currentIndex + 1, newItem);
    // 更新當前索引為副本的位置
    self._currentIndex++;
    // 通知 UI 更新
    notifyListeners();
  }

  /// 將當前項目往上移動一格
  ///
  /// 如果已經是第一個，則不做任何動作。
  void moveUp() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;

    final int len = self.items.length;
    // 計算新位置：(當前 - 1 + 總長度) % 總長度
    int newIndex = (self._currentIndex - 1 + len) % len;

    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);

    self._currentIndex = newIndex;
    notifyListeners();
  }

  /// 將當前項目往下移動一格
  ///
  /// 如果已經是最後一個，則不做任何動作。
  void moveDown() {
    final self = this as HomeController;
    if (self.items.length <= 1) return;

    final int len = self.items.length;
    // 計算新位置：(當前 + 1) % 總長度
    int newIndex = (self._currentIndex + 1) % len;

    final item = self.items.removeAt(self._currentIndex);
    self.items.insert(newIndex, item);

    self._currentIndex = newIndex;
    notifyListeners();
  }

  /// 更新當前項目的標題
  ///
  /// @param newTitle 新的標題字串
  void updateTitle(String newTitle) {
    final self = this as HomeController;
    final item = self.currentItem;
    // 建立新的 HomeItem，僅更新標題，保留其他屬性
    self.items[self._currentIndex] = HomeItem(
      title: newTitle,
      content: item.content,
      icon: item.icon,
      textColor: item.textColor,
      backgroundColor: item.backgroundColor,
      backgroundImagePath: item.backgroundImagePath,
    );
    // 通知 UI 更新
    notifyListeners();
  }

  /// 呼叫相簿並根據限制尺寸更新圖片
  /// 呼叫相簿並更新圖片，支援等比例縮放
  Future<void> pickImage(double maxDimension) async {
    final self = this as HomeController;
    final ImagePicker picker = ImagePicker();

    // 核心邏輯：
    // maxWidth 和 maxHeight 同時設定時，外掛會自動進行等比例縮放。
    // 它會挑選圖片最長的一邊縮放到 maxDimension，另一邊按比例自動調整。
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension, // 限制最大寬度
      maxHeight: maxDimension, // 限制最大高度
      imageQuality: 85, // 質量
    );

    if (image != null) {
      final item = self.currentItem;
      self.items[self._currentIndex] = HomeItem(
        title: item.title,
        content: '',
        icon: item.icon,
        textColor: item.textColor,
        backgroundColor: item.backgroundColor,
        backgroundImagePath: image.path,
      );
      notifyListeners();

      debugPrint(
        "imagePath=${image.path}, maxDimension=${maxDimension.toString()}",
      );
    }
  }

  /// 更新當前項目的圖示
  ///
  /// @param newIcon 新的 IconData
  void updateIcon(IconData newIcon) {
    final self = this as HomeController;
    final item = self.currentItem;
    // 建立新的 HomeItem，僅更新圖示
    self.items[self._currentIndex] = HomeItem(
      title: item.title,
      content: item.content,
      icon: newIcon,
      textColor: item.textColor,
      backgroundColor: item.backgroundColor,
      backgroundImagePath: item.backgroundImagePath,
    );
    // 通知 UI 更新
    notifyListeners();
  }

  /// 將當前項目設定為文字內容
  ///
  /// @param text 文字內容
  void setAsText(String text) {
    final self = this as HomeController;
    final item = self.currentItem;
    // 建立新的 HomeItem，文字內容更新，背景圖片清空
    self.items[self._currentIndex] = HomeItem(
      title: item.title,
      content: text,
      icon: item.icon,
      textColor: item.textColor,
      backgroundColor: item.backgroundColor,
      backgroundImagePath: '', // 純文字，清空背景圖
    );
    // 通知 UI 更新
    notifyListeners();
  }

  /// 將當前項目設定為圖片內容
  ///
  /// @param path 圖片路徑
  void setAsImage(String path) {
    final self = this as HomeController;
    final item = self.currentItem;
    // 建立新的 HomeItem，圖片內容更新，文字內容清空
    self.items[self._currentIndex] = HomeItem(
      title: item.title,
      content: '', // 純圖片，清空文字
      icon: item.icon,
      textColor: item.textColor,
      backgroundColor: item.backgroundColor,
      backgroundImagePath: path,
    );
    // 通知 UI 更新
    notifyListeners();
  }

  void setTextColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      textColor: color,
      clearTextColor: color == null,
    );
    notifyListeners();
  }

  /// 设置背景颜色
  void setBgColor(Color? color) {
    final self = this as HomeController;
    self.items[self._currentIndex] = self.currentItem.copyWith(
      backgroundColor: color,
      clearBgColor: color == null,
    );
    notifyListeners();
  }

  // 檢查兩個顏色是否過於相近 (基於亮度差)
  /// 閾值 0.1 通常意味著肉眼很難分辨文字和背景
  bool isTooSimilar(Color? a, Color? b) {
    if (a == null || b == null) return false;

    // 如果完全一致
    if (a.toARGB32() == b.toARGB32()) return true;

    // 如果相對亮度差小於xx
    final double luminanceDiff = (a.computeLuminance() - b.computeLuminance())
        .abs();
    return luminanceDiff < 0.1;
  }

  /// 更新文字與背景顏色並處理顏色衝突
  ///
  /// @param text 文字顏色 (可選)
  /// @param bg 背景顏色 (可選)
  bool updateColors({Color? text, Color? bg}) {
    final self = this as HomeController;
    final item = self.currentItem;
    bool didInvert = false;
    if (item.textColor == null || item.backgroundColor == null) return false;

    // 獲取當前事實上的顏色（處理 null 預設值情況）
    Color currentTxt = item.textColor!;
    Color currentBg = item.backgroundColor!;

    Color? nextTxt = text ?? item.textColor;
    Color? nextBg = bg ?? item.backgroundColor;

    // 衝突檢測：如果新設定的顏色與另一個顏色相同
    if (text != null && _isSameColor(text, currentBg)) {
      nextBg = _invertColor(text);
      didInvert = true;
    } else if (bg != null && _isSameColor(bg, currentTxt)) {
      nextTxt = _invertColor(bg);
      didInvert = true;
    }

    self.items[self._currentIndex] = HomeItem(
      title: item.title,
      content: item.content,
      icon: item.icon,
      textColor: nextTxt,
      backgroundColor: nextBg,
      backgroundImagePath: item.backgroundImagePath,
    );

    notifyListeners();
    return didInvert; // 返回是否發生了自動調整
  }

  // 使用 toARGB32() 替代 .value 進行顏色相等判斷
  bool _isSameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

  // 使用 Color.from 建構函式（接受 0.0 - 1.0 的浮點數）
  // 使用 .r, .g, .b, .a 訪問器（替代舊的 .red, .green, .blue, .alpha）
  Color _invertColor(Color color) {
    return Color.from(
      alpha: color.a, // 保持原有的不透明度
      red: 1.0 - color.r, // 紅色分量取反
      green: 1.0 - color.g, // 綠色分量取反
      blue: 1.0 - color.b, // 藍色分量取反
    );
  }
}
