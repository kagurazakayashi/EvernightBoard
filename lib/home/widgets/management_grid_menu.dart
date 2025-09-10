import 'package:flutter/material.dart';

/// 管理功能用的網格式選單元件。
///
/// 此元件會以固定四欄的網格版面，顯示一組後台或編輯模式常用的操作項目，
/// 讓使用者可以快速執行例如新增、刪除、複製、排序調整、標題與圖示編輯、
/// 顯示型態切換，以及色彩設定與開啟應用設定等動作。
///
/// 適合使用於：
/// - 側邊欄項目管理
/// - 畫面或頁面配置編輯
/// - 導覽選單內容維護
/// - 後台管理操作面板
///
/// 此元件本身僅負責呈現 UI 與轉發點擊事件，不包含任何狀態管理邏輯；
/// 實際的功能處理須由外部透過 callback 傳入。
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
  /// 所有操作項目的回呼函式皆為必填，呼叫端需提供對應的實作邏輯。
  /// 此元件不會主動檢查 callback 的業務正確性，只負責在使用者點擊後觸發。
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

  /// 包裝選單點擊事件。
  ///
  /// 先輸出統一格式的除錯訊息，再執行實際 callback，
  /// 方便在互動測試、事件追蹤或問題排查時快速定位使用者操作。
  void _handleMenuTap(String actionName, VoidCallback callback) {
    debugPrint('[ManagementGridMenu] 點擊操作：$actionName');
    callback();
  }

  @override
  Widget build(BuildContext context) {
    // 建立網格式選單的項目資料清單。
    //
    // 每一筆資料包含：
    // - 顯示圖示
    // - 顯示文字
    // - 點擊後要執行的動作
    // - 額外指定的主色（若有）
    final List<_GridItemData> menuItems = [
      // 第一列：圖示／標題編輯與排序調整功能。
      _GridItemData(
        Icons.category,
        '边栏图标',
        () => _handleMenuTap('边栏图标', onEditIcon),
        color: Colors.cyan,
      ),
      _GridItemData(
        Icons.title,
        '边栏标题',
        () => _handleMenuTap('边栏标题', onEditTitle),
        color: Colors.cyan,
      ),
      _GridItemData(
        Icons.arrow_upward,
        '上移',
        () => _handleMenuTap('上移', onMoveUp),
        color: Colors.green,
      ),
      _GridItemData(
        Icons.arrow_downward,
        '下移',
        () => _handleMenuTap('下移', onMoveDown),
        color: Colors.green,
      ),

      // 第二列：內容型態與顏色設定功能。
      _GridItemData(
        Icons.text_fields,
        '设为文字',
        () => _handleMenuTap('设为文字', onSetText),
        color: Colors.orange,
      ),
      _GridItemData(
        Icons.image,
        '设为图片',
        () => _handleMenuTap('设为图片', onSetImage),
        color: Colors.orange,
      ),
      _GridItemData(
        Icons.color_lens,
        '文字颜色',
        () => _handleMenuTap('文字颜色', onSetTextColor),
        color: Colors.pinkAccent,
      ),
      _GridItemData(
        Icons.format_color_fill,
        '背景颜色',
        () => _handleMenuTap('背景颜色', onSetBgColor),
        color: Colors.pinkAccent,
      ),

      // 第三列：項目管理與系統設定功能。
      _GridItemData(
        Icons.add_to_photos,
        '新增屏幕',
        () => _handleMenuTap('新增屏幕', onAdd),
        color: Colors.blue,
      ), // 以藍色突顯新增操作，便於使用者快速辨識。
      _GridItemData(
        Icons.content_copy,
        '复制屏幕',
        () => _handleMenuTap('复制屏幕', onCopy),
        color: Colors.blue,
      ),
      _GridItemData(
        Icons.delete_forever,
        '删除屏幕',
        () => _handleMenuTap('删除屏幕', onDelete),
        color: Colors.red,
      ), // 以紅色突顯刪除操作，提醒此操作具有破壞性。
      _GridItemData(
        Icons.settings, // 設定功能使用齒輪圖示，符合常見介面慣例。
        '应用设置',
        () => _handleMenuTap('应用设置', onOpenSettings),
        color: Colors.grey,
      ),
    ];

    return SafeArea(
      // 使用 SafeArea 避免內容被瀏海、狀態列或手勢區域遮住。
      child: Center(
        // 將內容置中，讓大尺寸裝置上的視覺焦點更集中。
        child: ConstrainedBox(
          // 限制最大寬度，避免在平板或桌面寬螢幕上過度延展。
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            // 目前未額外保留外距，保留結構方便日後調整版面。
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
              // 交由外部版面控制滾動，因此此處以內容高度自適應。
              shrinkWrap: true,

              // 停用 GridView 自身捲動，避免與外層可捲動元件衝突。
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                // 固定每列顯示四個項目，維持一致的管理面板密度。
                crossAxisCount: 4,

                // 控制列與列之間的垂直間距。
                mainAxisSpacing: 20,

                // 控制欄與欄之間的水平間距。
                crossAxisSpacing: 10,

                // 固定每個網格項目的主軸高度，讓圖示與文字排列一致。
                mainAxisExtent: 80,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final theme = Theme.of(context);

                // 優先使用項目自訂顏色，若未指定則退回主題的 onSurface 色彩，
                // 以確保在不同主題模式下仍有良好的可讀性。
                final Color activeColor =
                    item.color ?? theme.colorScheme.onSurface;

                return InkWell(
                  // 點擊時直接觸發對應操作。
                  onTap: item.onTap,

                  // 設定點擊波紋的圓角範圍，與整體視覺風格保持一致。
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    // 讓圖示與文字在格子中垂直置中。
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // 提供圖示外圍留白，避免圖示過度貼近背景。
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // 以主色的低透明度建立圓形底色，提升辨識度又不會過重。
                          color: activeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,

                          // 若有自訂色彩則使用該色；實務上目前皆有指定。
                          color: item.color,
                          size: 25,
                        ), // 顯示功能圖示。
                      ),

                      // 圖示與文字之間保留固定距離，維持閱讀節奏。
                      const SizedBox(height: 10),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // 管理面板項目較多，故採較精簡字級。
                          fontSize: 12,

                          // 有指定功能色彩的項目使用粗體，強化操作辨識度。
                          fontWeight: item.color != null
                              ? FontWeight.bold
                              : FontWeight.normal,

                          // 文字顏色與圖示主色一致，建立視覺對應。
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
/// 用來封裝每一個操作按鈕所需的顯示與互動資訊，包含：
/// - 圖示
/// - 顯示文字
/// - 點擊事件
/// - 可選的顏色設定
///
/// 透過這個資料模型，可將 UI 呈現與資料定義分離，
/// 讓選單內容更容易維護、擴充與重用。
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
  ///
  /// [icon] 為顯示圖示。
  /// [label] 為顯示文字。
  /// [onTap] 為點擊時要執行的事件。
  /// [color] 為此項目的主要顯示顏色，可省略。
  _GridItemData(this.icon, this.label, this.onTap, {this.color});
}
