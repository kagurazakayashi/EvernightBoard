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
  /// 預設標題為「項目 X」，內容為空，圖示為 Icons.star_outline。
  void addItem() {
    final self = this as HomeController;
    // 建立新的 HomeItem 並加入 items 清單
    self.items.add(
      HomeItem(
        title: '项目 ${self.items.length + 1}', // 自動編號
        content: '', // 內容預設為空
        icon: Icons.star_outline, // 預設圖示
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
    notifyListeners();
  }

  /// 將當前項目往上移動一格
  ///
  /// 如果已經是第一個，則不做任何動作。
  void moveUp() {
    final self = this as HomeController;
    if (self._currentIndex > 0) {
      // 移除當前項目
      final item = self.items.removeAt(self._currentIndex);
      // 插入到上一個位置
      self.items.insert(self._currentIndex - 1, item);
      // 更新當前索引
      self._currentIndex--;
      notifyListeners();
    }
  }

  /// 將當前項目往下移動一格
  ///
  /// 如果已經是最後一個，則不做任何動作。
  void moveDown() {
    final self = this as HomeController;
    if (self._currentIndex < self.items.length - 1) {
      // 移除當前項目
      final item = self.items.removeAt(self._currentIndex);
      // 插入到下一個位置
      self.items.insert(self._currentIndex + 1, item);
      // 更新當前索引
      self._currentIndex++;
      notifyListeners();
    }
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
    notifyListeners();
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
    notifyListeners();
  }

  /// 更新文字與背景顏色
  ///
  /// @param text 文字顏色 (可選)
  /// @param bg 背景顏色 (可選)
  void updateColors({Color? text, Color? bg}) {
    final self = this as HomeController;
    final item = self.currentItem;
    // 建立新的 HomeItem，僅更新文字顏色與背景顏色
    self.items[self._currentIndex] = HomeItem(
      title: item.title,
      content: item.content,
      icon: item.icon,
      textColor: text ?? item.textColor, // 未提供則保留原顏色
      backgroundColor: bg ?? item.backgroundColor, // 未提供則保留原顏色
      backgroundImagePath: item.backgroundImagePath,
    );
    notifyListeners();
  }
}
