/// 可水平捲動的底部導覽列元件。
///
/// 功能說明：
/// - 依據 [items] 動態產生多個導覽項目。
/// - 使用 [currentIndex] 標示目前選中的項目。
/// - 點擊項目時透過 [onTap] 將索引回傳給外部。
///
/// 視覺行為：
/// - 整體背景色會跟隨目前選中的項目變化。
/// - 被選中的項目會有半透明底色與較醒目的文字樣式。
/// - 當項目數量過多時，可左右水平捲動。
library;

import 'package:flutter/material.dart';
import '../home_model.dart';

/// 可水平捲動的導覽列。
class ScrollableNavBar extends StatelessWidget {
  /// 導覽列要顯示的所有項目資料。
  final List<HomeItem> items;

  /// 目前選中的項目索引。
  final int currentIndex;

  /// 點擊導覽項目時觸發的回呼函式。
  ///
  /// 傳入值為被點擊項目的索引。
  final Function(int) onTap;

  /// 建立 [ScrollableNavBar]。
  const ScrollableNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 取得目前選中的項目，供整體背景色與文字／圖示顏色使用。
    final currentItem = items[currentIndex];

    return Container(
      // 導覽列背景色跟隨目前選中項目的背景色。
      color: currentItem.backgroundColor,
      // 固定導覽列高度。
      height: 85,
      child: SingleChildScrollView(
        // 設定為水平捲動，讓多個項目可左右滑動查看。
        scrollDirection: Axis.horizontal,
        // 設定左右內距，避免內容貼齊邊界。
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List.generate(items.length, (index) {
            // 判斷目前產生的項目是否為選中狀態。
            final bool isSelected = currentIndex == index;

            // 取得目前索引對應的導覽項目資料。
            final item = items[index];

            return InkWell(
              // 點擊後將目前項目的索引回傳給外部。
              onTap: () => onTap(index),
              child: Padding(
                // 每個導覽項目左右保留固定間距。
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  // 垂直置中排列圖示與文字。
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      // 切換選中狀態時，做出平滑的動畫過渡效果。
                      duration: const Duration(milliseconds: 250),
                      // 圖示容器的內距，讓點擊區與視覺更舒適。
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // 若為選中狀態，顯示帶透明度的底色；否則為透明。
                        color: isSelected
                            ? currentItem.textColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                        // 設定圓角外觀，形成膠囊式背景。
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // 顯示項目圖示，顏色使用目前選中項目的文字色以維持整體一致性。
                      child: Icon(item.icon, color: currentItem.textColor),
                    ),
                    // 圖示與文字之間的垂直間距。
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        // 選中時使用完整顏色，未選中時降低透明度。
                        color: isSelected
                            ? currentItem.textColor
                            : currentItem.textColor.withValues(alpha: 0.5),
                        // 導覽文字字級。
                        fontSize: 12,
                        // 選中時使用粗體，未選中時為一般字重。
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
