/// 可捲動的側邊導覽列元件。
///
/// 此元件以 `NavigationRail` 為核心，外層包覆 `SingleChildScrollView`，
/// 讓導覽項目在數量較多或垂直空間不足時仍可捲動顯示。
///
/// 特色如下：
/// - 根據目前選取的項目動態調整背景色與文字色。
/// - 支援外部傳入目前索引值與點擊回呼。
/// - 適合用於平板、桌面版或寬螢幕版面配置中的側邊選單。
library;

import 'package:flutter/material.dart';
import '../home_model.dart';

/// 可捲動的側邊導覽列 StatelessWidget。
class ScrollableSideRail extends StatelessWidget {
  /// 側邊導覽列要顯示的項目清單。
  final List<HomeItem> items;

  /// 目前被選取的項目索引。
  final int currentIndex;

  /// 點擊導覽項目時觸發的回呼函式。
  ///
  /// 傳出的參數為被點擊項目的索引值。
  final Function(int) onTap;

  /// 建構子。
  ///
  /// - [items]：導覽項目清單，不可為空。
  /// - [currentIndex]：目前選取的索引位置。
  /// - [onTap]：使用者選取導覽項目時的回呼。
  const ScrollableSideRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 取得目前選取的項目，用來套用對應的背景色與文字色。
    final currentItem = items[currentIndex];

    return Container(
      // 整個側邊欄的背景色，依目前選取項目的背景色動態切換。
      color: currentItem.backgroundColor,
      child: SingleChildScrollView(
        // 讓整個導覽列在垂直空間不足時可以捲動。
        child: IntrinsicHeight(
          // 依內容本身的高度來撐開元件，
          // 避免在某些版面情況下高度計算異常。
          child: NavigationRail(
            // 導覽列本身背景設為透明，
            // 由外層 Container 統一控制背景顏色。
            backgroundColor: Colors.transparent,

            // 指定目前被選取的項目索引。
            selectedIndex: currentIndex,

            // 當使用者點擊某個導覽項目時，
            // 直接呼叫外部傳入的 onTap 回呼。
            onDestinationSelected: onTap,

            // 顯示所有項目的標籤文字。
            labelType: NavigationRailLabelType.all,

            // 已選取項目的圖示樣式。
            selectedIconTheme: IconThemeData(color: currentItem.textColor),

            // 已選取項目的文字樣式。
            selectedLabelTextStyle: TextStyle(
              color: currentItem.textColor,
              fontWeight: FontWeight.bold,
            ),

            // 未選取項目的圖示樣式，
            // 使用較低透明度來區分選取與未選取狀態。
            unselectedIconTheme: IconThemeData(
              color: currentItem.textColor.withValues(alpha: 0.5),
            ),

            // 未選取項目的文字樣式，
            // 同樣以半透明方式呈現。
            unselectedLabelTextStyle: TextStyle(
              color: currentItem.textColor.withValues(alpha: 0.5),
            ),

            // 將 items 清單轉換成 NavigationRailDestination 清單。
            destinations: items
                .map(
                  (e) => NavigationRailDestination(
                    // 每個導覽項目的圖示。
                    icon: Icon(e.icon),

                    // 每個導覽項目的標籤文字。
                    label: Text(e.title),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
