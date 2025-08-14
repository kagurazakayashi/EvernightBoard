import 'package:flutter/material.dart';
import 'home_controller.dart';

/// 首頁畫面元件。
///
/// 使用 [StatefulWidget] 以便在控制器狀態變更時，
/// 透過 `setState` 重新建構畫面。
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 對應的狀態類別。
///
/// 負責：
/// 1. 建立並持有 [HomeController]
/// 2. 監聽控制器狀態變化
/// 3. 依據螢幕方向切換版面配置
class _HomeViewState extends State<HomeView> {
  /// 首頁邏輯控制器，用來管理目前索引、內容與導覽位置。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();

    // 監聽控制器變化；當控制器通知更新時，重新建構畫面。
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
    // 使用 OrientationBuilder 依裝置方向建立不同版面。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向畫面。
        bool isPortrait = orientation == Orientation.portrait;

        // 如果是横屏，直接使用 Scaffold 自带的底部导航
        return Scaffold(
          // 橫向時顯示底部導覽列；直向時不顯示。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(),

          // 直向顯示左右分欄；橫向只顯示主要文字內容。
          body: isPortrait ? _buildPortraitLayout() : _buildScalingText(),
        );
      },
    );
  }

  /// 建立直向模式下的版面配置。
  ///
  /// 依照 Controller 內的 `currentSide` 決定：
  /// - 文字內容在左、導覽列在右
  /// - 或導覽列在左、文字內容在右
  Widget _buildPortraitLayout() {
    // 預設順序：[文字, 導航欄] -> 導航欄在右
    Widget textWidget = Expanded(child: _buildScalingText());
    Widget navWidget = _buildSideNav();

    return Row(
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget] // 在左
          : [textWidget, navWidget], // 在右
    );
  }

  // --- 基础组件抽取 (保持不变) ---

  /// 建立可依空間自動縮放字體大小的文字區塊。
  ///
  /// 透過 [LayoutBuilder] 取得可用尺寸後，
  /// 再呼叫 [_calculateSize] 計算適合的字體大小。
  Widget _buildScalingText() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 取得目前要顯示的文字內容。
        final String text = _controller.currentContent;

        // ... (此处省略上文已实现的 TextPainter 缩放逻辑)
        // 关键点：fontSize 依然基于当前的 constraints.maxWidth 计算

        // 將文字置中顯示，並套用動態計算後的字體大小。
        return Center(
          child: Text(
            text,
            style: TextStyle(fontSize: _calculateSize(text, constraints)),
          ),
        );
      },
    );
  }

  /// 建立直向模式使用的側邊導覽列。
  ///
  /// 使用 [NavigationRail] 呈現所有導覽項目，
  /// 並將選取狀態與點擊事件交由控制器處理。
  Widget _buildSideNav() {
    return NavigationRail(
      // 目前被選取的導覽索引。
      selectedIndex: _controller.currentIndex,

      // 點擊導覽項目時，通知控制器切換索引。
      onDestinationSelected: _controller.changeIndex,

      // 顯示所有項目的文字標籤。
      labelType: NavigationRailLabelType.all,

      // 將控制器中的項目資料轉為 NavigationRailDestination 清單。
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

  /// 建立橫向模式使用的底部導覽列。
  ///
  /// 使用 [BottomNavigationBar] 呈現所有導覽項目，
  /// 並同步控制器中的目前索引。
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      // 目前被選取的導覽索引。
      currentIndex: _controller.currentIndex,

      // 點擊項目時通知控制器更新目前索引。
      onTap: _controller.changeIndex,

      // 將控制器中的項目資料轉為 BottomNavigationBarItem 清單。
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

  /// 根據文字內容與可用版面空間，計算適合的字體大小。
  ///
  /// 此方法會先以固定字體大小建立 [TextPainter]，
  /// 量測文字實際寬高後，再依容器的寬與高取最小縮放比例，
  /// 最後乘上 `0.9` 預留一些邊界空間，避免文字貼齊容器邊緣。
  ///
  /// 參數：
  /// - [text]：欲顯示的文字內容
  /// - [constraints]：目前版面可用的尺寸限制
  ///
  /// 回傳：
  /// - 適合目前容器的字體大小
  double _calculateSize(String text, BoxConstraints constraints) {
    // 建立文字量測器，先以 100 的基準字體大小進行排版計算。
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 依可用寬高分別計算縮放比例，並取較小值以確保文字完整容納。
    double scale =
        (constraints.maxWidth / tp.width) < (constraints.maxHeight / tp.height)
        ? (constraints.maxWidth / tp.width)
        : (constraints.maxHeight / tp.height);

    // 以基準字體大小乘上縮放比例，再保留 10% 邊界。
    return (100 * scale) * 0.9;
  }
}
