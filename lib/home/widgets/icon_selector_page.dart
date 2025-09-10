import 'package:flutter/material.dart';

/// IconSelectorPage
///
/// 提供圖示選擇介面，讓使用者可透過搜尋或瀏覽圖示清單來挑選圖示。
/// 當使用者點選某個圖示後，會使用 `Navigator.pop` 將選取的 `IconData` 回傳給上一頁。
class IconSelectorPage extends StatefulWidget {
  const IconSelectorPage({super.key});

  @override
  State<IconSelectorPage> createState() => _IconSelectorPageState();
}

/// `IconSelectorPage` 的狀態類別。
///
/// 負責管理：
/// - 圖示資料來源
/// - 搜尋關鍵字
/// - 篩選後的顯示結果
class _IconSelectorPageState extends State<IconSelectorPage> {
  /// 圖示名稱與 `IconData` 的對照表。
  ///
  /// - key：圖示識別名稱，供搜尋與畫面顯示使用
  /// - value：實際對應的 Material icon
  final Map<String, IconData> _iconMap = {
    'home': Icons.home,
    'search': Icons.search,
    'settings': Icons.settings,
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'share': Icons.share,
    'send': Icons.send,
    'save': Icons.save,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'thumb_up': Icons.thumb_up,
    'person': Icons.person,
    'group': Icons.group,
    'face': Icons.face,
    'camera': Icons.camera_alt,
    'image': Icons.image,
    'movie': Icons.movie,
    'music': Icons.music_note,
    'play': Icons.play_arrow,
    'pause': Icons.pause,
    'work': Icons.work,
    'school': Icons.school,
    'build': Icons.build,
    'map': Icons.map,
    'explore': Icons.explore,
    'place': Icons.place,
    'alarm': Icons.alarm,
    'event': Icons.event,
    'schedule': Icons.schedule,
    'email': Icons.email,
    'phone': Icons.phone,
    'message': Icons.message,
    'cloud': Icons.cloud,
    'wb_sunny': Icons.wb_sunny,
    'nights_stay': Icons.nights_stay,
    'shopping_cart': Icons.shopping_cart,
    'credit_card': Icons.credit_card,
    'flight': Icons.flight,
    'directions_car': Icons.directions_car,
    'restaurant': Icons.restaurant,
    'coffee': Icons.local_cafe,
    'fitness': Icons.fitness_center,
    'sports_esports': Icons.sports_esports,
    'lightbulb': Icons.lightbulb,
    'brush': Icons.brush,
    'palette': Icons.palette,
    'code': Icons.code,
    'terminal': Icons.terminal,
    'bolt': Icons.bolt,
    'anchor': Icons.anchor,
    'pets': Icons.pets,
    'eco': Icons.eco,
    'category': Icons.category,
    'widgets': Icons.widgets,
    'layers': Icons.layers,
    'visibility': Icons.visibility,
    'lock': Icons.lock,
    'key': Icons.key,
  };

  /// 圖示名稱清單。
  ///
  /// 會在 `initState` 中由 `_iconMap` 的 key 轉換而來，
  /// 方便後續進行搜尋、篩選與清單渲染。
  late List<String> _keys;

  /// 目前搜尋欄位中的文字。
  ///
  /// 預設為空字串，代表顯示全部圖示。
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // 初始化圖示名稱清單，後續搜尋會以這份資料為基礎進行篩選。
    _keys = _iconMap.keys.toList();

    debugPrint('[IconSelectorPage] 已初始化，共載入 ${_keys.length} 個圖示。');
  }

  @override
  Widget build(BuildContext context) {
    // 依目前搜尋關鍵字篩選圖示名稱。
    //
    // 這裡將輸入內容轉為小寫後比對，避免因大小寫不同而影響搜尋結果。
    final filteredKeys = _keys
        .where((k) => k.contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('图标库'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: '搜索图标',
              onChanged: (value) {
                // 更新搜尋條件並重新建構畫面，以即時反映篩選結果。
                setState(() {
                  _searchQuery = value;
                });

                debugPrint(
                  '[IconSelectorPage] 搜尋關鍵字已更新："$value"，目前符合 ${filteredKeys.length} 個圖示。',
                );
              },
              leading: const Icon(Icons.search),
              elevation: WidgetStateProperty.all(1),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),

        // 使用固定欄數的網格版面配置，讓圖示以整齊的矩陣方式顯示。
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: filteredKeys.length,
        itemBuilder: (context, index) {
          // 取得目前格位對應的圖示名稱與圖示資料。
          final name = filteredKeys[index];

          // 此處使用 `!` 是因為 `filteredKeys` 來源即為 `_iconMap` 的 key，
          // 理論上一定能找到對應的 `IconData`。
          final icon = _iconMap[name]!;

          return Column(
            children: [
              Expanded(
                child: InkWell(
                  // 點選圖示後，將所選 `IconData` 回傳給上一頁。
                  onTap: () {
                    debugPrint('[IconSelectorPage] 使用者已選取圖示：$name');
                    Navigator.pop(context, icon);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // 使用主題中的容器色系作為背景，並降低透明度，
                      // 讓圖示卡片在不同主題下都能維持柔和的視覺層次。
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // 顯示圖示名稱。
              // 若文字長度超出可用寬度，則以省略號顯示，避免破版。
              Text(
                name,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
