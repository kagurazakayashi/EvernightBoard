import 'package:flutter/material.dart';
import 'home_controller.dart';

/// 首頁畫面元件。
///
/// 此元件負責：
/// - 建立並持有 [HomeController]
/// - 依據螢幕方向切換直向／橫向版面
/// - 疊加觸控翻頁層與內容顯示層
/// - 於不同方向下顯示對應的導覽元件
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 對應的狀態類別。
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，負責管理目前索引、內容、導覽側邊與切換行為。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    // 監聽控制器狀態變化，當資料更新時同步刷新畫面。
    _controller.addListener(_updateState);
  }

  /// 控制器狀態更新時呼叫。
  ///
  /// 若目前 State 仍掛載於 Widget Tree 中，則觸發重新建構畫面。
  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // 先移除監聽，避免控制器釋放後仍回呼到目前 State。
    _controller.removeListener(_updateState);
    // 釋放控制器資源。
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 依據裝置方向建立不同版面配置。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向模式。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 橫向時使用底部導覽列；直向時不顯示，改由側邊導覽取代。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(),
          body: Stack(
            children: [
              // 1. 底層：全畫面觸控翻頁區域。
              _buildTouchLayer(isPortrait),

              // 2. 上層：實際內容顯示區域。
              isPortrait ? _buildPortraitLayout() : _buildScalingText(),
            ],
          ),
        );
      },
    );
  }

  /// 建立翻頁觸控層。
  ///
  /// 在直向模式下以上下分區方式操作上一頁／下一頁；
  /// 在橫向模式下則以左右分區方式操作。
  Widget _buildTouchLayer(bool isPortrait) {
    // 使用新版 Color.withValues 設定透明度，避免舊 API 棄用警告。
    final Color splashColor = Colors.blueAccent.withValues(alpha: 0.1);
    final Color highlightColor = Colors.blueAccent.withValues(alpha: 0.05);

    return Material(
      // 觸控層本身不繪製背景，讓上層內容能正常顯示。
      color: Colors.transparent,
      child: isPortrait
          ? Column(
              children: [
                // 上半部點擊後切換到上一個項目。
                Expanded(
                  child: _createInkWell(
                    _controller.previousItem,
                    splashColor,
                    highlightColor,
                  ),
                ),
                // 下半部點擊後切換到下一個項目。
                Expanded(
                  child: _createInkWell(
                    _controller.nextItem,
                    splashColor,
                    highlightColor,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // 左半部點擊後切換到上一個項目。
                Expanded(
                  child: _createInkWell(
                    _controller.previousItem,
                    splashColor,
                    highlightColor,
                  ),
                ),
                // 右半部點擊後切換到下一個項目。
                Expanded(
                  child: _createInkWell(
                    _controller.nextItem,
                    splashColor,
                    highlightColor,
                  ),
                ),
              ],
            ),
    );
  }

  /// 建立可覆蓋整個區塊的點擊元件。
  ///
  /// [onTap] 為點擊後要執行的回呼。
  /// [splash] 與 [highlight] 分別控制點擊水波紋與高亮效果。
  Widget _createInkWell(VoidCallback onTap, Color splash, Color highlight) {
    return InkWell(
      // 點擊事件。
      onTap: onTap,
      // 點擊時的水波紋顏色。
      splashColor: splash,
      // 長按或按下時的高亮顏色。
      highlightColor: highlight,
      // 讓可點擊範圍撐滿父容器。
      child: const SizedBox.expand(),
    );
  }

  /// 建立直向版面。
  ///
  /// 直向時採用左右排列：
  /// - 一側顯示導覽列
  /// - 另一側顯示主要文字內容
  ///
  /// 導覽列顯示於左側或右側，由控制器中的 [currentSide] 決定。
  Widget _buildPortraitLayout() {
    // 可自動延展的文字顯示區。
    final Widget textWidget = Expanded(child: _buildScalingText());
    // 側邊導覽列。
    final Widget navWidget = _buildSideNav();

    return Row(
      // 根據目前設定決定導覽列位於左側或右側。
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget]
          : [textWidget, navWidget],
    );
  }

  /// 建立會依可用空間自動縮放字體大小的文字元件。
  ///
  /// 主要流程如下：
  /// - 先以固定大字體進行測量
  /// - 再根據容器寬高比例計算縮放值
  /// - 最後套用縮放後字體大小顯示內容
  Widget _buildScalingText() {
    return IgnorePointer(
      // 必須讓文字區域忽略點擊，手勢事件才能穿透到 Stack 底層的觸控翻頁層。
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 取得目前要顯示的文字內容。
          final String text = _controller.currentContent;

          // 基礎文字樣式，不包含最終字體大小。
          const TextStyle baseStyle = TextStyle(
            height: 1.1,
            color: Colors.black87,
          );

          // 使用 TextPainter 先以較大的字體進行一次測量，
          // 以便估算內容在目前版面中的最佳縮放比例。
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 根據寬度與高度限制，取較小的縮放比例，
          // 以確保文字能完整顯示在可用區域內。
          double scale =
              (constraints.maxWidth / textPainter.width) <
                  (constraints.maxHeight / textPainter.height)
              ? (constraints.maxWidth / textPainter.width)
              : (constraints.maxHeight / textPainter.height);

          return Container(
            // 給內容保留內距，避免文字貼齊邊界。
            padding: const EdgeInsets.all(24),
            // 文字置中顯示。
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              // 乘上 0.9 作為額外保留空間，避免極限情況下貼邊或溢出。
              style: baseStyle.copyWith(fontSize: (100 * scale) * 0.9),
            ),
          );
        },
      ),
    );
  }

  /// 建立直向模式下使用的側邊導覽列。
  Widget _buildSideNav() {
    return NavigationRail(
      // 目前選取的導覽索引。
      selectedIndex: _controller.currentIndex,
      // 使用者點選不同導覽項目時切換內容。
      onDestinationSelected: _controller.changeIndex,
      // 顯示所有導覽項目的標籤文字。
      labelType: NavigationRailLabelType.all,
      // 由控制器中的項目清單動態產生導覽目的地。
      destinations: _controller.items.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          label: Text(item.title),
        );
      }).toList(),
    );
  }

  /// 建立橫向模式下使用的底部導覽列。
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      // 目前選取的導覽索引。
      currentIndex: _controller.currentIndex,
      // 點擊底部項目時切換目前內容。
      onTap: _controller.changeIndex,
      // 由控制器中的項目清單動態建立底部導覽項目。
      items: _controller.items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.title,
        );
      }).toList(),
    );
  }
}
