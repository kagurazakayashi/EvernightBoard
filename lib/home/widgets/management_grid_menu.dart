import 'package:flutter/material.dart';
import 'package:evernight_board/global.dart';
// 引入 staggered_grid_view 套件
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 管理功能用的網格式選單元件（高度自適應版本）。
///
/// 此元件用於集中呈現一組管理操作入口，包含圖示編輯、標題編輯、
/// 項目移動、文字／圖片設定、顏色設定、複製、刪除與開啟設定等功能。
///
/// 版面採用四欄網格配置，並搭配自適應高度設計，讓不同長度的文字標籤
/// 能依內容自然撐開，避免因固定高度造成截斷或排版擁擠。
class ManagementGridMenu extends StatelessWidget {
  /// 新增項目的回呼。
  final VoidCallback onAdd;

  /// 刪除項目的回呼。
  final VoidCallback onDelete;

  /// 將項目上移的回呼。
  final VoidCallback onMoveUp;

  /// 將項目下移的回呼。
  final VoidCallback onMoveDown;

  /// 編輯標題的回呼。
  final VoidCallback onEditTitle;

  /// 編輯圖示的回呼。
  final VoidCallback onEditIcon;

  /// 將內容設為文字的回呼。
  final VoidCallback onSetText;

  /// 將內容設為圖片的回呼。
  final VoidCallback onSetImage;

  /// 設定文字顏色的回呼。
  final VoidCallback onSetTextColor;

  /// 設定背景顏色的回呼。
  final VoidCallback onSetBgColor;

  /// 複製項目的回呼。
  final VoidCallback onCopy;

  /// 開啟應用程式設定的回呼。
  final VoidCallback onOpenSettings;

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

  /// 統一處理管理選單項目的點擊事件。
  ///
  /// 透過集中式包裝可在執行實際回呼前，先輸出一致格式的除錯訊息，
  /// 方便於開發階段快速追蹤使用者操作流程。
  ///
  /// [actionName] 為目前觸發的操作名稱。
  /// [callback] 為對應操作的實際執行函式。
  void _handleMenuTap(String actionName, VoidCallback callback) {
    debugPrint('[ManagementGridMenu] 使用者觸發管理操作：$actionName');
    callback();
  }

  @override
  Widget build(BuildContext context) {
    /// 管理選單的資料來源清單。
    ///
    /// 每個項目封裝圖示、顯示文字、點擊事件與對應的視覺強調色，
    /// 供網格清單統一渲染使用。
    final List<_GridItemData> menuItems = [
      _GridItemData(
        Icons.category,
        t.sidebaricons,
        () => _handleMenuTap(t.sidebaricons, onEditIcon),
        color: Colors.cyan,
      ),
      _GridItemData(
        Icons.title,
        t.sidebartitle,
        () => _handleMenuTap(t.sidebartitle, onEditTitle),
        color: Colors.cyan,
      ),
      _GridItemData(
        Icons.arrow_upward,
        t.moveforward,
        () => _handleMenuTap(t.moveforward, onMoveUp),
        color: Colors.green,
      ),
      _GridItemData(
        Icons.arrow_downward,
        t.movebackward,
        () => _handleMenuTap(t.movebackward, onMoveDown),
        color: Colors.green,
      ),
      _GridItemData(
        Icons.text_fields,
        t.setastext,
        () => _handleMenuTap(t.setastext, onSetText),
        color: Colors.orange,
      ),
      _GridItemData(
        Icons.image,
        t.setasimage,
        () => _handleMenuTap(t.setasimage, onSetImage),
        color: Colors.orange,
      ),
      _GridItemData(
        Icons.color_lens,
        t.textcolor,
        () => _handleMenuTap(t.textcolor, onSetTextColor),
        color: Colors.pinkAccent,
      ),
      _GridItemData(
        Icons.format_color_fill,
        t.backgroundcolor,
        () => _handleMenuTap(t.backgroundcolor, onSetBgColor),
        color: Colors.pinkAccent,
      ),
      _GridItemData(
        Icons.add_to_photos,
        t.addscreen,
        () => _handleMenuTap(t.addscreen, onAdd),
        color: Colors.blue,
      ),
      _GridItemData(
        Icons.content_copy,
        t.copyscreen,
        () => _handleMenuTap(t.copyscreen, onCopy),
        color: Colors.blue,
      ),
      _GridItemData(
        Icons.delete_forever,
        t.deletescreen,
        () => _handleMenuTap(t.deletescreen, onDelete),
        color: Colors.red,
      ),
      _GridItemData(
        Icons.settings,
        t.appsettings,
        () => _handleMenuTap(t.appsettings, onOpenSettings),
        color: Colors.grey,
      ),
    ];

    debugPrint('[ManagementGridMenu] 正在建構管理功能網格選單，共 ${menuItems.length} 個操作項目');

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AlignedGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // 固定為四欄配置，讓操作入口在有限寬度下維持一致且易於辨識的排列方式。
              crossAxisCount: 4,
              // 設定列與列之間的垂直間距，避免項目上下過於擁擠。
              mainAxisSpacing: 10,
              // 設定欄與欄之間的水平間距；目前維持為 0，以保留較緊湊的橫向排列。
              crossAxisSpacing: 0,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final theme = Theme.of(context);

                /// 目前項目的實際顯示色彩。
                ///
                /// 若項目有指定顏色則優先使用，否則回退至目前主題的 onSurface 色彩，
                /// 以確保在不同主題模式下仍具備足夠可讀性。
                final Color activeColor =
                    item.color ?? theme.colorScheme.onSurface;

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    // 增加上下留白，提升點擊區域手感，且不限制內容高度。
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 25),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          // 不限制最大行數，讓標籤文字可依實際內容自然換行顯示。
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

/// 管理選單單一格位的資料模型。
///
/// 此類別僅作為 UI 渲染所需的輕量資料封裝，包含：
/// - [icon]：顯示圖示
/// - [label]：顯示文字
/// - [onTap]：點擊後執行的操作
/// - [color]：項目的主要視覺顏色，可為空
class _GridItemData {
  /// 選單項目的圖示資料。
  final IconData icon;

  /// 選單項目的文字標籤。
  final String label;

  /// 點擊選單項目時要執行的回呼。
  final VoidCallback onTap;

  /// 選單項目的強調色；若未提供，將由外部主題色補足。
  final Color? color;

  /// 建立一筆網格選單項目資料。
  _GridItemData(this.icon, this.label, this.onTap, {this.color});
}
