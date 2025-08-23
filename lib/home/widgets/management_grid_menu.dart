import 'package:flutter/material.dart';

/// 管理功能的格子選單 Widget
///
/// 這個 Widget 提供一個網格狀的操作選單，可以針對項目進行新增、刪除、上下移動、
/// 修改標題、修改圖示、設定文字或圖片、文字顏色與背景顏色等操作。
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

  final VoidCallback onCopy;

  /// 建構子，必須提供所有操作的回調函式
  const ManagementGridMenu({
    super.key,
    required this.onAdd,
    required this.onCopy,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEditTitle,
    required this.onEditIcon,
    required this.onSetText,
    required this.onSetImage,
    required this.onSetTextColor,
    required this.onSetBgColor,
  });

  @override
  Widget build(BuildContext context) {
    // 建立格子選單資料列表
    final List<_GridItemData> menuItems = [
      // 第一行
      _GridItemData(Icons.category, '边栏图标', onEditIcon),
      _GridItemData(Icons.title, '边栏标题', onEditTitle),
      _GridItemData(Icons.text_fields, '设为文字', onSetText),
      _GridItemData(Icons.image, '设为图片', onSetImage),
      // 第二行
      _GridItemData(Icons.color_lens, '文字颜色', onSetTextColor),
      _GridItemData(Icons.format_color_fill, '背景颜色', onSetBgColor),
      _GridItemData(Icons.arrow_upward, '上移', onMoveUp),
      _GridItemData(Icons.arrow_downward, '下移', onMoveDown),
      // 第三行
      _GridItemData(Icons.add_to_photos, '新增项', onAdd, color: Colors.blue),
      _GridItemData(Icons.content_copy, '复制项', onCopy),
      _GridItemData(Icons.delete_forever, '删除项', onDelete, color: Colors.red),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: GridView.builder(
          // 自動調整高度，不可滾動
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 一行四個格子
            mainAxisSpacing: 10, // 主軸間距
            crossAxisSpacing: 10, // 交叉軸間距
            childAspectRatio: 0.85, // 長寬比例
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              onTap: item.onTap, // 點擊事件
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 圓形圖示容器
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (item.color ?? Theme.of(context).colorScheme.primary)
                              .withValues(alpha: 0.1), // 背景色加透明
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(height: 8), // 圖示與文字間距
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          item.color ?? Theme.of(context).colorScheme.onSurface,
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

  /// 點擊事件
  final VoidCallback onTap;

  /// 圖示與文字顏色（可選）
  final Color? color;

  /// 建構子
  _GridItemData(this.icon, this.label, this.onTap, {this.color});
}
