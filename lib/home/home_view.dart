import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'home_model.dart';

/// HomeView 為首頁畫面的主要入口元件。
///
/// 採用 [StatefulWidget]，因為畫面需要根據控制器狀態變化而即時重繪，
/// 例如目前選取項目、導覽位置、顯示內容與背景等。
class HomeView extends StatefulWidget {
  /// 建立 HomeView。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// HomeView 的狀態類別。
///
/// 負責：
/// 1. 監聽 [HomeController] 狀態變更。
/// 2. 處理導覽列點擊事件。
/// 3. 顯示管理選單與刪除確認視窗。
/// 4. 依照螢幕方向切換版面配置。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，負責管理目前項目、導覽索引與項目增刪切換等邏輯。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器狀態變化。
    // 當控制器通知更新時，若目前 Widget 仍掛載在樹上，則觸發 setState 重新繪製畫面。
    _controller.addListener(() => {if (mounted) setState(() {})});
  }

  /// 處理導覽列項目點擊事件。
  ///
  /// 當點擊的是目前已選取的項目時，開啟管理選單；
  /// 若點擊的是其他項目，則切換目前索引。
  void _onNavTap(int index) {
    // 若使用者再次點擊目前項目，視為想進入管理操作。
    if (index == _controller.currentIndex) {
      _showManagementMenu(context);
    } else {
      // 否則切換到指定項目。
      _controller.changeIndex(index);
    }
  }

  /// 顯示目前項目的管理選單。
  ///
  /// 透過 Bottom Sheet 提供：
  /// - 編輯項
  /// - 新增項
  /// - 刪除項
  void _showManagementMenu(BuildContext context) {
    // 取得目前選取項目的資料，供樣式設定使用。
    final item = _controller.currentItem;

    showModalBottomSheet(
      context: context,
      // 讓底部選單背景色跟目前項目風格一致。
      backgroundColor: item.backgroundColor,
      builder: (context) {
        return SafeArea(
          // 使用 SafeArea 避免內容被系統安全區域遮住。
          child: Wrap(
            children: [
              ListTile(
                // 編輯項目的圖示。
                leading: Icon(Icons.edit, color: item.textColor),
                // 編輯項目的文字。
                title: Text('编辑项', style: TextStyle(color: item.textColor)),
                onTap: () {
                  // 關閉底部選單。
                  Navigator.pop(context);
                },
              ),
              ListTile(
                // 新增項目的圖示。
                leading: Icon(Icons.add, color: item.textColor),
                // 新增項目的文字。
                title: Text('新增项', style: TextStyle(color: item.textColor)),
                onTap: () {
                  // 先關閉底部選單，再新增項目。
                  Navigator.pop(context);
                  _controller.addItem();
                },
              ),
              ListTile(
                // 刪除項目的圖示，使用紅色強調警示感。
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  '删除项',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  // 先關閉底部選單，再顯示刪除確認對話框。
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 顯示刪除確認視窗。
  ///
  /// 若目前僅剩一個項目，則不允許刪除，並顯示提示訊息。
  /// 否則顯示確認對話框，讓使用者決定是否刪除目前項目。
  void _confirmDelete(BuildContext context) {
    // 至少保留一個項目，避免清空後沒有可顯示內容。
    if (_controller.items.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('至少保留一项，无法删除')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除当前这一项吗？'),
        actions: [
          TextButton(
            // 取消刪除，直接關閉對話框。
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 先關閉對話框，再刪除目前項目。
              Navigator.pop(context);
              _controller.deleteCurrentItem();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 取得目前項目，作為整體畫面配色與內容來源。
    final item = _controller.currentItem;

    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向模式。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 整個頁面背景色跟隨目前項目設定。
          backgroundColor: item.backgroundColor,

          // 橫向時顯示底部導覽列；直向時不顯示。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(item),

          body: Stack(
            children: [
              // 觸控層放在底下，負責處理前後切換點擊區域。
              _buildTouchLayer(isPortrait, item),

              // 直向與橫向採用不同版面配置。
              isPortrait ? _buildPortraitLayout(item) : _buildDisplayArea(item),
            ],
          ),
        );
      },
    );
  }

  /// 建立橫向模式下使用的底部導覽列。
  ///
  /// 導覽列會根據目前項目的顏色設定動態套用樣式。
  Widget _buildBottomNav(HomeItem item) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // 導覽列背景色。
        backgroundColor: item.backgroundColor,

        // 選取指示器顏色，使用文字色並加上透明度。
        indicatorColor: item.textColor.withValues(alpha: 0.2),

        // 導覽標籤文字樣式。
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: item.textColor),
        ),

        // 導覽圖示樣式。
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: item.textColor)),
      ),
      child: NavigationBar(
        // 目前選取的索引。
        selectedIndex: _controller.currentIndex,

        // 使用者點選導覽項目時的回呼。
        onDestinationSelected: _onNavTap,

        // 根據控制器中的項目列表動態建立導覽目的地。
        destinations: _controller.items
            .map(
              (e) => NavigationDestination(icon: Icon(e.icon), label: e.title),
            )
            .toList(),
      ),
    );
  }

  /// 建立直向模式下使用的側邊導覽列。
  ///
  /// 導覽列可依目前設定顯示在左側或右側。
  Widget _buildSideNav(HomeItem item) {
    return NavigationRail(
      // 側邊導覽背景色。
      backgroundColor: item.backgroundColor,

      // 目前選取的索引。
      selectedIndex: _controller.currentIndex,

      // 點選導覽目的地後的處理。
      onDestinationSelected: _onNavTap,

      // 永遠顯示標籤文字。
      labelType: NavigationRailLabelType.all,

      // 已選取項目的圖示樣式。
      selectedIconTheme: IconThemeData(color: item.textColor),

      // 已選取項目的文字樣式。
      selectedLabelTextStyle: TextStyle(color: item.textColor),

      // 未選取項目的圖示樣式，透明度較低。
      unselectedIconTheme: IconThemeData(
        color: item.textColor.withValues(alpha: 0.5),
      ),

      // 未選取項目的文字樣式，透明度較低。
      unselectedLabelTextStyle: TextStyle(
        color: item.textColor.withValues(alpha: 0.5),
      ),

      // 根據項目資料建立側邊導覽目的地。
      destinations: _controller.items
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              label: Text(e.title),
            ),
          )
          .toList(),
    );
  }

  /// 建立直向模式的整體版面。
  ///
  /// 一側為導覽列，另一側為主要顯示區；
  /// 導覽列位置依 [_controller.currentSide] 決定顯示在左邊或右邊。
  Widget _buildPortraitLayout(HomeItem item) {
    // 主要內容區域使用 Expanded 撐滿剩餘空間。
    final Widget textWidget = Expanded(child: _buildDisplayArea(item));

    // 側邊導覽元件。
    final Widget navWidget = _buildSideNav(item);

    return Row(
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget]
          : [textWidget, navWidget],
    );
  }

  /// 建立主要顯示區域。
  ///
  /// 顯示規則：
  /// 1. 若有背景圖片路徑，則顯示圖片。
  /// 2. 若背景圖片路徑為空字串且內容也為空，則顯示預設圖片。
  /// 3. 否則顯示文字內容，並依可用空間自動縮放字體大小。
  Widget _buildDisplayArea(HomeItem item) {
    return IgnorePointer(
      // 讓顯示區本身不攔截點擊事件，交由底下的觸控層處理。
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 目前項目的背景圖片路徑。
          final String? path = item.backgroundImagePath;

          // 目前項目的文字內容。
          final String content = item.content;

          // 判斷是否應顯示圖片：
          // - path 不為 null 且不為空字串，表示有指定圖片
          // - path 為空字串且內容也為空，表示要顯示預設圖片
          bool shouldShowImage =
              (path != null && path.isNotEmpty) ||
              (path == '' && content.isEmpty);

          if (shouldShowImage) {
            // 若未指定有效圖片路徑，則改用預設圖片。
            final String finalPath = (path == null || path.isEmpty)
                ? 'assets/default.png'
                : path;

            return Container(
              // 填滿可用寬度。
              width: constraints.maxWidth,

              // 填滿可用高度。
              height: constraints.maxHeight,

              // 圖片置中。
              alignment: Alignment.center,

              // 顯示資產圖片，並以 contain 保持完整比例。
              child: Image.asset(finalPath, fit: BoxFit.contain),
            );
          }

          // 設定文字的基礎樣式。
          final TextStyle baseStyle = TextStyle(
            // 行高略微壓縮，讓大字顯示更緊湊。
            height: 1.1,
            color: item.textColor,
          );

          // 先以固定字級進行測量，取得文字原始寬高。
          final tp = TextPainter(
            text: TextSpan(
              text: content,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 依可用寬高比例計算縮放值，取較小者以確保完整顯示。
          double scale =
              (constraints.maxWidth / tp.width) <
                  (constraints.maxHeight / tp.height)
              ? (constraints.maxWidth / tp.width)
              : (constraints.maxHeight / tp.height);

          return Center(
            child: Text(
              // 顯示內容文字。
              content,

              // 文字置中對齊。
              textAlign: TextAlign.center,

              // 套用縮放後字級，並乘上 0.85 保留些許邊界避免過滿。
              style: baseStyle.copyWith(fontSize: (100 * scale) * 0.85),
            ),
          );
        },
      ),
    );
  }

  /// 建立全畫面的觸控層。
  ///
  /// 作用：
  /// - 直向模式：上半部點擊切到上一項，下半部切到下一項
  /// - 橫向模式：左半部點擊切到上一項，右半部切到下一項
  ///
  /// 此層使用透明材質與 InkWell，讓點擊時仍有水波紋效果。
  Widget _buildTouchLayer(bool isPortrait, HomeItem item) {
    // 點擊水波紋顏色。
    final Color splash = item.textColor.withValues(alpha: 0.1);

    // 點擊高亮顏色。
    final Color highlight = item.textColor.withValues(alpha: 0.05);

    return Material(
      // 背景透明，僅保留 Material 與 InkWell 所需材質能力。
      color: Colors.transparent,
      child: isPortrait
          ? Column(
              children: [
                Expanded(
                  child: InkWell(
                    // 點擊上半部切換到前一項。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 點擊下半部切換到下一項。
                    onTap: _controller.nextItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: InkWell(
                    // 點擊左半部切換到前一項。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 點擊右半部切換到下一項。
                    onTap: _controller.nextItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
    );
  }
}
