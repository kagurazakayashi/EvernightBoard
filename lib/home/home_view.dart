import 'package:flutter/material.dart';

/// 匯入圖示挑選器的設定模型，用於限制可選圖示來源與對話框行為。
import 'package:flutter_iconpicker/Models/configuration.dart';

/// 匯入首頁控制器，負責首頁資料與互動邏輯管理。
import 'home_controller.dart';

/// 匯入內容顯示區元件，用於呈現目前選中的頁面內容。
import 'widgets/display_area.dart';

/// 匯入觸控層元件，用於處理左右切換等手勢操作。
import 'widgets/touch_layer.dart';

/// 匯入可橫向捲動的底部導覽列元件。
import 'widgets/scrollable_nav_bar.dart';

/// 匯入可捲動的側邊導覽列元件。
import 'widgets/scrollable_side_rail.dart';

/// 匯入管理功能選單元件，用於編輯、複製、刪除與設定操作。
import 'widgets/management_grid_menu.dart';

/// 匯入圖示挑選器套件，用於顯示圖示選擇對話框。
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

/// 匯入顏色挑選器套件，用於選取文字或背景顏色。
import 'package:flex_color_picker/flex_color_picker.dart';

/// 匯入設定頁面。
import '../settings/settings_view.dart';

/// 首頁畫面元件。
///
/// 此頁面負責：
/// - 顯示目前選中的內容項目
/// - 根據直向或橫向方向切換不同版面
/// - 開啟管理選單以編輯圖示、標題、文字、圖片與顏色
/// - 導向設定頁面
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態類別。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，集中管理目前頁面狀態與資料操作。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器狀態變更，當資料更新時重新建構畫面。
    _controller.addListener(() {
      // 確保元件仍掛載於 Widget Tree 上，避免在已卸載狀態呼叫 setState。
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 釋放控制器資源，避免記憶體洩漏。
    _controller.dispose();
    super.dispose();
  }

  /// 處理導覽項目點擊事件。
  ///
  /// 若使用者再次點擊目前已選取的項目，則開啟管理選單；
  /// 否則切換到指定索引的項目。
  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      _controller.changeIndex(index);
    }
  }

  /// 開啟顏色挑選器對話框。
  ///
  /// [title] 為對話框標題。
  /// [initialColor] 為初始顏色。
  /// [onColorChanged] 會在顏色變更時即時回呼。
  /// [isTextType] 用來判斷目前設定的是文字色還是背景色。
  ///
  /// 若使用者確認顏色後，會檢查文字色與背景色是否過於接近；
  /// 若太相近則還原原始顏色並顯示警告提示。
  Future<void> _openColorPicker({
    required String title,
    required Color? initialColor,
    required Function(Color?) onColorChanged,
    required bool isTextType,
  }) async {
    // 保留原始顏色，以便取消或驗證失敗時還原。
    final Color? originalColor = initialColor;

    // 記錄使用者最後挑選的顏色。
    Color? latestPickedColor = initialColor;

    // 顯示顏色挑選器對話框，並取得是否確認的結果。
    final bool isConfirmed =
        await ColorPicker(
          color:
              initialColor ?? (isTextType ? Colors.cyanAccent : Colors.black87),
          onColorChanged: (Color color) {
            // 即時記錄最新顏色，並同步通知外部更新。
            latestPickedColor = color;
            onColorChanged(color);
          },
          width: 44,
          height: 44,
          borderRadius: 22,
          heading: Text(title),
          pickersEnabled: const {
            // 僅啟用主色盤，不啟用 accent 色盤。
            ColorPickerType.primary: true,
            ColorPickerType.accent: false,
          },
        ).showPickerDialog(
          context,
          constraints: const BoxConstraints(
            minHeight: 400,
            minWidth: 300,
            maxWidth: 320,
          ),
        );

    // 使用者按下確認後，再進行顏色相似度檢查。
    if (isConfirmed == true) {
      final item = _controller.currentItem;

      // 當沒有背景圖片且內容為空時，視為預設空白狀態。
      final bool isDefaultImage =
          (item.backgroundImagePath?.isEmpty ?? true) && item.content.isEmpty;

      // 當內容為空且已有背景圖片時，視為純圖片模式。
      final bool isPureImageMode = item.content.isEmpty && !isDefaultImage;

      // 純圖片模式下不檢查文字色與背景色相似度。
      if (!isPureImageMode) {
        // 若目前設定的是文字色，則比對背景色；反之則比對文字色。
        final Color? otherColor = isTextType
            ? item.backgroundColor
            : item.textColor;

        // 若顏色太接近，還原設定並提示使用者重新選擇。
        if (_controller.isTooSimilar(latestPickedColor, otherColor)) {
          onColorChanged(originalColor);
          _showWarningHint('背景颜色和文字颜色太相近了，请重新设置！');
          return;
        }
      }
    } else {
      // 若使用者取消，則還原為原始顏色。
      onColorChanged(originalColor);
    }
  }

  /// 顯示警告提示訊息。
  ///
  /// 使用黃色 SnackBar 顯示內容，以提升警示辨識度。
  void _showWarningHint(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 取得目前選中的項目資料。
    final item = _controller.currentItem;

    // 取得目前主題。
    final theme = Theme.of(context);

    // 決定畫面背景色，若未設定則使用主題預設 surface 色。
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 決定主題色，通常用於文字或互動元件顏色。
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向模式。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          backgroundColor: bgColor,

          // 橫向模式時顯示底部導覽列；直向模式則改用側邊導覽。
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  items: _controller.items,
                  currentIndex: _controller.currentIndex,
                  onTap: _onNavTap,
                ),

          body: Stack(
            children: [
              // 最底層觸控區，負責上一頁／下一頁等手勢互動。
              TouchLayer(
                isPortrait: isPortrait,
                themeColor: themeColor,
                onPrevious: _controller.previousItem,
                onNext: _controller.nextItem,
              ),

              // 依照螢幕方向切換不同版面配置。
              isPortrait ? _buildPortraitLayout(item) : DisplayArea(item: item),
            ],
          ),
        );
      },
    );
  }

  /// 建立直向模式下的版面配置。
  ///
  /// 直向模式會以左右排列方式顯示側邊導覽與內容區，
  /// 並依據目前設定決定導覽列顯示在左側或右側。
  Widget _buildPortraitLayout(var item) {
    // 建立側邊導覽列。
    final nav = ScrollableSideRail(
      items: _controller.items,
      currentIndex: _controller.currentIndex,
      onTap: _onNavTap,
    );

    // 建立主內容區。
    final content = Expanded(child: DisplayArea(item: _controller.currentItem));

    return Row(
      children: _controller.currentSide == NavSide.left
          ? [nav, content]
          : [content, nav],
    );
  }

  /// 顯示管理功能選單。
  ///
  /// 使用底部彈出面板提供各種管理操作，例如：
  /// - 編輯圖示與標題
  /// - 設定全螢幕文字或背景圖片
  /// - 修改文字色與背景色
  /// - 調整項目順序
  /// - 新增、複製、刪除項目
  /// - 開啟設定頁
  void _showManagementMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onEditIcon: () async {
          // 先關閉管理選單，再開啟圖示選擇器。
          Navigator.pop(context);

          IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: const SinglePickerConfiguration(
              // 僅允許選擇 Material 圖示。
              iconPackModes: [IconPack.material],
              searchHintText: '',
              title: Text(''),
            ),
          );

          // 若有成功選取圖示，則更新目前項目的圖示。
          if (selectedIcon != null) {
            _controller.updateIcon(selectedIcon.data);
          }
        },
        onEditTitle: () {
          Navigator.pop(context);
          _showEditDialog(
            '边栏标题',
            _controller.currentItem.title,
            _controller.updateTitle,
            isMultiline: false,
          );
        },
        onSetText: () {
          Navigator.pop(context);
          _showEditDialog(
            '全屏文字',
            _controller.currentItem.content,
            _controller.setAsText,
            isMultiline: true,
          );
        },

        onSetImage: () async {
          Navigator.pop(context);

          // 取得螢幕尺寸，並以較長邊作為圖片選擇或處理的尺寸上限。
          final Size screenSize = MediaQuery.sizeOf(context);

          final double limit = screenSize.width > screenSize.height
              ? screenSize.width
              : screenSize.height;

          await _controller.pickImage(limit);
        },

        onSetTextColor: () async {
          Navigator.pop(context);
          await _openColorPicker(
            title: '文字颜色',
            isTextType: true,
            initialColor: _controller.currentItem.textColor,
            onColorChanged: (color) => _controller.setTextColor(color),
          );
        },
        onSetBgColor: () async {
          Navigator.pop(context);
          await _openColorPicker(
            title: '背景颜色',
            isTextType: false,
            initialColor: _controller.currentItem.backgroundColor,
            onColorChanged: (color) => _controller.setBgColor(color),
          );
        },
        onMoveUp: () {
          // 將目前項目往前移動一格。
          _controller.moveUp();
        },
        onMoveDown: () {
          // 將目前項目往後移動一格。
          _controller.moveDown();
        },

        onAdd: () {
          Navigator.pop(context);
          _controller.addItem();
        },
        onCopy: () {
          Navigator.pop(context);
          _controller.copyCurrentItem();
        },
        onDelete: () {
          Navigator.pop(context);

          // 刪除目前項目後，顯示簡短提示訊息。
          _controller.deleteCurrentItem();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已刪除該項'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        onOpenSettings: () {
          Navigator.pop(context);

          // 導向設定頁面，並共用同一個控制器實例。
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsView(controller: _controller),
            ),
          );
        },
      ),
    );
  }

  /// 顯示文字編輯對話框。
  ///
  /// [title] 為對話框標題。
  /// [initialValue] 為文字輸入框的初始內容。
  /// [onConfirm] 為使用者按下確認後的回呼。
  /// [isMultiline] 控制是否允許多行輸入。
  void _showEditDialog(
    String title,
    String initialValue,
    Function(String) onConfirm, {
    bool isMultiline = false,
  }) {
    // 建立文字輸入控制器，並帶入原始內容。
    final textController = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,

          // 多行模式下不限制行數；單行模式僅允許 1 行。
          maxLines: isMultiline ? null : 1,
          keyboardType: isMultiline
              ? TextInputType.multiline
              : TextInputType.text,
          decoration: const InputDecoration(
            hintText: "请输入内容...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            // 關閉對話框，不儲存變更。
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 將輸入內容回傳給呼叫端處理，然後關閉對話框。
              onConfirm(textController.text);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
