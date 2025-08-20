import 'package:flutter/material.dart';
import 'home_controller.dart';
import 'home_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    _controller.dispose();
    super.dispose();
  }

  // --- 核心交互：处理导航点击 ---
  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      _showManagementMenu(context);
    } else {
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _controller.currentItem;

    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isPortrait = orientation == Orientation.portrait;

        return Scaffold(
          backgroundColor: item.backgroundColor,
          // 横屏模式：显示底部的滚动导航
          bottomNavigationBar: isPortrait ? null : _buildBottomNav(item),
          body: Stack(
            children: [
              // 层 1：触控翻页背景
              _buildTouchLayer(isPortrait, item),
              // 层 2：内容区域 (竖屏含侧边栏)
              isPortrait ? _buildPortraitLayout(item) : _buildDisplayArea(item),
            ],
          ),
        );
      },
    );
  }

  // --- 1. 横屏：水平滚动底栏 ---
  Widget _buildBottomNav(HomeItem item) {
    return Container(
      color: item.backgroundColor,
      height: 85, // 略微增加高度以容纳文字和间距
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List.generate(_controller.items.length, (index) {
            final e = _controller.items[index];
            final bool isSelected = _controller.currentIndex == index;

            return InkWell(
              onTap: () => _onNavTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.textColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(e.icon, color: item.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.title,
                      style: TextStyle(
                        color: isSelected
                            ? item.textColor
                            : item.textColor.withValues(alpha: 0.5),
                        fontSize: 12,
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

  // --- 2. 竖屏：垂直滚动侧栏 ---
  Widget _buildPortraitLayout(HomeItem item) {
    final Widget textWidget = Expanded(child: _buildDisplayArea(item));

    // 使用 SingleChildScrollView 包裹 NavigationRail 以实现滚动
    final Widget navWidget = Container(
      color: item.backgroundColor,
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: NavigationRail(
            backgroundColor: Colors.transparent, // 背景由外层 Container 提供
            selectedIndex: _controller.currentIndex,
            onDestinationSelected: _onNavTap,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(color: item.textColor),
            selectedLabelTextStyle: TextStyle(
              color: item.textColor,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme: IconThemeData(
              color: item.textColor.withValues(alpha: 0.5),
            ),
            unselectedLabelTextStyle: TextStyle(
              color: item.textColor.withValues(alpha: 0.5),
            ),
            destinations: _controller.items
                .map(
                  (e) => NavigationRailDestination(
                    icon: Icon(e.icon),
                    label: Text(e.title),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    return Row(
      children: _controller.currentSide == NavSide.left
          ? [navWidget, textWidget]
          : [textWidget, navWidget],
    );
  }

  // --- 3. 内容显示逻辑 (图片 vs 文字) ---
  Widget _buildDisplayArea(HomeItem item) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final String? path = item.backgroundImagePath;
          final String content = item.content;

          bool shouldShowImage =
              (path != null && path.isNotEmpty) ||
              (path == '' && content.isEmpty);

          if (shouldShowImage) {
            final String finalPath = (path == null || path.isEmpty)
                ? 'assets/default.png'
                : path;
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              alignment: Alignment.center,
              child: Image.asset(finalPath, fit: BoxFit.contain),
            );
          }

          final TextStyle baseStyle = TextStyle(
            height: 1.1,
            color: item.textColor,
          );

          final tp = TextPainter(
            text: TextSpan(
              text: content,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          double scale =
              (constraints.maxWidth / tp.width) <
                  (constraints.maxHeight / tp.height)
              ? (constraints.maxWidth / tp.width)
              : (constraints.maxHeight / tp.height);

          return Center(
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: baseStyle.copyWith(fontSize: (100 * scale) * 0.85),
            ),
          );
        },
      ),
    );
  }

  // --- 4. 触控层 (水波纹反馈) ---
  Widget _buildTouchLayer(bool isPortrait, HomeItem item) {
    final Color splash = item.textColor.withValues(alpha: 0.1);
    final Color highlight = item.textColor.withValues(alpha: 0.05);

    return Material(
      color: Colors.transparent,
      child: isPortrait
          ? Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _controller.nextItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _controller.previousItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _controller.nextItem,
                    splashColor: splash,
                    highlightColor: highlight,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
    );
  }

  // --- 5. 管理菜单与删除确认 (此处逻辑同上文，已含 {} 修复) ---
  // --- 弹出管理菜单 (使用系统默认配色) ---
  void _showManagementMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // 移除 backgroundColor: item.backgroundColor，回归系统默认
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit), // 移除自定义颜色
                title: const Text('编辑'),
                onTap: () {
                  Navigator.pop(context);
                  // 待实现编辑逻辑
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('新增'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.addItem();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ), // 删除通常保留红色警告
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 确认删除对话框 (使用系统默认配色) ---
  void _confirmDelete(BuildContext context) {
    if (_controller.items.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('不可删除最后一项')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // 移除所有自定义 Style，完全交给系统主题处理
        title: const Text('确认删除'),
        content: const Text('确定要删除当前这一项吗？操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteCurrentItem();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
