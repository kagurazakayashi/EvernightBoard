import 'package:flutter/material.dart';
import 'home_controller.dart';

/// 首頁畫面元件。
///
/// 負責建立首頁的 StatefulWidget，並交由 [_HomeViewState]
/// 管理畫面狀態、版面切換與互動邏輯。
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 的狀態物件。
///
/// 主要職責包含：
/// - 初始化並綁定 [HomeController]
/// - 監聽控制器狀態變更並刷新畫面
/// - 依照螢幕方向切換直向／橫向版面
/// - 建立觸控區、文字縮放區與導覽列
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，用來管理目前索引、內容、導覽位置與切換行為。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 註冊監聽器，當控制器狀態改變時同步更新畫面。
    _controller.addListener(_handleStateChange);
  }

  /// 處理控制器狀態變更。
  ///
  /// 當 [HomeController] 內容有更新時，如果目前 State 仍掛載於樹上，
  /// 就呼叫 [setState] 重新建構畫面。
  void _handleStateChange() {
    // 避免在元件已被移除後仍呼叫 setState，造成例外。
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 移除監聽器，避免記憶體洩漏或無效回呼。
    _controller.removeListener(_handleStateChange);

    // 釋放控制器資源。
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 OrientationBuilder 依照裝置方向動態切換版面配置。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向模式。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 橫向時顯示底部導覽列；直向時不顯示。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(),

          // 使用 Stack 疊放觸控層與內容層，
          // 讓整個畫面可以分區點擊切換上一筆／下一筆。
          body: Stack(
            children: [
              _buildTouchLayer(isPortrait),
              isPortrait ? _buildPortraitLayout() : _buildScalingText(),
            ],
          ),
        );
      },
    );
  }

  /// 建立全畫面的觸控層。
  ///
  /// - 直向模式：上下各半區，分別對應上一筆／下一筆
  /// - 橫向模式：左右各半區，分別對應上一筆／下一筆
  ///
  /// 透過透明 [Material] + [InkWell] 提供點擊水波紋效果。
  Widget _buildTouchLayer(bool isPortrait) {
    // 點擊時的水波紋顏色。
    final Color splash = Colors.blueAccent.withValues(alpha: 0.1);

    // 長按或高亮時的背景顏色。
    final Color highlight = Colors.blueAccent.withValues(alpha: 0.05);

    return Material(
      // 保持背景透明，只保留觸控效果。
      color: Colors.transparent,
      child: isPortrait
          ? Column(
              children: [
                Expanded(
                  child: InkWell(
                    // 點擊上半部時切換到上一筆。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,

                    // 讓可點擊區域撐滿整個 Expanded。
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 點擊下半部時切換到下一筆。
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
                    // 橫向時點擊左半部切換到上一筆。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 橫向時點擊右半部切換到下一筆。
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

  /// 建立直向模式下的版面。
  ///
  /// 此版面由兩部分組成：
  /// - 可自動縮放的文字顯示區
  /// - 側邊導覽列 [NavigationRail]
  ///
  /// 導覽列位置會依 [_controller.currentSide] 決定顯示在左側或右側。
  Widget _buildPortraitLayout() {
    // 文字區域使用 Expanded 撐滿剩餘空間。
    final Widget textWidget = Expanded(child: _buildScalingText());

    // 側邊導覽列，提供項目切換功能。
    final Widget navWidget = NavigationRail(
      // 目前選取的項目索引。
      selectedIndex: _controller.currentIndex,

      // 點選導覽項目後切換索引。
      onDestinationSelected: _controller.changeIndex,

      // 顯示所有標籤文字。
      labelType: NavigationRailLabelType.all,

      // 依控制器提供的項目清單動態建立導覽目的地。
      destinations: _controller.items
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              label: Text(e.title),
            ),
          )
          .toList(),
    );

    // 根據導覽列配置方向，決定導覽列要放左邊還是右邊。
    return Row(
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget]
          : [textWidget, navWidget],
    );
  }

  /// 建立可依可用空間自動縮放的文字區域。
  ///
  /// 會先使用 [TextPainter] 測量文字在基準字級下的寬高，
  /// 再根據目前版面可用尺寸計算縮放比例，
  /// 讓文字盡可能放大且完整顯示在畫面內。
  Widget _buildScalingText() {
    return IgnorePointer(
      // 讓此層只負責顯示，不攔截觸控事件，
      // 使下方的觸控層仍可正常接收點擊。
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 取得目前要顯示的文字內容。
          final String text = _controller.currentContent;

          // 使用 TextPainter 預先量測文字在固定字級下的實際尺寸。
          final tp = TextPainter(
            text: TextSpan(
              text: text,
              style: const TextStyle(fontSize: 100, height: 1.1),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 依照寬與高的可用比例，取較小值作為縮放倍率，
          // 以確保文字不會超出容器範圍。
          double scale =
              (constraints.maxWidth / tp.width) <
                  (constraints.maxHeight / tp.height)
              ? (constraints.maxWidth / tp.width)
              : (constraints.maxHeight / tp.height);

          return Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                // 以基準字級 100 計算，並乘上 0.8 保留額外邊界，
                // 避免因字型實際渲染誤差造成裁切。
                fontSize: (100 * scale) * 0.8,
                height: 1.1,
                color: Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 建立橫向模式下的底部導覽列。
  ///
  /// 使用 [NavigationBar] 顯示所有項目，
  /// 並透過控制器同步目前選取狀態與切換動作。
  Widget _buildBottomNav() {
    return NavigationBar(
      // 目前選取的導覽索引。
      selectedIndex: _controller.currentIndex,

      // 點擊導覽項目後切換對應內容。
      onDestinationSelected: _controller.changeIndex,

      // 依項目清單動態建立底部導覽按鈕。
      destinations: _controller.items
          .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.title))
          .toList(),
    );
  }
}
