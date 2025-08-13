import 'package:flutter/material.dart';
import 'home_controller.dart';

/// HomeView 為首頁畫面元件。
///
/// 此畫面會根據螢幕方向自動切換導覽列的顯示方式：
/// - 直向時：使用右側側邊導覽列
/// - 橫向時：使用底部導覽列
///
/// 中央內容會依可用空間自動縮放文字大小，
class HomeView extends StatefulWidget {
  /// 建立首頁畫面元件。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// HomeView 的狀態物件。
///
/// 負責：
/// - 管理 [HomeController]
/// - 監聽控制器資料變化並重建畫面
/// - 根據畫面方向切換版面配置
class _HomeViewState extends State<HomeView> {
  /// 首頁畫面的控制器，用來管理目前索引、內容與導覽項目。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器狀態變化，當資料更新時重新繪製畫面。
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // 釋放控制器資源，避免記憶體洩漏。
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 OrientationBuilder 監聽螢幕方向變化。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向畫面。
        bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 如果是直屏，導覽列在右側，因此不使用 bottomNavigationBar，
          // 而是在 body 中以 Row 方式排版。
          //
          // 如果是橫屏，直接使用 Scaffold 的 bottomNavigationBar。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(),
          body: isPortrait
              ? Row(
                  children: [
                    // 文字區域占據剩餘空間。
                    Expanded(child: _buildScalingText()),

                    // 右側顯示側邊導覽列。
                    _buildSideNav(),
                  ],
                )
              // 橫屏時僅顯示主內容，底部導覽列由 Scaffold 負責。
              : _buildScalingText(),
        );
      },
    );
  }

  /// 建立可依容器大小自動縮放的文字區塊。
  ///
  /// 此方法會先使用 [TextPainter] 以基準字級進行排版測量，
  /// 再依據可用寬高計算最適合的縮放比例，
  /// 讓文字能盡可能完整地顯示於畫面中央。
  Widget _buildScalingText() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 取得目前要顯示的文字內容。
        final String text = _controller.currentContent;

        // 定義文字的基礎樣式。
        const TextStyle baseStyle = TextStyle(
          height: 1.1,
          color: Colors.deepPurple,
        );

        // 使用 TextPainter 先以固定字級測量文字實際尺寸。
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: baseStyle.copyWith(fontSize: 100)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        // 根據容器可用寬高與文字實際尺寸計算縮放比例，
        // 取寬度比例與高度比例中較小者，避免文字超出容器範圍。
        double scale =
            (constraints.maxWidth / textPainter.width) <
                (constraints.maxHeight / textPainter.height)
            ? (constraints.maxWidth / textPainter.width)
            : (constraints.maxHeight / textPainter.height);

        return Container(
          // 將文字置中顯示。
          alignment: Alignment.center,

          // 設定內距，避免文字貼齊邊界。
          padding: const EdgeInsets.all(10),
          child: Text(
            text,
            textAlign: TextAlign.center,

            // 套用縮放後字級，並保留些許安全邊界。
            style: baseStyle.copyWith(fontSize: (100 * scale) * 0.9),
          ),
        );
      },
    );
  }

  /// 建立底部導覽列。
  ///
  /// 此導覽列用於橫向畫面，並依據控制器中的導覽項目動態產生按鈕。
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      // 設定目前選中的索引。
      currentIndex: _controller.currentIndex,

      // 點擊導覽項目時切換頁面索引。
      onTap: _controller.changeIndex,

      // 由控制器的項目清單動態建立導覽列項目。
      items: _controller.items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.title,
            ),
          )
          .toList(),
    );
  }

  /// 建立右側側邊導覽列。
  ///
  /// 此導覽列用於直向畫面，採用 [NavigationRail] 實作。
  Widget _buildSideNav() {
    // 使用 NavigationRail 實作側邊導覽。
    return NavigationRail(
      // 目前選中的目的地索引。
      selectedIndex: _controller.currentIndex,

      // 點選目的地時切換頁面索引。
      onDestinationSelected: _controller.changeIndex,

      // 顯示所有標籤文字。
      labelType: NavigationRailLabelType.all,

      // 由控制器的項目清單動態建立側邊導覽目的地。
      destinations: _controller.items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.title),
            ),
          )
          .toList(),
    );
  }
}
