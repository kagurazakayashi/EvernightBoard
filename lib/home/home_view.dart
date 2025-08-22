import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';

/// 首頁畫面元件。
///
/// 此元件作為整體主畫面的入口，負責：
/// - 建立並持有 [HomeController]
/// - 依照裝置方向切換直向／橫向版面
/// - 組合內容顯示區、觸控翻頁層與導覽元件
/// - 處理目前項目的管理操作（新增、刪除等）
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態物件。
///
/// 負責監聽控制器狀態變化，並依據目前選取項目與螢幕方向
/// 動態建立對應的 UI 版面。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，負責管理項目列表、目前索引與翻頁邏輯。
  // 初始化控制器
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器狀態變更，當資料有更新時重新建構畫面。
    // 修复 Set literal 警告：使用标准匿名函数体
    _controller.addListener(() {
      // 確認此 State 仍掛載於 Widget Tree 上，避免在已釋放後呼叫 setState。
      if (mounted) {
        // 觸發畫面重繪，讓最新狀態反映到 UI。
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
  /// 當使用者點擊的索引與目前索引相同時，代表是對當前項目的再次操作，
  /// 此時開啟管理選單；否則切換到對應項目。
  ///
  /// [index] 為被點擊的導覽項目索引。
  /// 处理导航项点击：切页或弹出管理菜单
  void _onNavTap(int index) {
    // 若點擊的是目前已選取的項目，則顯示管理選單。
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      // 否則切換目前顯示的項目。
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得目前選取的項目資料。
    final item = _controller.currentItem;

    // 取得目前主題設定。
    final theme = Theme.of(context);

    // 動態決定背景色：
    // 優先使用目前項目自訂的背景色，若未設定則改用主題 surface 色。
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;

    // 動態決定主題色：
    // 優先使用目前項目自訂文字色，若未設定則改用主題 primary 色。
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    // 使用 OrientationBuilder 依裝置方向動態切換版面。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷是否為直向畫面。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 套用動態背景色。
          backgroundColor: bgColor,

          // 橫向模式下顯示底部水平可捲動導覽列；
          // 直向模式則不顯示底部導覽列，改由側邊導覽列處理。
          // 横屏模式下显示底部的水平滚动导航栏
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  // 導覽列使用控制器中的所有項目。
                  items: _controller.items,
                  // 目前選取的索引。
                  currentIndex: _controller.currentIndex,
                  // 點擊導覽項目時的回呼。
                  onTap: _onNavTap,
                ),

          // 主要內容區採用 Stack 疊層方式，
          // 讓觸控層能覆蓋在底層，內容區再疊在其上。
          body: Stack(
            children: [
              // 1. 底層：全螢幕／分區觸控翻頁層。
              // 負責處理上一頁、下一頁的手勢或點擊互動。
              // 1. 底层：全屏/分屏触控翻页层
              TouchLayer(
                // 傳入目前是否為直向，供觸控邏輯調整互動方式。
                isPortrait: isPortrait,
                // 傳入主題色，供觸控層視覺表現使用。
                themeColor: themeColor,
                // 上一項操作。
                onPrevious: _controller.previousItem,
                // 下一項操作。
                onNext: _controller.nextItem,
              ),

              // 2. 上層：實際顯示內容與導覽版面。
              // 直向時使用含側邊導覽列的版面；
              // 橫向時只顯示內容區，導覽列放到底部。
              // 2. 上层：内容显示与侧边栏布局
              isPortrait ? _buildPortraitLayout(item) : DisplayArea(item: item),
            ],
          ),
        );
      },
    );
  }

  /// 建立直向模式下的版面配置。
  ///
  /// 直向版面包含：
  /// - 一個可捲動的側邊導覽列
  /// - 一個可擴展的內容顯示區
  ///
  /// 並依據控制器提供的 [NavSide] 決定導覽列顯示於左側或右側。
  ///
  /// [item] 為目前項目資料；此方法中主要內容仍以控制器最新狀態為準。
  /// 竖屏布局：侧边滚动导航栏 + 内容区域
  Widget _buildPortraitLayout(var item) {
    // 建立側邊可捲動導覽列。
    final nav = ScrollableSideRail(
      // 傳入所有可導覽項目。
      items: _controller.items,
      // 傳入目前選取索引。
      currentIndex: _controller.currentIndex,
      // 點擊事件處理。
      onTap: _onNavTap,
    );

    // 建立可撐滿剩餘空間的內容區。
    final content = Expanded(
      child: DisplayArea(
        // 顯示目前項目的內容。
        item: _controller.currentItem,
      ),
    );

    // 根據目前側邊位置決定導覽列顯示在左或右。
    // 如果是左側，排列順序為 [nav, content]；
    // 如果是右側，排列順序為 [content, nav]。
    // 根据重力感应结果决定导航栏在左还是在右
    return Row(
      children: _controller.currentSide == NavSide.left
          ? [nav, content]
          : [content, nav],
    );
  }

  // --- 系統層級管理彈窗（使用系統預設配色） ---

  /// 顯示目前項目的管理選單。
  ///
  /// 使用底部彈出式選單提供以下操作：
  /// - 編輯目前項目
  /// - 新增空白項目
  /// - 刪除目前項目
  void _showManagementMenu() {
    showModalBottomSheet(
      // 使用目前畫面的 BuildContext 顯示底部彈窗。
      context: context,

      // 啟用 Material 3 頂部拖曳把手樣式。
      showDragHandle: true, // Material 3 特色：顶部拖动手柄

      builder: (context) => SafeArea(
        // 使用 SafeArea 避免內容被系統區域遮住。
        child: Wrap(
          children: [
            // 編輯目前項目
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑当前项'),
              onTap: () {
                // 先關閉底部彈窗。
                Navigator.pop(context);

                // 預留未來的編輯功能入口。
                // 预留编辑功能入口
              },
            ),

            // 新增空白項目
            ListTile(
              leading: const Icon(Icons.add_to_photos),
              title: const Text('新增空白项'),
              onTap: () {
                // 先關閉底部彈窗。
                Navigator.pop(context);

                // 透過控制器新增一個空白項目。
                _controller.addItem();
              },
            ),

            // 刪除目前項目
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('删除当前项', style: TextStyle(color: Colors.red)),
              onTap: () {
                // 先關閉底部彈窗。
                Navigator.pop(context);

                // 顯示二次確認對話框，避免誤刪。
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
  /// 若使用者確認刪除，則呼叫控制器刪除目前項目。
  /// 當刪除後列表為空時，控制器應依既有邏輯建立預設項目。
  void _confirmDelete() {
    showDialog(
      // 使用目前畫面的 BuildContext 顯示對話框。
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后如果列表为空，系统将自动创建一个默认项。'),
        actions: [
          // 取消按鈕：僅關閉對話框。
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),

          // 確認刪除按鈕：關閉對話框後刪除目前項目。
          TextButton(
            onPressed: () {
              // 關閉確認對話框。
              Navigator.pop(context);

              // 執行刪除目前項目。
              _controller.deleteCurrentItem();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
