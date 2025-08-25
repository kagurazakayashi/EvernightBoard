import 'package:flutter/material.dart';

/// IconSelectorPage
///
/// 這個頁面提供一個圖標選擇器，使用者可以透過搜尋或瀏覽圖示列表來選擇想要的圖標。
/// 選擇圖標後會透過 Navigator.pop 回傳所選的 IconData。
class IconSelectorPage extends StatefulWidget {
  const IconSelectorPage({super.key});

  @override
  State<IconSelectorPage> createState() => _IconSelectorPageState();
}

class _IconSelectorPageState extends State<IconSelectorPage> {
  /// 圖示對照表，key 為圖示名稱，value 為對應的 IconData
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

  /// 圖示名稱列表，方便搜尋與排序
  late List<String> _keys;

  /// 搜尋框文字
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 初始化圖示名稱列表
    _keys = _iconMap.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    // 過濾出符合搜尋條件的圖示名稱
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
              hintText: '搜索图标 (例如: home, edit...)',
              onChanged: (value) => setState(() => _searchQuery = value),
              leading: const Icon(Icons.search),
              elevation: WidgetStateProperty.all(1),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        // 使用固定列數的網格布局
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: filteredKeys.length,
        itemBuilder: (context, index) {
          final name = filteredKeys[index];
          final icon = _iconMap[name]!; // 確保一定有對應 IconData

          return Column(
            children: [
              Expanded(
                child: InkWell(
                  // 點擊圖示時回傳 IconData
                  onTap: () => Navigator.pop(context, icon),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // 背景色使用表面容器最高層並調整透明度
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
              // 顯示圖示名稱，超出以省略號表示
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
