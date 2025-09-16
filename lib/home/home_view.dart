import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';
import 'widgets/edit_text_dialog.dart';
import 'widgets/color_picker_handler.dart';
import '../settings/settings_view.dart';

/// 首頁畫面元件。
///
/// 此畫面主要負責：
/// - 顯示目前選取的全螢幕內容
/// - 根據橫豎屏切換不同的導覽介面
/// - 接收點擊、管理選單與設定操作
/// - 與 [HomeController] 同步狀態變化
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態類別。
///
/// 內部持有 [HomeController]，並監聽其狀態變化，
/// 在資料或目前項目改變時重新建構畫面。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器實例。
  ///
  /// 負責管理首頁資料、導覽狀態、感測器與音量控制等邏輯。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 註冊控制器監聽，當狀態改變時同步刷新畫面。
    _controller.addListener(_updateUI);
    debugPrint('[_HomeViewState] 已註冊控制器監聽');
  }

  /// 收到控制器通知時更新畫面。
  ///
  /// 僅在目前 State 仍掛載於 Widget Tree 時呼叫 [setState]，
  /// 避免元件已銷毀後仍更新 UI 而產生例外。
  void _updateUI() {
    if (mounted) {
      debugPrint('[_HomeViewState] 控制器狀態已更新，重新整理畫面');
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 先移除監聽，再釋放控制器，避免銷毀後仍收到通知。
    _controller.removeListener(_updateUI);
    debugPrint('[_HomeViewState] 已移除控制器監聽');

    _controller.dispose();
    debugPrint('[_HomeViewState] 已釋放控制器');

    super.dispose();
  }

  /// 處理導覽項目點擊事件。
  ///
  /// 若點擊的是目前已選取的項目，則開啟管理選單；
  /// 否則切換到對應的項目索引。
  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      debugPrint('[_HomeViewState] 點擊目前項目，開啟管理選單');
      _showManagementMenu();
    } else {
      debugPrint('[_HomeViewState] 點擊導覽項目，切換到索引：$index');
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 取得目前畫面尺寸，用於判斷橫豎屏版型。
    final Size size = MediaQuery.sizeOf(context);
    final bool isPortrait = size.height > size.width;

    // 讀取目前項目與主題資料，作為畫面配色依據。
    final item = _controller.currentItem;
    final theme = Theme.of(context);
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentItem = _controller.currentItem;

        // 核心顯示區塊，包含實際內容顯示與觸控切換層。
        Widget mainContent = Stack(
          children: [
            DisplayArea(item: currentItem),
            TouchLayer(
              isPortrait: isPortrait,
              themeColor: themeColor,
              onPrevious: _controller.useSideTap
                  ? _controller.previousItem
                  : null,
              onNext: _controller.useSideTap ? _controller.nextItem : null,
            ),
          ],
        );

        Widget body;
        Widget? bottomNavigationBarWidget;

        // 提取複用的水平（底部/頂部）導航和垂直（左側/右側）導航生成函式
        Widget buildHorizontalNav() => ScrollableNavBar(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        Widget buildVerticalNav() => ScrollableSideRail(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        // 根据横竖屏以及用户选择的设置来构建不同的布局排版
        if (isPortrait) {
          switch (_controller.portraitNavPosition) {
            case PortraitNavPosition.auto:
              body = Row(
                children: _controller.currentSide == NavSide.left
                    ? [buildVerticalNav(), Expanded(child: mainContent)]
                    : [Expanded(child: mainContent), buildVerticalNav()],
              );
              break;
            case PortraitNavPosition.left:
              body = Row(
                children: [
                  buildVerticalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case PortraitNavPosition.right:
              body = Row(
                children: [
                  Expanded(child: mainContent),
                  buildVerticalNav(),
                ],
              );
              break;
            case PortraitNavPosition.bottom:
              body = mainContent;
              bottomNavigationBarWidget = buildHorizontalNav();
              break;
            case PortraitNavPosition.top:
              body = Column(
                children: [
                  buildHorizontalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
          }
        } else {
          switch (_controller.landscapeNavPosition) {
            case LandscapeNavPosition.bottom:
              body = mainContent;
              bottomNavigationBarWidget = buildHorizontalNav();
              break;
            case LandscapeNavPosition.top:
              body = Column(
                children: [
                  buildHorizontalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case LandscapeNavPosition.left:
              body = Row(
                children: [
                  buildVerticalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case LandscapeNavPosition.right:
              body = Row(
                children: [
                  Expanded(child: mainContent),
                  buildVerticalNav(),
                ],
              );
              break;
          }
        }

        return Scaffold(
          backgroundColor: bgColor,
          bottomNavigationBar: bottomNavigationBarWidget,
          body: body,
        );
      },
    );
  }

  /// 顯示目前項目的管理選單。
  ///
  /// 使用底部彈出選單集中管理目前項目的各種操作，
  /// 例如編輯圖示、標題、文字、背景圖片、顏色、排序與設定頁跳轉。
  void _showManagementMenu() {
    debugPrint('[_HomeViewState] 顯示管理選單');

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onEditIcon: () async {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 準備編輯邊欄圖示');

          final IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: const SinglePickerConfiguration(
              iconPackModes: [IconPack.material],
              searchHintText: '搜索图标...',
              title: Text('选择边栏图标'),
            ),
          );

          if (selectedIcon != null) {
            debugPrint('[_HomeViewState] 已選擇新的邊欄圖示');
            _controller.updateIcon(selectedIcon.data);
          } else {
            debugPrint('[_HomeViewState] 使用者取消選擇邊欄圖示');
          }
        },
        onEditTitle: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 開啟邊欄標題編輯對話框');

          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: '边栏标题',
              initialValue: _controller.currentItem.title,
              onConfirm: _controller.updateTitle,
            ),
          );
        },
        onSetText: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 開啟全螢幕文字編輯對話框');

          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: '全屏文字',
              initialValue: _controller.currentItem.content,
              isMultiline: true,
              onConfirm: _controller.setAsText,
            ),
          );
        },
        onSetImage: () async {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 準備選取背景圖片');

          final Size size = MediaQuery.sizeOf(context);
          await _controller.pickImage(
            size.width > size.height ? size.width : size.height,
          );
        },
        onSetTextColor: () async {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 開啟文字顏色選擇器');

          await ColorPickerHandler.show(
            context: context,
            title: '文字颜色',
            isTextType: true,
            initialColor: _controller.currentItem.textColor,
            otherColor: _controller.currentItem.backgroundColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) => _controller.setTextColor(color),
          );
        },
        onSetBgColor: () async {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 開啟背景顏色選擇器');

          await ColorPickerHandler.show(
            context: context,
            title: '背景颜色',
            isTextType: false,
            initialColor: _controller.currentItem.backgroundColor,
            otherColor: _controller.currentItem.textColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) => _controller.setBgColor(color),
          );
        },
        onMoveUp: () {
          debugPrint('[_HomeViewState] 執行項目上移');
          _controller.moveUp();
        },
        onMoveDown: () {
          debugPrint('[_HomeViewState] 執行項目下移');
          _controller.moveDown();
        },
        onAdd: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 新增項目');
          _controller.addItem();
        },
        onCopy: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 複製目前項目');
          _controller.copyCurrentItem();
        },
        onDelete: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 刪除目前項目');
          _controller.deleteCurrentItem();
        },
        onOpenSettings: () {
          Navigator.pop(context);
          debugPrint('[_HomeViewState] 開啟設定頁');

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
}
