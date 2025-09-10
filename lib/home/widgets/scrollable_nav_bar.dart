/// 可水平捲動的底部導覽列元件。
///
/// 此元件會依據目前選中的項目，動態套用對應的文字色與背景色，
/// 並以膠囊式背景突顯當前選取狀態。
///
/// 搭配 [HomeItem] 清單使用，並透過 [onTap] 將點擊的索引回傳給外部。
library;

import 'package:flutter/material.dart';
import '../home_model.dart';

/// 一個可左右捲動的導覽列元件。
///
/// 適合用在項目數量較多、無法於單一畫面寬度內完整顯示的情境。
///
/// 此元件本身不管理選取狀態，需由外部透過 [currentIndex] 傳入目前狀態，
/// 並在 [onTap] 中處理點擊後的切換邏輯。
class ScrollableNavBar extends StatelessWidget {
  /// 導覽列要顯示的所有項目資料。
  final List<HomeItem> items;

  /// 目前選中的項目索引。
  final int currentIndex;

  /// 點擊項目時的回呼函式，會回傳被點擊的索引值。
  final Function(int) onTap;

  /// 建立一個 [ScrollableNavBar]。
  const ScrollableNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 取得目前主題，供顏色與樣式回退使用。
    final theme = Theme.of(context);

    // 檢查目前索引是否落在有效範圍內，避免清單為空或索引越界時直接存取失敗。
    final bool hasValidCurrentIndex =
        items.isNotEmpty && currentIndex >= 0 && currentIndex < items.length;

    // 當索引無效時輸出偵錯資訊，協助排查外部狀態管理或資料同步問題。
    if (!hasValidCurrentIndex) {
      debugPrint(
        '[ScrollableNavBar] currentIndex 無效，items.length=${items.length}，currentIndex=$currentIndex',
      );
    }

    // 取得目前選中的項目資料；若目前沒有可用項目或索引無效，則使用暫時的預設項目避免例外。
    final currentItem = hasValidCurrentIndex
        ? items[currentIndex]
        : HomeItem(title: "...", content: "", icon: Icons.hourglass_empty);

    // 目前作用中的主色：
    // 優先使用目前項目的自訂文字顏色，若未提供則退回主題的 primary 色。
    final Color activeColor =
        currentItem.textColor ?? theme.colorScheme.primary;

    // 導覽列背景色：
    // 優先使用目前項目的自訂背景色，若未提供則退回主題的 surface 色。
    final Color navBgColor =
        currentItem.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      // 套用整個導覽列的背景色。
      color: navBgColor,

      // 固定導覽列高度，以符合常見底部導覽列的視覺比例。
      height: 85,

      child: SingleChildScrollView(
        // 啟用水平捲動，讓較多項目仍可完整顯示。
        scrollDirection: Axis.horizontal,

        // 在左右兩側加入內距，避免內容緊貼容器邊界。
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: Row(
          // 根據資料清單動態建立每一個導覽項目。
          children: List.generate(items.length, (index) {
            // 取得目前迭代的項目資料。
            final item = items[index];

            // 判斷目前項目是否為選取狀態。
            final bool isSelected = currentIndex == index;

            return InkWell(
              // 點擊時將索引回傳給外部，由外部更新選取狀態。
              onTap: () {
                debugPrint(
                  '[ScrollableNavBar] 點擊導覽項目：index=$index, title=${item.title}',
                );
                onTap(index);
              },

              // 移除預設水波紋與高亮效果，改由自訂膠囊背景呈現互動狀態。
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,

              child: Padding(
                // 每個導覽項目左右保留間距，提升可讀性與點擊舒適度。
                padding: const EdgeInsets.symmetric(horizontal: 12),

                child: Column(
                  // 讓圖示與文字在可用高度中垂直置中。
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 使用動畫容器呈現選取時的膠囊式背景轉場效果。
                    AnimatedContainer(
                      // 設定選取狀態切換時的動畫時間。
                      duration: const Duration(milliseconds: 250),

                      // 使用平滑的動畫曲線，讓切換更自然。
                      curve: Curves.easeInOut,

                      // 膠囊背景的內距，控制圖示周圍留白。
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        // 選取時顯示淡色膠囊背景，未選取時維持透明。
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.15)
                            : Colors.transparent,

                        // 以較大圓角形成膠囊外觀。
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Icon(
                        // 顯示該導覽項目對應的圖示。
                        item.icon,

                        // 選取時使用完整強調色，未選取時降低透明度以形成層級。
                        color: isSelected
                            ? activeColor
                            : activeColor.withValues(alpha: 0.5),
                      ),
                    ),

                    // 圖示與標題之間的垂直間距。
                    const SizedBox(height: 4),

                    // 顯示導覽項目的標題文字。
                    Text(
                      item.title,
                      style: TextStyle(
                        // 選取時使用完整強調色，未選取時降低透明度。
                        color: isSelected
                            ? activeColor
                            : activeColor.withValues(alpha: 0.5),

                        // 導覽列標題字級。
                        fontSize: 12,

                        // 選取時加粗，讓目前頁籤更明顯。
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
