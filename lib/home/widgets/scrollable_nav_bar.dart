/// 可水平捲動的底部導覽列元件。
///
/// 此元件會依據目前選中的項目，動態套用對應的文字色與背景色，
/// 並以膠囊式背景突顯當前選取狀態。
///
/// 搭配 [HomeItem] 清單使用，並透過 [onTap] 將點擊的索引回傳給外部。
import 'package:flutter/material.dart';
import '../home_model.dart';

/// 一個可左右捲動的導覽列元件。
///
/// 適合用在項目數量較多、無法於單一畫面寬度內完整顯示的情境。
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
    // 取得目前主題設定，供顏色與樣式回退使用。
    final theme = Theme.of(context);

    // 取得目前選中的項目資料。
    final currentItem = items[currentIndex];

    // 顏色回退邏輯：優先使用目前項目的自訂文字顏色，否則使用主題主色。
    final Color activeColor =
        currentItem.textColor ?? theme.colorScheme.primary;

    // 導覽列背景色：優先使用目前項目的自訂背景色，否則使用主題 surface 色。
    final Color navBgColor =
        currentItem.backgroundColor ?? theme.colorScheme.surface;

    return Container(
      // 套用導覽列背景色。
      color: navBgColor,

      // 固定高度，對齊 Material 3 常見的導覽列高度設計。
      height: 85, // 适配 Material 3 标准高度

      child: SingleChildScrollView(
        // 設定為水平捲動。
        scrollDirection: Axis.horizontal,

        // 左右保留內距，避免內容貼齊邊界。
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: Row(
          // 依據項目數量動態產生每一個導覽按鈕。
          children: List.generate(items.length, (index) {
            // 取得目前迭代的項目資料。
            final item = items[index];

            // 判斷目前這個項目是否為選中狀態。
            final bool isSelected = currentIndex == index;

            return InkWell(
              // 點擊時將索引傳回外部處理。
              onTap: () => onTap(index),

              // 移除預設水波紋與高亮背景，改用自訂膠囊背景表現選中狀態。
              // 去掉默认的水波纹背景，使用自定义的胶囊背景
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,

              child: Padding(
                // 每個導覽項目左右保留間距，讓排版更舒適。
                padding: const EdgeInsets.symmetric(horizontal: 12),

                child: Column(
                  // 讓圖示與文字在可用高度內垂直置中。
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 以動畫容器模擬選中時的膠囊背景效果。
                    // 模拟选中的胶囊背景
                    AnimatedContainer(
                      // 切換選中狀態時的動畫時間。
                      duration: const Duration(milliseconds: 250),

                      // 動畫曲線使用平滑的 easeInOut。
                      curve: Curves.easeInOut,

                      // 膠囊背景內部留白，控制圖示周圍空間。
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        // 若為選中狀態，顯示淡色膠囊背景；否則為透明。
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.15)
                            : Colors.transparent,

                        // 設定圓角形成膠囊外觀。
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Icon(
                        // 顯示項目對應的圖示。
                        item.icon,

                        // 選中時使用完整強調色，未選中時降低透明度。
                        color: isSelected
                            ? activeColor
                            : activeColor.withValues(alpha: 0.5),
                      ),
                    ),

                    // 圖示與文字之間的垂直間距。
                    const SizedBox(height: 4),

                    // 顯示導覽項目的標題文字。
                    // 标题文字
                    Text(
                      item.title,
                      style: TextStyle(
                        // 選中時使用完整強調色，未選中時降低透明度。
                        color: isSelected
                            ? activeColor
                            : activeColor.withValues(alpha: 0.5),

                        // 導覽列文字大小。
                        fontSize: 12,

                        // 選中時加粗，未選中時維持一般字重。
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
