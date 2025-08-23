import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';

/// 主頁面元件
///
/// 負責呈現首頁的整體 UI，包括底部導航列、側邊導航列、觸控層以及內容區
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// 控制首頁狀態及資料的控制器
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器變化，若畫面已掛載則刷新 UI
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 清理控制器資源
    _controller.dispose();
    super.dispose();
  }

  /// 導航列點擊事件
  ///
  /// 若點擊當前項目則顯示管理選單，否則切換到點擊的索引
  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得當前項目
    final item = _controller.currentItem;

    final theme = Theme.of(context);

    // 背景顏色，若項目未設定則使用主題表面色
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 主題文字顏色，若未設定則使用主題主要色
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          backgroundColor: bgColor,

          // 若為橫向，顯示底部可滾動導航列
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  items: _controller.items,
                  currentIndex: _controller.currentIndex,
                  onTap: _onNavTap,
                ),

          body: Stack(
            children: [
              // 觸控層，用於滑動切換前後頁
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
    final nav = ScrollableSideRail(
      items: _controller.items,
      currentIndex: _controller.currentIndex,
      onTap: _onNavTap,
    );

    final content = Expanded(child: DisplayArea(item: _controller.currentItem));

    return Row(
      children: _controller.currentSide == NavSide.left
          ? [nav, content]
          : [content, nav],
    );
  }

  /// 顯示管理選單
  ///
  /// 提供新增、刪除、上下移動、編輯標題、圖示及文字、文字顏色與背景顏色等操作
  void _showManagementMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onAdd: () {
          Navigator.pop(context);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete();
        },
        onMoveUp: () {
          Navigator.pop(context);
        },
        onMoveDown: () {
          Navigator.pop(context);
        },
        onEditTitle: () {
          Navigator.pop(context);
        },
        onEditIcon: () {
          Navigator.pop(context);
        },
        onSetText: () {
          Navigator.pop(context);
        },
        onSetImage: () {
          Navigator.pop(context);
        },
        onSetTextColor: () {
          Navigator.pop(context);
        },
        onSetBgColor: () {
          Navigator.pop(context);
        },
        onCopy: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// 顯示刪除確認對話框
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后如果列表为空，系统将自动创建一个默认项。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
