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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 應用程式首頁主畫面。
///
/// 此元件負責：
///
/// 1. 與 [HomeController] 綁定並監聽狀態變更。
/// 2. 依照螢幕方向（直向／橫向）與導覽列設定動態切換版面配置。
/// 3. 組合主要顯示區、觸控層與導覽元件。
/// 4. 提供項目管理入口，例如編輯圖示、標題、文字、顏色、圖片與排序等功能。
class HomeView extends StatefulWidget {
  /// 首頁所依賴的控制器，負責提供目前項目資料與操作行為。
  final HomeController controller;

  const HomeView({super.key, required this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態物件。
///
/// 主要負責監聽控制器、重建畫面，以及處理各類互動事件與底部管理選單。
class _HomeViewState extends State<HomeView> {
  /// 便捷存取目前綁定的 [HomeController]。
  HomeController get _controller => widget.controller;

  /// 控制網頁版頂欄是否顯示
  bool _isWebAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    debugPrint('[HomeView] 初始化完成，開始註冊控制器監聽器');
    // 註冊監聽器，當控制器狀態變更時同步觸發畫面更新。
    _controller.addListener(_updateUI);
  }

  /// 接收控制器狀態變更後，安全地觸發畫面重建。
  ///
  /// 僅在元件仍掛載於 Widget Tree 時才執行 [setState]，
  /// 以避免在元件銷毀後更新 UI 而產生例外。
  void _updateUI() {
    if (mounted) {
      debugPrint('[HomeView] 偵測到控制器狀態變更，準備重建畫面');
      setState(() {
        // 透過空的 setState 觸發 build，讓最新狀態反映到畫面上。
      });
    } else {
      debugPrint('[HomeView] 控制器狀態變更已收到，但元件未掛載，略過重建');
    }
  }

  @override
  void dispose() {
    debugPrint('[HomeView] 即將銷毀元件，移除控制器監聽器並釋放資源');
    // 移除監聽器，避免元件釋放後仍持有回呼造成記憶體洩漏。
    _controller.removeListener(_updateUI);
    super.dispose();
  }

  /// 顯示統一樣式的提示訊息。
  ///
  /// 會先清除目前佇列中的 SnackBar，再顯示新的提示，
  /// 以確保使用者能立即看到最新操作結果。
  ///
  /// [message] 要顯示給使用者的訊息內容。
  /// [isError] 是否為錯誤／警示狀態；若為 `true`，將使用提示性圖示樣式。
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      debugPrint('[HomeView] 嘗試顯示提示訊息失敗，原因：元件未掛載');
      return;
    }

    debugPrint('[HomeView] 顯示提示訊息，內容: "$message"，錯誤狀態: $isError');

    // 立即清除目前已顯示或排隊中的提示訊息，避免回饋延遲或堆疊。
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
        backgroundColor: Colors.grey[900]?.withValues(alpha: 0.9),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// 處理導覽項目點擊事件。
  ///
  /// 當使用者點擊目前已選取的項目時，開啟管理功能選單；
  /// 否則切換至指定索引對應的項目。
  ///
  /// [index] 使用者點擊的導覽項目索引。
  void _onNavTap(int index) {
    debugPrint(
      '[HomeView] 使用者點擊導覽項目，索引: $index，目前索引: ${_controller.currentIndex}',
    );
    if (index == _controller.currentIndex) {
      debugPrint('[HomeView] 點擊的是目前項目，改為開啟管理選單');
      _showManagementMenu();
    } else {
      debugPrint('[HomeView] 切換目前項目至索引: $index');
      _controller.changeIndex(index);
    }
  }

  /// 開啟外部網址
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('[HomeView] 無法開啟網址: $urlString');
      if (mounted) _showSnackBar('無法開啟連結', isError: true);
    }
  }

  /// 建立僅限網頁版顯示的頂部導覽列
  PreferredSizeWidget? _buildWebAppBar() {
    // 判斷條件：必須是網頁版 且 使用者沒有關閉它
    if (!kIsWeb || !_isWebAppBarVisible) return null;
    final double screenWidth = MediaQuery.of(context).size.width;
    // 定義一個寬度閾值，低於此數值則隱藏標題文字（例如 600）
    final bool showTitle = screenWidth >= 600;

    return AppBar(
      // 根據寬度決定顯示標題還是 null
      title: showTitle ? Text(t.appTitle) : null,
      elevation: 1, // 給一點陰影增加立體感
      backgroundColor: Colors.grey[900], // 配合你現有的深色底色，可依需求調整
      actions: [
        // 渠道配置 GitHub 按鈕
        InkWell(
          onTap: () =>
              _launchURL('https://github.com/kagurazakayashi/EvernightBoard'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SvgPicture.asset('assets/web/github.svg', height: 40),
          ),
        ),
        // 渠道配置 Google Play 按鈕
        InkWell(
          onTap: () => _launchURL(
            'https://play.google.com/store/apps/details?id=moe.yashi.evernightboard',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SvgPicture.asset('assets/web/googleplay.svg', height: 40),
          ),
        ),
        // 渠道配置 App Store 按鈕
        InkWell(
          onTap: () => _launchURL(
            'https://apps.apple.com/app/evernightboard/id6761154116',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SvgPicture.asset('assets/web/appstore.svg', height: 40),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          tooltip: 'Hide',
          onPressed: () {
            setState(() {
              _isWebAppBarVisible = false;
            });
          },
        ),
        const SizedBox(width: 16), // 右側留白
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isPortrait = size.height > size.width;
    final item = _controller.currentItem;
    final theme = Theme.of(context);

    // 依目前項目設定決定背景色與主題色；若未指定則回退到主題預設值。
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentItem = _controller.currentItem;

        // 主要內容區：底層為實際顯示內容，上層為手勢互動區。
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

        /// 建立水平導覽列。
        ///
        /// 通常用於畫面上方或下方的導覽配置。
        Widget buildHorizontalNav() => ScrollableNavBar(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        /// 建立垂直側邊導覽列。
        ///
        /// 通常用於畫面左側或右側的導覽配置。
        Widget buildVerticalNav() => ScrollableSideRail(
          items: _controller.items,
          currentIndex: _controller.currentIndex,
          onTap: _onNavTap,
        );

        // 根據目前裝置方向與導覽列設定，動態組裝版面配置。
        if (isPortrait) {
          debugPrint('[HomeView] 目前為直向模式，套用直向版面配置');
          switch (_controller.portraitNavPosition) {
            case PortraitNavPosition.auto:
              debugPrint('[HomeView] 直向導覽位置設定為 auto，依目前側邊方向決定佈局');
              body = Row(
                children: _controller.currentSide == NavSide.left
                    ? [buildVerticalNav(), Expanded(child: mainContent)]
                    : [Expanded(child: mainContent), buildVerticalNav()],
              );
              break;
            case PortraitNavPosition.left:
              debugPrint('[HomeView] 直向導覽位置設定為 left');
              body = Row(
                children: [
                  buildVerticalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case PortraitNavPosition.right:
              debugPrint('[HomeView] 直向導覽位置設定為 right');
              body = Row(
                children: [
                  Expanded(child: mainContent),
                  buildVerticalNav(),
                ],
              );
              break;
            case PortraitNavPosition.bottom:
              debugPrint('[HomeView] 直向導覽位置設定為 bottom');
              body = mainContent;
              bottomNavigationBarWidget = buildHorizontalNav();
              break;
            case PortraitNavPosition.top:
              debugPrint('[HomeView] 直向導覽位置設定為 top');
              body = Column(
                children: [
                  buildHorizontalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
          }
        } else {
          debugPrint('[HomeView] 目前為橫向模式，套用橫向版面配置');
          switch (_controller.landscapeNavPosition) {
            case LandscapeNavPosition.bottom:
              debugPrint('[HomeView] 橫向導覽位置設定為 bottom');
              body = mainContent;
              bottomNavigationBarWidget = buildHorizontalNav();
              break;
            case LandscapeNavPosition.top:
              debugPrint('[HomeView] 橫向導覽位置設定為 top');
              body = Column(
                children: [
                  buildHorizontalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case LandscapeNavPosition.left:
              debugPrint('[HomeView] 橫向導覽位置設定為 left');
              body = Row(
                children: [
                  buildVerticalNav(),
                  Expanded(child: mainContent),
                ],
              );
              break;
            case LandscapeNavPosition.right:
              debugPrint('[HomeView] 橫向導覽位置設定為 right');
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
          appBar: _buildWebAppBar(),
          bottomNavigationBar: bottomNavigationBarWidget,
          body: body,
        );
      },
    );
  }

  /// 顯示項目管理底部選單。
  ///
  /// 使用者可從此選單執行目前項目的常見管理操作，
  /// 包括編輯圖示、標題、內容、顏色、背景圖片，以及新增、複製、刪除與進入設定頁等。
  void _showManagementMenu() {
    debugPrint('[HomeView] 開啟項目管理底部選單');
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onEditIcon: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇編輯圖示，準備開啟圖示選取器');
          final IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: SinglePickerConfiguration(
              iconPackModes: [IconPack.material],
              searchHintText: t.searchicon,
              title: Text(t.selectsidebarico),
            ),
          );

          if (selectedIcon != null) {
            debugPrint('[HomeView] 圖示選取完成，準備更新目前項目圖示');
            _controller.updateIcon(selectedIcon.data);
            if (mounted) _showSnackBar(t.sidebaricoupdated);
          } else {
            debugPrint('[HomeView] 圖示選取器已關閉，未選取任何圖示');
            if (mounted) _showSnackBar(t.icounchanged, isError: true);
          }
        },
        onEditTitle: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇編輯標題，準備開啟文字輸入對話框');
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: t.sidebartitle,
              initialValue: _controller.currentItem.title,
              onConfirm: (val) {
                debugPrint('[HomeView] 標題編輯已確認，準備更新目前項目標題');
                _controller.updateTitle(val);
                _showSnackBar('${t.sidebartitlechanged}: $val');
              },
            ),
          );
        },
        onSetText: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇編輯內容文字，準備開啟多行輸入對話框');
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: t.setastext,
              initialValue: _controller.currentItem.content,
              isMultiline: true,
              onConfirm: (val) {
                debugPrint('[HomeView] 內容文字編輯已確認，準備更新目前項目內容');
                _controller.setAsText(val);
                _showSnackBar(t.textupdated);
              },
            ),
          );
        },
        onSetImage: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇設定背景圖片，開始啟動圖片選取流程');
          final Size size = MediaQuery.sizeOf(context);
          await _controller.pickImage(
            size.width > size.height ? size.width : size.height,
          );

          if (mounted) {
            if (_controller.currentItem.backgroundImagePath?.isNotEmpty ==
                true) {
              debugPrint('[HomeView] 背景圖片設定成功');
              _showSnackBar(t.imageupdated);
            } else {
              debugPrint('[HomeView] 背景圖片設定失敗或使用者未完成選取');
              _showSnackBar(t.imagefailed, isError: true);
            }
          }
        },
        onSetTextColor: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇設定文字顏色，準備開啟顏色選取器');
          await ColorPickerHandler.show(
            context: context,
            title: t.textcolor,
            isTextType: true,
            initialColor: _controller.currentItem.textColor,
            otherColor: _controller.currentItem.backgroundColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) {
              debugPrint('[HomeView] 文字顏色已變更，準備套用新設定');
              _controller.setTextColor(color);
              _showSnackBar(
                color == null ? t.textcolordefault : t.textcolorupdated,
              );
            },
          );
        },
        onSetBgColor: () async {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇設定背景顏色，準備開啟顏色選取器');
          await ColorPickerHandler.show(
            context: context,
            title: t.backgroundcolor,
            isTextType: false,
            initialColor: _controller.currentItem.backgroundColor,
            otherColor: _controller.currentItem.textColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) {
              debugPrint('[HomeView] 背景顏色已變更，準備套用新設定');
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
          debugPrint('[HomeView] 使用者選擇將目前項目上移');
          _controller.moveUp();
        },
        onMoveDown: () {
          debugPrint('[HomeView] 使用者選擇將目前項目下移');
          _controller.moveDown();
        },
        onAdd: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇新增項目');
          _controller.addItem();
          _showSnackBar(t.screenadded);
        },
        onCopy: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇複製目前項目');
          _controller.copyCurrentItem();
          _showSnackBar(t.screencopied);
        },
        onDelete: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇刪除目前項目');
          _controller.deleteCurrentItem();
          _showSnackBar(t.screendeleted);
        },
        onOpenSettings: () {
          Navigator.pop(context);
          debugPrint('[HomeView] 使用者選擇開啟設定頁面');
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
