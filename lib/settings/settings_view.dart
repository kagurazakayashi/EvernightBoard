import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_controller.dart';

class SettingsView extends StatelessWidget {
  final HomeController controller;

  const SettingsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isVolumeSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    return Scaffold(
      appBar: AppBar(title: const Text('应用设置'), centerTitle: true),

      body: ListView(
        children: [
          const _SettingsSectionTitle(title: '翻页交互'),
          SwitchListTile(
            secondary: const Icon(Icons.touch_app),
            title: const Text('点击半屏翻页'),
            subtitle: const Text('横屏时按左右半屏、竖屏时按上下半屏。'),
            value: controller.useSideTap, // 现在这里会随 notifyListeners 更新
            onChanged: (val) => controller.toggleSideTap(val),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.volume_up,
              color: isVolumeSupported ? null : Colors.grey, // 不支持时图标变灰
            ),
            title: const Text('音量键翻页'),
            // 如果不支持，显示提示文字
            subtitle: Text(
              isVolumeSupported ? '使用物理音量按键切换项目' : '当前平台不支持物理音量键翻页',
              style: TextStyle(color: isVolumeSupported ? null : Colors.grey),
            ),
            value: controller.useVolumeKeys,
            onChanged: isVolumeSupported
                ? (val) => controller.toggleVolumeKeys(val)
                : null,
          ),

          const Divider(),
          const _SettingsSectionTitle(title: '数据管理'),

          ListTile(
            leading: const Icon(Icons.restore, color: Colors.redAccent),
            title: const Text('恢复出厂设置'),
            subtitle: const Text('清除所有保存的项目、颜色和图片配置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _confirmReset(context),
          ),

          const Divider(),

          const _SettingsSectionTitle(title: '关于'),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
            title: const Text('版本信息'),
            subtitle: const Text('v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.import_export, color: Colors.blueGrey),
            title: const Text('数据导出'),
            enabled: false,
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有设置'),
        content: const Text('这将清除所有保存的内容且无法恢复。确定要重置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllData();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('清空所有设置'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('确定重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
