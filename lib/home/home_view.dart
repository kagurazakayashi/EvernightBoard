import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'home_model.dart'; // 引入模型

/// 首頁畫面元件。
///
/// 負責建立首頁的 StatefulWidget，並將實際畫面狀態交由 [_HomeViewState] 管理。
class HomeView extends StatefulWidget {
  /// 建立首頁畫面。
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// 首頁畫面的狀態類別。
///
/// 此類別負責：
/// - 監聽 [HomeController] 狀態變化
/// - 依照螢幕方向切換直向／橫向版面
/// - 顯示背景圖片或自動縮放文字內容
/// - 建立底部導覽列或側邊導覽列
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器，用來管理目前項目、切換邏輯與狀態通知。
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    // 註冊狀態監聽器，當 controller 狀態改變時更新畫面。
    _controller.addListener(_handleStateChange);
  }

  /// 處理 controller 狀態改變事件。
  ///
  /// 當 widget 仍掛載在樹上時，呼叫 [setState] 重新建構畫面。
  void _handleStateChange() {
    // 確保當前 State 仍有效，避免已卸載後仍觸發重建。
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 先移除監聽，避免 controller 在釋放後仍回呼此 State。
    _controller.removeListener(_handleStateChange);
    // 釋放 controller 內部資源。
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 OrientationBuilder 依螢幕方向動態切換版面配置。
    return OrientationBuilder(
      builder: (context, orientation) {
        // 判斷目前是否為直向畫面。
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          // 使用 Model 的背景色作为 Scaffold 的底色，防止切换瞬间闪白
          backgroundColor: _controller.currentItem.backgroundColor,
          // 橫向時顯示底部導覽列；直向則不顯示。
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(),
          body: Stack(
            children: [
              // 层 1：底层触控反馈层
              // 最底層放觸控區，負責點擊上一個／下一個項目。
              _buildTouchLayer(isPortrait),
              // 层 2：内容与侧边栏
              // 上層顯示主要內容；直向為含側邊導覽的版面，橫向僅顯示內容區。
              isPortrait ? _buildPortraitLayout() : _buildDisplayArea(),
            ],
          ),
        );
      },
    );
  }

  // --- 触控层 (水波纹反馈用 Model 的 textColor) ---

  /// 建立全畫面的觸控層。
  ///
  /// 直向時以上下兩半區域控制上一個／下一個；
  /// 橫向時以左右兩半區域控制上一個／下一個。
  ///
  /// 水波紋與高亮色會依目前項目的文字顏色做透明化處理。
  Widget _buildTouchLayer(bool isPortrait) {
    // 取得目前顯示的資料項目。
    final item = _controller.currentItem;
    // 水波纹和按下高亮使用文字色的透明版本
    final Color splash = item.textColor.withValues(alpha: 0.1);
    final Color highlight = item.textColor.withValues(alpha: 0.05);

    return Material(
      // 外層 Material 設透明，讓 InkWell 水波紋可以正常顯示但不覆蓋背景。
      color: Colors.transparent,
      child: isPortrait
          ? Column(
              children: [
                Expanded(
                  child: InkWell(
                    // 點擊上半部切換到上一個項目。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 點擊下半部切換到下一個項目。
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
                    // 點擊左半部切換到上一個項目。
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    // 點擊右半部切換到下一個項目。
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

  /// 建立直向模式的版面。
  ///
  /// 包含：
  /// - 主要顯示區
  /// - 左側或右側的 [NavigationRail]
  ///
  /// 導覽列位置會依 [_controller.currentSide] 決定。
  Widget _buildPortraitLayout() {
    // 主要文字／圖片顯示區，使用 Expanded 填滿剩餘空間。
    final Widget textWidget = Expanded(child: _buildDisplayArea());

    // 側邊導覽列，用於切換不同頁面項目。
    final Widget navWidget = NavigationRail(
      // 目前選取的索引。
      selectedIndex: _controller.currentIndex,
      // 點選導覽項目後切換索引。
      onDestinationSelected: _controller.changeIndex,
      // 顯示所有 label。
      labelType: NavigationRailLabelType.all,
      // 如果没有图片，让导航栏底色和内容区底色一致
      backgroundColor: _controller.currentItem.backgroundImagePath == null
          ? _controller.currentItem.backgroundColor
          : null,
      destinations: _controller.items
          .map(
            (e) => NavigationRailDestination(
              // 導覽 icon。
              icon: Icon(e.icon),
              // 導覽標題。
              label: Text(e.title),
            ),
          )
          .toList(),
    );

    return Row(
      // 依設定決定導覽列顯示在左側或右側。
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget]
          : [textWidget, navWidget],
    );
  }

  // --- 重构：显示区域 (图片 vs 文字) ---

  /// 建立主要顯示區。
  ///
  /// 顯示邏輯如下：
  /// - 若目前項目有背景圖片，則顯示圖片
  /// - 若沒有背景圖片，則顯示自動縮放的文字
  ///
  /// 此區域使用 [IgnorePointer] 忽略觸控事件，
  /// 讓手勢可傳遞到底層的觸控層處理。
  Widget _buildDisplayArea() {
    return IgnorePointer(
      // 必须忽略点击，手势才能传递给底层的 Stack 触控层
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 取得目前要顯示的項目資料。
          final HomeItem item = _controller.currentItem;

          // --- 逻辑核心：如果有图片，显示图片，不显示文字 ---
          if (item.backgroundImagePath != null &&
              item.backgroundImagePath!.isNotEmpty) {
            return Container(
              // 讓容器寬度填滿可用空間。
              width: constraints.maxWidth,
              // 讓容器高度填滿可用空間。
              height: constraints.maxHeight,
              // 防止圖片使用 contain 時露出不協調的底色。
              color: item.backgroundColor, // 防止图片 contain 时露出不协调的 Scaffold 底色
              alignment: Alignment.center,
              child: Image.asset(
                // 載入資產圖片。
                item.backgroundImagePath!,
                // 使用 contain 縮放，確保整張圖完整顯示。
                fit: BoxFit.contain,
                // 为了让 contain 看起来也是 "填满"，
                // 我们把 Container 的宽高设满，Image 会在里面自动找最大比例。
              ),
            );
          }

          // --- 无图片逻辑：显示自动缩放文字 ---
          // 取得要顯示的文字內容。
          final String text = item.content;
          // 建立基礎文字樣式，之後會依比例調整字體大小。
          final TextStyle baseStyle = TextStyle(
            // 壓縮行高，讓大字顯示更緊湊。
            height: 1.1,
            color: item.textColor, // 使用 Model 指定的文字色
          );

          // 使用 TextPainter 先以固定字級量測文字所需大小。
          final tp = TextPainter(
            text: TextSpan(
              text: text,
              // 先用 100 作為基準字級，後續再按比例縮放。
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 依寬高限制計算縮放比例，取較小值以避免內容超出範圍。
          double scale =
              (constraints.maxWidth / tp.width) <
                  (constraints.maxHeight / tp.height)
              ? (constraints.maxWidth / tp.width)
              : (constraints.maxHeight / tp.height);

          return Container(
            color: item.backgroundColor, // 使用 Model 指定的背景色
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              text,
              // 文字置中對齊。
              textAlign: TextAlign.center,
              style: baseStyle.copyWith(
                // 根據量測結果縮放字級，並額外乘上 0.85 留出安全邊界。
                fontSize: (100 * scale) * 0.85,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 建立橫向模式下的底部導覽列。
  ///
  /// 使用 [NavigationBar] 顯示目前所有可切換項目。
  Widget _buildBottomNav() {
    return NavigationBar(
      // 當前選取索引。
      selectedIndex: _controller.currentIndex,
      // 點選導覽項目後更新索引。
      onDestinationSelected: _controller.changeIndex,
      destinations: _controller.items
          .map(
            (e) => NavigationDestination(
              // 導覽 icon。
              icon: Icon(e.icon),
              // 導覽文字。
              label: e.title,
            ),
          )
          .toList(),
    );
  }
}
