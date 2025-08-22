import 'package:flutter/material.dart';
import '../home_model.dart';

/// 可捲動的側邊導覽列元件。
///
/// 適用於導覽項目數量可能超出可視高度的情境，透過 `SingleChildScrollView`
/// 讓整個 `NavigationRail` 可以垂直捲動，避免內容被截斷。
///
/// 此元件會依據目前選取的 `HomeItem`，動態套用目前頁面的文字色與背景色；
/// 若對應色彩為空，則自動回退到目前主題的預設色彩。
class ScrollableSideRail extends StatelessWidget {
  /// 側邊導覽列要顯示的項目清單。
  final List<HomeItem> items;

  /// 目前選取中的導覽項目索引。
  final int currentIndex;

  /// 點擊導覽項目時的回呼函式。
  ///
  /// 參數為被點擊項目的索引值。
  final Function(int) onTap;

  /// 建立可捲動側邊導覽列。
  const ScrollableSideRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 取得目前主題，供色彩樣式回退使用。
    final theme = Theme.of(context);

    // 取得目前選取中的項目，用來決定目前導覽列的主色與背景色。
    final currentItem = items[currentIndex];

    // 顏色回退邏輯：
    // 若目前項目有自訂文字顏色，優先使用；
    // 否則回退到主題的 primary 色。
    final Color activeColor =
        currentItem.textColor ?? theme.colorScheme.primary;

    // 若目前項目有自訂背景顏色，優先使用；
    // 否則回退到主題的 surface 色。
    final Color navBgColor =
        currentItem.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      // 整個側邊導覽區塊的背景色。
      color: navBgColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // 確保當內容較少時，最小高度仍至少等於可用高度，
              // 這樣背景色才能完整鋪滿整個側邊區域。
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  // 由外層 Container 控制背景，因此此處設為透明。
                  backgroundColor: Colors.transparent,

                  // 目前選取中的項目索引。
                  selectedIndex: currentIndex,

                  // 點擊導覽項目時，將索引值往外傳遞。
                  onDestinationSelected: onTap,

                  // 顯示所有項目的文字標籤。
                  labelType: NavigationRailLabelType.all,

                  // 選中狀態的圖示樣式。
                  selectedIconTheme: IconThemeData(color: activeColor),

                  // 選中狀態的文字樣式。
                  selectedLabelTextStyle: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                  ),

                  // 未選中狀態的圖示樣式。
                  // 使用新版 withValues 取代舊版 withOpacity。
                  unselectedIconTheme: IconThemeData(
                    color: activeColor.withValues(alpha: 0.5),
                  ),

                  // 未選中狀態的文字樣式。
                  unselectedLabelTextStyle: TextStyle(
                    color: activeColor.withValues(alpha: 0.5),
                  ),

                  // 選中項目的背景指示器顏色，
                  // 透過較低透明度呈現輕量高亮效果。
                  indicatorColor: activeColor.withValues(alpha: 0.15),

                  // 將資料清單轉換為 NavigationRail 需要的目的地項目。
                  destinations: items
                      .map(
                        (e) => NavigationRailDestination(
                          // 導覽項目的圖示。
                          icon: Icon(e.icon),

                          // 導覽項目的標題文字。
                          label: Text(e.title),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
