import 'package:evernight_board/global.dart';
import 'package:flutter/material.dart';
import '../home_model.dart';

/// 可捲動的側邊導覽列元件。
///
/// 適用於導覽項目數量可能超出可視高度的情境，透過 `SingleChildScrollView`
/// 讓整個 `NavigationRail` 能夠垂直捲動，避免項目超出畫面後被截斷。
///
/// 此元件會依據目前選取的 [HomeItem]，動態套用對應頁面的文字色彩與背景色彩；
/// 若項目未提供自訂色彩，則會自動回退為目前主題中的預設色彩。
///
/// 版面配置上，外層使用 [Container] 負責繪製整體背景色，
/// 內層再透過 [LayoutBuilder]、[ConstrainedBox] 與 [IntrinsicHeight]
/// 確保在內容不足一頁高度時，側邊欄仍能完整撐滿可用空間。
class ScrollableSideRail extends StatelessWidget {
  /// 側邊導覽列要顯示的導覽項目清單。
  final List<HomeItem> items;

  /// 目前已選取的導覽項目索引。
  ///
  /// 此值會對應到 [NavigationRail.selectedIndex]，
  /// 用來決定目前高亮顯示的目的地項目。
  final int currentIndex;

  /// 使用者點擊導覽項目時觸發的回呼函式。
  ///
  /// 傳入的參數為被點擊項目的索引值。
  final Function(int) onTap;

  /// 建立一個可捲動的側邊導覽列元件。
  const ScrollableSideRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 取得目前主題，供色彩回退與樣式設定使用。
    final theme = Theme.of(context);

    // 取得目前選取中的項目，用來決定導覽列的主色與背景色。
    // 若清單為空，則建立一個暫時的占位項目，避免後續色彩計算無法進行。
    // if (items.isEmpty) return Text("Loading...");
    if (items.isEmpty) {
      debugPrint('[ScrollableSideRail] items 為空，顯示預設的載入中圖示。');
    }

    final currentItem = items.isEmpty
        ? HomeItem(title: "...", content: "", icon: Icons.hourglass_empty)
        : items[currentIndex];

    // 計算選取狀態要使用的主色：
    // 若目前項目有自訂文字顏色則優先採用，否則回退為主題的 primary 色。
    final Color activeColor =
        currentItem.textColor ?? theme.colorScheme.primary;

    // 計算側邊導覽列的背景色：
    // 若目前項目有自訂背景色則優先採用，否則回退為主題的 surface 色。
    final Color navBgColor =
        currentItem.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      // 設定整個側邊導覽區塊的背景色。
      color: navBgColor,
      child: items.isEmpty
          ? const Icon(Icons.hourglass_empty)
          : LayoutBuilder(
              builder: (context, constraints) {
                // 使用可捲動容器包住 NavigationRail，
                // 讓目的地項目數量過多時仍可垂直瀏覽所有項目。
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    // 當內容高度不足時，仍強制最小高度等於可用高度，
                    // 確保背景色可以完整鋪滿整個側邊區域。
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      // 讓子元件依內容高度自我測量，
                      // 搭配最小高度限制，使側邊欄在不同內容量下都能維持合理外觀。
                      child: NavigationRail(
                        // 背景由外層 Container 負責繪製，因此這裡設為透明。
                        backgroundColor: Colors.transparent,

                        // 指定目前選取中的導覽項目索引。
                        selectedIndex: currentIndex,

                        // 當使用者選取目的地項目時，將索引值透過回呼傳出。
                        onDestinationSelected: onTap,

                        // 顯示所有導覽項目的文字標籤。
                        labelType: NavigationRailLabelType.all,

                        // 已選取項目的圖示樣式。
                        selectedIconTheme: IconThemeData(color: activeColor),

                        // 已選取項目的文字樣式。
                        selectedLabelTextStyle: TextStyle(
                          color: activeColor,
                          fontWeight: FontWeight.bold,
                        ),

                        // 未選取項目的圖示樣式。
                        // 使用較低透明度呈現次要狀態。
                        unselectedIconTheme: IconThemeData(
                          color: activeColor.withValues(alpha: 0.5),
                        ),

                        // 未選取項目的文字樣式。
                        // 與未選取圖示維持一致的透明度，降低視覺權重。
                        unselectedLabelTextStyle: TextStyle(
                          color: activeColor.withValues(alpha: 0.5),
                        ),

                        // 已選取項目的背景指示器顏色。
                        // 以較低透明度呈現柔和的高亮效果。
                        indicatorColor: activeColor.withValues(alpha: 0.15),

                        // 將導覽項目清單轉換為 NavigationRail 所需的目的地列表。
                        destinations: items.map((e) {
                          // 新增判斷邏輯
                          final String displayTitle = e.title.isEmpty
                              ? t.newscreen
                              : e.title;

                          return NavigationRailDestination(
                            icon: Icon(e.icon),
                            label: Text(displayTitle), // 使用處理後的標題
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
