import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_controller.dart';

/// 設定頁面。
///
/// 用於顯示與操作應用程式的各項設定，包含翻頁互動、資料管理與版本資訊。
class SettingsView extends StatefulWidget {
  /// 首頁控制器。
  ///
  /// 負責管理設定狀態與資料清除等邏輯。
  final HomeController controller;

  /// 建立設定頁面。
  const SettingsView({super.key, required this.controller});

  /// 建立 [SettingsView] 對應的狀態物件。
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

/// [SettingsView] 的狀態類別。
class _SettingsViewState extends State<SettingsView> {
  /// 切換是否啟用半屏點擊翻頁。
  ///
  /// 變更設定後同步通知控制器，並在元件仍掛載時重新整理畫面。
  void toggleSideTap(bool val) {
    debugPrint('[_SettingsViewState] 切換點擊半屏翻頁：$val');
    widget.controller.toggleSideTap(val);
    if (mounted) {
      setState(() {});
    }
  }

  /// 切換是否啟用音量鍵翻頁。
  ///
  /// 變更設定後同步通知控制器，並在元件仍掛載時重新整理畫面。
  void toggleVolumeKeys(bool val) {
    debugPrint('[_SettingsViewState] 切換音量鍵翻頁：$val');
    widget.controller.toggleVolumeKeys(val);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 僅在非 Web 且平台為 Android / iOS 時，才支援實體音量鍵翻頁。
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
            // 直接讀取控制器中的目前狀態。
            value: widget.controller.useSideTap,
            onChanged: (val) => toggleSideTap(val),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.volume_up,
              // 平台不支援時，將圖示顯示為灰色以降低可操作感。
              color: isVolumeSupported ? null : Colors.grey,
            ),
            title: const Text('音量键翻页'),
            subtitle: Text(
              isVolumeSupported ? '使用物理音量按键切换项目' : '当前平台不支持物理音量键翻页',
              // 平台不支援時，提示文字同步顯示為灰色。
              style: TextStyle(color: isVolumeSupported ? null : Colors.grey),
            ),
            value: widget.controller.useVolumeKeys,
            // 若平台不支援，將 onChanged 設為 null 以停用開關。
            onChanged: isVolumeSupported
                ? (val) => toggleVolumeKeys(val)
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
            // 功能尚未開放，先以停用狀態呈現。
            enabled: false,
          ),
        ],
      ),
    );
  }

  /// 顯示重設確認對話框。
  ///
  /// 使用者確認後會清除所有資料，並以 SnackBar 提示操作結果。
  void _confirmReset(BuildContext context) {
    debugPrint('[_SettingsViewState] 顯示重設確認對話框');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有设置'),
        content: const Text('这将清除所有保存的内容且无法恢复。确定要重置吗？'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 取消重設');
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 確認重設，開始清除資料');
              widget.controller.clearAllData();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('清空所有设置'),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              debugPrint('[_SettingsViewState] 資料已清除並顯示提示訊息');
            },
            child: const Text('确定重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 設定區塊標題元件。
///
/// 用於在設定頁中區分不同功能群組。
class _SettingsSectionTitle extends StatelessWidget {
  /// 區塊標題文字。
  final String title;

  /// 建立設定區塊標題。
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 提供與清單項目一致的左右留白，以及區塊上下間距。
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
