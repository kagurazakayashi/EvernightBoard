import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';

/// 首頁主視圖。
///
/// 負責：
/// - 建立並持有 [HomeController]
/// - 根據螢幕方向切換直向／橫向版面
/// - 顯示主要內容區與導覽元件
/// - 處理底部管理選單與刪除確認流程
class HomeView extends StatefulWidget {
  /// 建立首頁視圖。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態物件。
///
/// 這一層主要負責 UI 狀態同步與互動事件轉送，
/// 實際的資料與項目切換邏輯由 [HomeController] 管理。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，負責管理目前項目、導覽位置與增刪切換等操作。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽 controller 狀態變化。
    // 當資料更新時，若目前 Widget 仍掛載於畫面樹上，則重新建構畫面。
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 釋放 controller 資源，避免監聽器或其他資源洩漏。
    _controller.dispose();
    super.dispose();
  }

  /// 處理導覽項目點擊事件。
  ///
  /// 當使用者點擊目前已選取的項目時，顯示管理選單；
  /// 若點擊的是其他項目，則切換到對應索引。
  void _onNavTap(int index) {
    // 若點擊的是目前項目，開啟管理功能選單。
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      // 否則切換到新的項目。
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得目前顯示中的項目資料，方便後續版面使用。
    final item = _controller.currentItem;

    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向模式。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 以目前項目的背景色作為整體頁面背景。
          backgroundColor: item.backgroundColor,

          // 橫向時顯示底部可捲動導覽列；直向時不顯示。
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  items: _controller.items,
                  currentIndex: _controller.currentIndex,
                  onTap: _onNavTap,
                ),

          body: Stack(
            children: [
              // 觸控互動層：
              // 提供前後切換手勢與主題色設定。
              TouchLayer(
                isPortrait: isPortrait,
                themeColor: item.textColor,
                onPrevious: _controller.previousItem,
                onNext: _controller.nextItem,
              ),

              // 直向顯示側邊導覽＋內容區的橫向排列版面；
              // 橫向則直接顯示內容區。
              isPortrait ? _buildPortraitLayout() : DisplayArea(item: item),
            ],
          ),
        );
      },
    );
  }

  /// 建立直向模式下的版面配置。
  ///
  /// 直向模式會使用左右側欄導覽，
  /// 並依照目前設定的 [NavSide] 決定導覽列位於左側或右側。
  Widget _buildPortraitLayout() {
    // 建立可捲動的側邊導覽列。
    final nav = ScrollableSideRail(
      items: _controller.items,
      currentIndex: _controller.currentIndex,
      onTap: _onNavTap,
    );

    // 建立主要內容區，並使用 Expanded 佔滿剩餘空間。
    final content = Expanded(child: DisplayArea(item: _controller.currentItem));

    return Row(
      // 根據目前側欄方向，決定導覽列與內容區的排列順序。
      children: _controller.currentSide == NavSide.left
          ? [nav, content]
          : [content, nav],
    );
  }

  /// 顯示管理功能底部彈窗。
  ///
  /// 提供三個操作：
  /// - 编辑
  /// - 新增
  /// - 删除
  ///
  /// 備註：此處僅負責 View 層互動與操作入口，實際資料處理由 controller 執行。
  // --- 管理弹窗 (逻辑保持在 View 层，使用系统默认配色) ---
  void _showManagementMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // 編輯：目前僅關閉彈窗，尚未接入實際編輯流程。
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () => Navigator.pop(context),
            ),

            // 新增：先關閉彈窗，再新增項目。
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('新增'),
              onTap: () {
                Navigator.pop(context);
                _controller.addItem();
              },
            ),

            // 刪除：先關閉彈窗，再顯示刪除確認對話框。
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示刪除確認對話框。
  ///
  /// 若目前只剩最後一個項目，則禁止刪除並顯示提示；
  /// 否則顯示確認視窗，讓使用者決定是否刪除目前項目。
  void _confirmDelete() {
    // 若只剩一筆資料，禁止刪除，避免清空到完全沒有項目。
    if (_controller.items.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('不可删除最后一项')));
      return;
    }

    // 顯示刪除確認對話框。
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        actions: [
          // 取消：僅關閉對話框。
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),

          // 刪除：先關閉對話框，再刪除目前項目。
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteCurrentItem();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
