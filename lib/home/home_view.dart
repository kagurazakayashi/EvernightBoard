import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'home_controller.dart';
import 'widgets/display_area.dart';
import 'widgets/touch_layer.dart';
import 'widgets/scrollable_nav_bar.dart';
import 'widgets/scrollable_side_rail.dart';
import 'widgets/management_grid_menu.dart';
import 'widgets/edit_text_dialog.dart';
import 'widgets/color_picker_handler.dart';
import '../settings/settings_view.dart';

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
    _controller.addListener(_updateUI);
  }

  // 修复：setState 必须接收一个闭包，且 if 语句不能直接接在 => 后面
  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUI); // 养成好习惯，销毁时移除监听
    _controller.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _controller.currentIndex) {
      _showManagementMenu();
    } else {
      _controller.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isPortrait = size.height > size.width;
    final item = _controller.currentItem;
    final theme = Theme.of(context);
    final Color bgColor = item.backgroundColor ?? theme.colorScheme.surface;
    final Color themeColor = item.textColor ?? theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentItem = _controller.currentItem;

        // 核心显示区域与触控层组合
        Widget mainContent = Stack(
          children: [
            DisplayArea(item: currentItem),
            TouchLayer(
              isPortrait: isPortrait,
              themeColor: themeColor,
              onPrevious: _controller.useSideTap
                  ? _controller.previousItem
                  : null,
              onNext: _controller.useSideTap ? _controller.nextItem : null,
            ),
          ],
        );

        Widget body;
        if (isPortrait) {
          final nav = ScrollableSideRail(
            items: _controller.items,
            currentIndex: _controller.currentIndex,
            onTap: _onNavTap,
          );
          body = Row(
            children: _controller.currentSide == NavSide.left
                ? [nav, Expanded(child: mainContent)]
                : [Expanded(child: mainContent), nav],
          );
        } else {
          body = mainContent;
        }

        return Scaffold(
          backgroundColor: bgColor,
          bottomNavigationBar: isPortrait
              ? null
              : ScrollableNavBar(
                  items: _controller.items,
                  currentIndex: _controller.currentIndex,
                  onTap: _onNavTap,
                ),
          body: body,
        );
      },
    );
  }

  void _showManagementMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ManagementGridMenu(
        onEditIcon: () async {
          Navigator.pop(context);
          final IconPickerIcon? selectedIcon = await showIconPicker(
            context,
            configuration: const SinglePickerConfiguration(
              iconPackModes: [IconPack.material],
              searchHintText: '搜索图标...',
              title: Text('选择边栏图标'),
            ),
          );
          if (selectedIcon != null) {
            _controller.updateIcon(selectedIcon.data);
          }
        },
        onEditTitle: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: '边栏标题',
              initialValue: _controller.currentItem.title,
              onConfirm: _controller.updateTitle,
            ),
          );
        },
        onSetText: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => EditTextDialog(
              title: '全屏文字',
              initialValue: _controller.currentItem.content,
              isMultiline: true,
              onConfirm: _controller.setAsText,
            ),
          );
        },
        onSetImage: () async {
          Navigator.pop(context);
          final Size size = MediaQuery.sizeOf(context);
          await _controller.pickImage(
            size.width > size.height ? size.width : size.height,
          );
        },
        onSetTextColor: () async {
          Navigator.pop(context);
          await ColorPickerHandler.show(
            context: context,
            title: '文字颜色',
            isTextType: true,
            initialColor: _controller.currentItem.textColor,
            otherColor: _controller.currentItem.backgroundColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) => _controller.setTextColor(color),
          );
        },
        onSetBgColor: () async {
          Navigator.pop(context);
          await ColorPickerHandler.show(
            context: context,
            title: '背景颜色',
            isTextType: false,
            initialColor: _controller.currentItem.backgroundColor,
            otherColor: _controller.currentItem.textColor,
            checkSimilarity: _controller.isTooSimilar,
            onColorChanged: (color) => _controller.setBgColor(color),
          );
        },
        onMoveUp: _controller.moveUp,
        onMoveDown: _controller.moveDown,
        onAdd: () {
          Navigator.pop(context);
          _controller.addItem();
        },
        onCopy: () {
          Navigator.pop(context);
          _controller.copyCurrentItem();
        },
        onDelete: () {
          Navigator.pop(context);
          _controller.deleteCurrentItem();
        },
        onOpenSettings: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsView(controller: _controller),
            ),
          );
        },
      ),
    );
  }
}
