import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

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
            '修改邊欄標題',
            _controller.currentItem.title,
            _controller.updateTitle,
          );
        },
        onSetText: () {
          Navigator.pop(context);
          _showEditDialog(
            '配置要顯示的文字',
            _controller.currentItem.content,
            _controller.setAsText,
          );
        },
        onSetImage: () async {
          // 1. 關閉選單，因為接下來的相簿是系統級介面
          Navigator.pop(context);

          // 2. 呼叫控制器的圖片選擇邏輯
          await _controller.pickImage();
        },

        // 第二行操作：設定文字顏色、背景顏色、上下移動
        onSetTextColor: () {
          Navigator.pop(context);
          _controller.updateColors(text: Colors.orange); // 更新文字顏色
        },
        onSetBgColor: () {
          Navigator.pop(context);
          _controller.updateColors(bg: Colors.blueGrey[900]); // 更新背景顏色
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

  /// 顯示文字或標題編輯對話框
  ///
  /// [title] 對話框標題
  /// [initialValue] 初始文字
  /// [onConfirm] 確認後回調
  void _showEditDialog(
    String title,
    String initialValue,
    Function(String) onConfirm,
  ) {
    final textController = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: textController, autofocus: true),
        actions: [
          // 取消按鈕
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          // 確定按鈕
          TextButton(
            onPressed: () {
              onConfirm(textController.text); // 回傳使用者輸入文字
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
