import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:evernight_board/global.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';
import 'widgets/edit_text_dialog.dart';
import 'widgets/color_picker_handler.dart';
import '../settings/settings_view.dart';

/// 應用程式首頁的主視圖元件。
///
/// 負責統合 [HomeController] 的狀態，並根據螢幕導向（橫向/縱向）與
/// 使用者設定來動態佈局導覽列與內容顯示區。
class HomeView extends StatefulWidget {
  final HomeController controller;
  const HomeView({super.key, required this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    debugPrint('[HomeView] 初始化狀態 (initState)');
    // 註冊監聽器以響應控制器狀態變更
    _controller.addListener(_updateUI);
  }

  /// 觸發 UI 重繪的內部回呼函式。
  void _updateUI() {
    if (mounted) {
      setState(() {
        // 狀態更新，觸發 Build 流程
      });
    }
  }

  @override
  void dispose() {
    debugPrint('[HomeView] 正在銷毀元件並釋放資源 (dispose)');
    // 移除監聽器防止記憶體洩漏
    _controller.removeListener(_updateUI);
    super.dispose();
  }

  /// 顯示全域統一風格的提示訊息 (SnackBar)。
  ///
  /// [message] 欲呈現給使用者的文字內容。
  /// [isError] 是否為錯誤或警告狀態，將影響圖示顏色。
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    debugPrint('[HomeView] 顯示提示訊息: "$message" (錯誤: $isError)');

    // 立即清除當前佇列中的提示，確保操作回饋的即時性
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
        backgroundColor: Colors.grey[900]?.withOpacity(0.9),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// 處理導覽列項目的點擊事件。
  ///
  /// 若點擊的是當前選中項，則開啟管理功能選單；否則進行頁面切換。
  void _onNavTap(int index) {
    debugPrint('[HomeView] 導覽列點擊事件，目標索引: $index');
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isPortrait = size.height > size.width;
    final item = _controller.currentItem;
    final theme = Theme.of(context);

    // 確定當前背景色與主題色
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentItem = _controller.currentItem;

        // 核心內容顯示區，包含顯示層與觸控互動層
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

        // 定義水平導覽列構建邏輯
        Widget buildHorizontalNav() => ScrollableNavBar(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        // 定義垂直側邊欄構建邏輯
        Widget buildVerticalNav() => ScrollableSideRail(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        // 根據螢幕方向與控制器組態進行佈局適配
        if (isPortrait) {
          debugPrint('[HomeView] 當前為縱向模式 (Portrait)，套用對應佈局');
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
          debugPrint('[HomeView] 當前為橫向模式 (Landscape)，套用對應佈局');
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

  /// 開啟底部管理功能選單。
  void _showManagementMenu() {
    debugPrint('[HomeView] 顯示項目管理選單');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onEditIcon: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 觸發圖示選取器');
          final IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: SinglePickerConfiguration(
              iconPackModes: [IconPack.material],
              searchHintText: t.searchicon,
              title: Text(t.selectsidebarico),
            ),
          );

          if (selectedIcon != null) {
            _controller.updateIcon(selectedIcon.data);
            if (mounted) _showSnackBar(t.sidebaricoupdated);
          } else {
            debugPrint('[HomeView] 圖示選取已取消');
            if (mounted) _showSnackBar(t.icounchanged, isError: true);
          }
        },
        onEditTitle: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 觸發標題編輯對話框');
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: t.sidebartitle,
              initialValue: _controller.currentItem.title,
              onConfirm: (val) {
                _controller.updateTitle(val);
                _showSnackBar('${t.sidebartitlechanged}: $val');
              },
            ),
          );
        },
        onSetText: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 觸發內容文字編輯');
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: t.setastext,
              initialValue: _controller.currentItem.content,
              isMultiline: true,
              onConfirm: (val) {
                _controller.setAsText(val);
                _showSnackBar(t.textupdated);
              },
            ),
          );
        },
        onSetImage: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 啟動背景圖片選取程序');
          final Size size = MediaQuery.sizeOf(context);
          await _controller.pickImage(
            size.width > size.height ? size.width : size.height,
          );

          if (mounted) {
            if (_controller.currentItem.backgroundImagePath?.isNotEmpty ==
                true) {
              _showSnackBar(t.imageupdated);
            } else {
              _showSnackBar(t.imagefailed, isError: true);
            }
          }
        },
        onSetTextColor: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 觸發文字顏色選取器');
          await ColorPickerHandler.show(
            context: context,
            title: t.textcolor,
            isTextType: true,
            initialColor: _controller.currentItem.textColor,
            otherColor: _controller.currentItem.backgroundColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) {
              _controller.setTextColor(color);
              _showSnackBar(
                color == null ? t.textcolordefault : t.textcolorupdated,
              );
            },
          );
        },
        onSetBgColor: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 觸發背景顏色選取器');
          await ColorPickerHandler.show(
            context: context,
            title: t.backgroundcolor,
            isTextType: false,
            initialColor: _controller.currentItem.backgroundColor,
            otherColor: _controller.currentItem.textColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) {
              _controller.setBgColor(color);
              _showSnackBar(
                color == null
                    ? t.backgroundcolordefault
                    : t.backgroundcolorupdated,
              );
            },
          );
        },
        onMoveUp: () {
          debugPrint('[HomeView] 項目上移');
          _controller.moveUp();
        },
        onMoveDown: () {
          debugPrint('[HomeView] 項目下移');
          _controller.moveDown();
        },
        onAdd: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 新增項目');
          _controller.addItem();
          _showSnackBar(t.screenadded);
        },
        onCopy: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 複製當前項目');
          _controller.copyCurrentItem();
          _showSnackBar(t.screencopied);
        },
        onDelete: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 刪除當前項目');
          _controller.deleteCurrentItem();
          _showSnackBar(t.screendeleted);
        },
        onOpenSettings: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 導覽至設定頁面');
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
