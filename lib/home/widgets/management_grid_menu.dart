import 'package:flutter/material.dart';

/// 管理功能的格子選單 Widget
///
/// 這個 Widget 提供一個網格狀的操作選單，可以針對項目進行新增、刪除、上下移動、
/// 修改標題、修改圖示、設定文字或圖片、文字顏色與背景顏色等操作。
/// 適合在台灣商業或管理應用中，快速提供直覺式操作入口。
class ManagementGridMenu extends StatelessWidget {
  /// 點擊「新增項」的回調
  final VoidCallback onAdd;

  /// 點擊「刪除項」的回調
  final VoidCallback onDelete;

  /// 點擊「上移」的回調
  final VoidCallback onMoveUp;

  /// 點擊「下移」的回調
  final VoidCallback onMoveDown;

  /// 點擊「改標題」的回調
  final VoidCallback onEditTitle;

  /// 點擊「改圖示」的回調
  final VoidCallback onEditIcon;

  /// 點擊「設為文字」的回調
  final VoidCallback onSetText;

  /// 點擊「設為圖片」的回調
  final VoidCallback onSetImage;

  /// 點擊「文字顏色」的回調
  final VoidCallback onSetTextColor;

  /// 點擊「背景顏色」的回調
  final VoidCallback onSetBgColor;

  /// 點擊「複製項」的回調
  final VoidCallback onCopy;

  /// 建構子，必須提供所有操作的回調函式
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
  });

  @override
  Widget build(BuildContext context) {
    // 建立格子選單資料列表
    final List<_GridItemData> menuItems = [
      // 第一行功能項目
      _GridItemData(Icons.category, '边栏图标', onEditIcon, color: Colors.cyan),
      _GridItemData(Icons.title, '边栏标题', onEditTitle, color: Colors.cyan),
      _GridItemData(Icons.arrow_upward, '上移', onMoveUp, color: Colors.green),
      _GridItemData(
        Icons.arrow_downward,
        '下移',
        onMoveDown,
        color: Colors.green,
      ),
      // 第二行功能項目
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
      // 第三行功能項目
      _GridItemData(
        Icons.add_to_photos,
        '新增项',
        onAdd,
        color: Colors.blue,
      ), // 藍色凸顯新增
      _GridItemData(Icons.content_copy, '复制项', onCopy, color: Colors.blue),
      _GridItemData(
        Icons.delete_forever,
        '删除项',
        onDelete,
        color: Colors.red,
      ), // 紅色凸顯刪除
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20), // 上下左右間距
        child: GridView.builder(
          shrinkWrap: true, // 根據內容收縮高度
          physics: const NeverScrollableScrollPhysics(), // 禁止滾動
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 每行四個格子
            mainAxisSpacing: 10, // 行間距
            crossAxisSpacing: 10, // 列間距
            childAspectRatio: 0.8, // 格子高寬比，留文字空間
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final theme = Theme.of(context);
            // 如果未指定顏色，使用主題顏色
            final Color activeColor = item.color ?? theme.colorScheme.onSurface;

            return InkWell(
              onTap: item.onTap, // 點擊事件
              borderRadius: BorderRadius.circular(12), // 圓角觸控效果
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 圓形圖示容器
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1), // 淡色背景
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(height: 6), // 圖示與文字間距
                  // 功能文字標籤
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: item.color != null
                          ? FontWeight.bold
                          : FontWeight.normal, // 若有顏色使用粗體
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 格子選單單項資料模型
///
/// 包含圖示、文字標籤、點擊事件以及可選的顏色
class _GridItemData {
  /// 圖示
  final IconData icon;

  /// 文字標籤
  final String label;

  /// 點擊事件回調
  final VoidCallback onTap;

  /// 圖示與文字顏色（可選）
  final Color? color;

  /// 建構子
  _GridItemData(this.icon, this.label, this.onTap, {this.color});
}
