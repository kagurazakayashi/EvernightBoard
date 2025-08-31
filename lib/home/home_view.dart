import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// 主頁面元件
///
/// 此元件為應用首頁的主要畫面，負責呈現整體 UI，包括：
/// - 底部導航列 (橫向模式時)
/// - 側邊導航列 (直向模式時)
/// - 觸控層，用於滑動切換前後項目
/// - 內容顯示區
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// 控制首頁狀態與資料的控制器
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器狀態改變，畫面已掛載則刷新 UI
    _controller.addListener(() {
      if (mounted) {
        setState(() {}); // 畫面刷新
      }
    });
  }

  @override
  void dispose() {
    // 釋放控制器資源
    _controller.dispose();
    super.dispose();
  }

  /// 導航列點擊事件處理
  ///
  /// 若點擊當前項目則顯示管理選單，否則切換到點擊的索引
  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      _showManagementMenu(); // 顯示管理選單
    } else {
      _controller.changeIndex(index); // 切換到新的索引
    }
  }

  Future<void> _openColorPicker({
    required String title,
    required Color? initialColor,
    required Function(Color?) onColorChanged,
    required bool isTextType,
  }) async {
    final Color? originalColor = initialColor;
    Color? latestPickedColor = initialColor;

    final bool? isConfirmed =
        await ColorPicker(
          color:
              initialColor ?? (isTextType ? Colors.cyanAccent : Colors.black87),
          onColorChanged: (Color color) {
            latestPickedColor = color;
            onColorChanged(color);
          },
          width: 44,
          height: 44,
          borderRadius: 22,
          heading: Text(title),
          pickersEnabled: const {
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

    if (isConfirmed == true) {
      final item = _controller.currentItem;

      // 1. 判斷是否為預設圖片狀態 (路徑為空且文字為空)
      final bool isDefaultImage =
          (item.backgroundImagePath?.isEmpty ?? true) && item.content.isEmpty;

      // 2. 按照你的要求：顯示文字為空 並且 不是預設圖片 -> 判定為“純圖片模式”
      // 只有這種模式下才會跳過顏色校驗
      final bool isPureImageMode = item.content.isEmpty && !isDefaultImage;

      // 3. 如果不是純圖片模式（即：正在顯示文字，或者是預設圖狀態），則執行衝突檢查
      if (!isPureImageMode) {
        final Color? otherColor = isTextType
            ? item.backgroundColor
            : item.textColor;
        if (_controller.isTooSimilar(latestPickedColor, otherColor)) {
          onColorChanged(originalColor); // 攔截回滾
          _showWarningHint('背景颜色和文字颜色太相近了，请重新设置！');
          return;
        }
      }

      // 如果是圖片模式，或者校驗透過，則不做任何攔截，直接保留 onColorChanged 已更新的狀態
    } else {
      // 使用者取消：回滾到開啟前的顏色
      onColorChanged(originalColor);
    }
  }

  /// 顏色相近警告提示
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
    // 取得當前選中項目
    final item = _controller.currentItem;

    // 取得主題資料
    final theme = Theme.of(context);

    // 背景顏色，若項目未設定則使用主題 surface 色
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 主題文字顏色，若未設定則使用主題 primary 色
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isPortrait = orientation == Orientation.portrait; // 判斷直向模式

        return Scaffold(
          backgroundColor: bgColor,

          // 若為橫向，顯示底部可滾動導航列；直向則不顯示
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  items: _controller.items,
                  currentIndex: _controller.currentIndex,
                  onTap: _onNavTap,
                ),

          body: Stack(
            children: [
              // 觸控層，用於滑動切換前後項
              TouchLayer(
                isPortrait: isPortrait,
                themeColor: themeColor,
                onPrevious: _controller.previousItem,
                onNext: _controller.nextItem,
              ),

              // 根據方向顯示不同的內容區
              isPortrait ? _buildPortraitLayout(item) : DisplayArea(item: item),
            ],
          ),
        );
      },
    );
  }

  /// 建立直向模式下的頁面佈局
  ///
  /// 左側或右側為側邊導航列，另一側為內容區
  Widget _buildPortraitLayout(var item) {
    // 側邊導航列
    final nav = ScrollableSideRail(
      items: _controller.items,
      currentIndex: _controller.currentIndex,
      onTap: _onNavTap,
    );

    // 內容區，使用 Expanded 填滿剩餘空間
    final content = Expanded(child: DisplayArea(item: _controller.currentItem));

    // 根據目前側邊導航列位置返回 Row
    return Row(
      children: _controller.currentSide == NavSide.left
          ? [nav, content] // 側邊在左
          : [content, nav], // 側邊在右
    );
  }

  /// 顯示管理選單
  ///
  /// 提供操作：新增、複製、刪除、上下移動、編輯標題、編輯圖示與文字、文字顏色、背景顏色
  void _showManagementMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true, // 顯示拖動手把
      builder: (context) => ManagementGridMenu(
        // 第一行操作：編輯圖示、編輯標題、文字、圖片
        onEditIcon: () async {
          // 1. 先關閉底部選單，避免 UI 疊加
          Navigator.pop(context);

          // 2. 顯示圖示選擇器
          IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: const SinglePickerConfiguration(
              iconPackModes: [IconPack.material],
              searchHintText: '',
              title: Text(''),
            ),
          );

          // 3. 處理返回結果
          if (selectedIcon != null) {
            // 更新 Controller 中的圖示資料
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
        // 設為圖片
        onSetImage: () async {
          Navigator.pop(context);

          // 1. 獲取螢幕尺寸
          final Size screenSize = MediaQuery.sizeOf(context);

          // 2. 計算螢幕最長邊 (取寬高的最大值)
          // 比如手機豎屏是 390x844，則 limit 為 844
          // 這樣圖片匯入後，最長的一邊不會超過 844，且比例不變
          final double limit = screenSize.width > screenSize.height
              ? screenSize.width
              : screenSize.height;

          // 3. 傳入限制值進行圖片挑選
          await _controller.pickImage(limit);
        },

        // 第二行操作：設定文字顏色、背景顏色、上下移動
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
          _controller.moveUp(); // 上移項目
        },
        onMoveDown: () {
          _controller.moveDown(); // 下移項目
        },

        // 第三行操作：新增、複製、刪除
        onAdd: () {
          Navigator.pop(context);
          _controller.addItem(); // 新增項目
        },
        onCopy: () {
          Navigator.pop(context);
          _controller.copyCurrentItem(); // 複製當前項目
        },
        onDelete: () {
          // 1. 先關閉宮格選單
          Navigator.pop(context);

          // 2. 執行刪除邏輯
          // 控制器會自動判斷：若列表空則新增預設項目
          _controller.deleteCurrentItem();

          // 顯示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已刪除該項'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  /// 顏色取反提示資訊
  // void _showInvertHint(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Icon(Icons.auto_fix_high, color: Colors.white),
  //           const SizedBox(width: 10),
  //           Text(message),
  //         ],
  //       ),
  //       backgroundColor: Colors.blueAccent,
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  /// 顯示文字或標題編輯對話框
  ///
  /// [title] 對話框標題
  /// [initialValue] 初始文字
  /// [onConfirm] 確認後回調
  void _showEditDialog(
    String title,
    String initialValue,
    Function(String) onConfirm, {
    bool isMultiline = false,
  }) {
    final textController = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          // 如果是多行模式，不限制行數，並允許回車換行
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
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
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
