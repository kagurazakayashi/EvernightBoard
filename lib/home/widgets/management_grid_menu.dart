import 'package:flutter/material.dart';

/// 管理功能用的網格式選單元件。
///
/// 此元件會以固定欄數的格狀版面顯示一組操作項目，讓使用者可快速執行：
/// 新增、刪除、複製、上下移動、修改標題、修改圖示、切換文字或圖片，
/// 以及設定文字顏色、背景顏色與開啟應用設定等動作。
///
/// 適合用於後台管理、版面配置、導覽項目編輯等操作情境。
class ManagementGridMenu extends StatelessWidget {
  /// 點擊「新增項」時觸發的回呼函式。
  final VoidCallback onAdd;

  /// 點擊「刪除項」時觸發的回呼函式。
  final VoidCallback onDelete;

  /// 點擊「上移」時觸發的回呼函式。
  final VoidCallback onMoveUp;

  /// 點擊「下移」時觸發的回呼函式。
  final VoidCallback onMoveDown;

  /// 點擊「改標題」時觸發的回呼函式。
  final VoidCallback onEditTitle;

  /// 點擊「改圖示」時觸發的回呼函式。
  final VoidCallback onEditIcon;

  /// 點擊「設為文字」時觸發的回呼函式。
  final VoidCallback onSetText;

  /// 點擊「設為圖片」時觸發的回呼函式。
  final VoidCallback onSetImage;

  /// 點擊「文字顏色」時觸發的回呼函式。
  final VoidCallback onSetTextColor;

  /// 點擊「背景顏色」時觸發的回呼函式。
  final VoidCallback onSetBgColor;

  /// 點擊「複製項」時觸發的回呼函式。
  final VoidCallback onCopy;

  /// 點擊「應用設定」時觸發的回呼函式。
  final VoidCallback onOpenSettings;

  /// 建立 [ManagementGridMenu]。
  ///
  /// 所有操作項目的回呼函式皆為必填，呼叫端需自行提供對應處理邏輯。
  const ManagementGridMenu({
    super.key,
    required this.onEditIcon,
    required this.onEditTitle,
    required this.onSetText,
    required this.onSetImage,
    required this.onSetTextColor,
    required this.onSetBgColor,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onAdd,
    required this.onCopy,
    required this.onDelete,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    // 建立網格式選單的項目資料清單。
    final List<_GridItemData> menuItems = [
      // 第一列：圖示／標題編輯與排序調整功能。
      _GridItemData(Icons.category, '边栏图标', onEditIcon, color: Colors.cyan),
      _GridItemData(Icons.title, '边栏标题', onEditTitle, color: Colors.cyan),
      _GridItemData(Icons.arrow_upward, '上移', onMoveUp, color: Colors.green),
      _GridItemData(
        Icons.arrow_downward,
        '下移',
        onMoveDown,
        color: Colors.green,
      ),

      // 第二列：內容型態與顏色設定功能。
      _GridItemData(Icons.text_fields, '设为文字', onSetText, color: Colors.orange),
      _GridItemData(Icons.image, '设为图片', onSetImage, color: Colors.orange),
      _GridItemData(
        Icons.color_lens,
        '文字颜色',
        onSetTextColor,
        color: Colors.pinkAccent,
      ),
      _GridItemData(
        Icons.format_color_fill,
        '背景颜色',
        onSetBgColor,
        color: Colors.pinkAccent,
      ),

      // 第三列：項目管理與系統設定功能。
      _GridItemData(
        Icons.add_to_photos,
        '新增屏幕',
        onAdd,
        color: Colors.blue,
      ), // 以藍色突顯新增操作。
      _GridItemData(Icons.content_copy, '复制屏幕', onCopy, color: Colors.blue),
      _GridItemData(
        Icons.delete_forever,
        '删除屏幕',
        onDelete,
        color: Colors.red,
      ), // 以紅色突顯刪除操作。
      _GridItemData(
        Icons.settings, // 設定功能的圖示。
        '应用设置',
        onOpenSettings, // 點擊後執行設定頁開啟邏輯。
        color: Colors.grey,
      ),
    ];

    return SafeArea(
      // 以最大寬度限制版面，避免在大螢幕上被過度拉寬。
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 20, // 控制列與列之間的間距。
                crossAxisSpacing: 10, // 控制欄與欄之間的間距。
                mainAxisExtent: 80, // 固定每個網格項目的主軸高度。
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final theme = Theme.of(context);

                // 優先使用項目自訂顏色，否則退回主題預設文字色。
                final Color activeColor =
                    item.color ?? theme.colorScheme.onSurface;

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 內容垂直置中。
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10), // 圖示外圍的內距。
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 25,
                        ), // 顯示功能圖示。
                      ),
                      const SizedBox(height: 10), // 圖示與文字之間的間距。
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: item.color != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: activeColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 網格選單單一項目的資料模型。
///
/// 封裝每一個操作項目所需的顯示與互動資料，包含：
/// 圖示、顯示文字、點擊事件，以及可選的顏色設定。
class _GridItemData {
  /// 項目顯示用的圖示資料。
  final IconData icon;

  /// 項目顯示的文字標籤。
  final String label;

  /// 點擊此項目時執行的回呼函式。
  final VoidCallback onTap;

  /// 項目的圖示與文字顏色；若未指定則由外部主題決定。
  final Color? color;

  /// 建立一筆網格選單項目資料。
  _GridItemData(this.icon, this.label, this.onTap, {this.color});
}
