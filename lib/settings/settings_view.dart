import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:evernight_board/global.dart';
import 'readme_view.dart';

/// 設定頁面視圖元件。
///
/// 負責呈現應用程式的全域配置選項，包括互動行為、資料備份、
/// 介面佈局調整以及關於資訊。
class SettingsView extends StatefulWidget {
  /// 關聯的首頁控制器，用於存取與修改全域狀態。
  final HomeController controller;

  /// 建立設定頁面實例。
  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

/// [SettingsView] 的狀態管理類別。
///
/// 處理設定頁面的生命週期、退出動畫以及與 [HomeController] 的資料互動。
class _SettingsViewState extends State<SettingsView>
    with TickerProviderStateMixin {
  /// 控制退出程式時的黑屏淡出動畫控制器。
  late AnimationController _exitAnimationController;

  /// 處理背景變黑效果的數值動畫。
  late Animation<double> _blackOutAnimation;

  /// 標記當前是否處於執行退出程序的狀態。
  bool _isExiting = false;

  /// 儲存應用程式版本號。
  String _version = '0.0.0';

  /// 儲存應用程式建置序號。
  String _buildNumber = '0';

  // 渠道配置: {"localhost":"appicp","hostname1":"webicp","hostname2":"webicp"}
  static const Map<String, String> _icpConfig = {'localhost': ''};

  @override
  void initState() {
    super.initState();
    debugPrint('[_SettingsViewState] 正在初始化設定頁面狀態...');
    _initPackageInfo();

    // 初始化退出動畫設定：時長 600 毫秒
    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _blackOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 監聽動畫狀態，當全黑動畫完成後，強制結束應用程式進程
    _exitAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('[_SettingsViewState] 動畫執行完畢，正在結束應用程式。');
        exit(0);
      }
    });
  }

  /// 從平台層獲取套件版本資訊。
  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
        debugPrint('[_SettingsViewState] 成功載入版本資訊: $_version+$_buildNumber');
      }
    } catch (e) {
      debugPrint('[_SettingsViewState] 獲取套件資訊失敗: $e');
    }
  }

  /// 切換側邊觸控翻頁功能的開關狀態。
  ///
  /// [val] 新的布林值狀態。
  void toggleSideTap(bool val) {
    debugPrint('[_SettingsViewState] 變更點擊半屏翻頁狀態為: $val');
    widget.controller.toggleSideTap(val);
    if (mounted) {
      setState(() {});
    }
  }

  /// 切換實體音量鍵翻頁功能的開關狀態。
  ///
  /// [val] 新的布林值狀態。
  void toggleVolumeKeys(bool val) {
    debugPrint('[_SettingsViewState] 變更音量鍵翻頁狀態為: $val');
    widget.controller.toggleVolumeKeys(val);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 檢查目前運行平台是否具備物理音量鍵支援（排除 Web 並限制在 iOS/Android）
    final bool isVolumeSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    bool isEnglish = t.language != "Language";
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(t.appsettings), centerTitle: true),
          body: ListView(
            children: [
              _SettingsSectionTitle(title: t.language),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(t.language),
                subtitle: isEnglish ? const Text("Language") : null,
                trailing: DropdownButton<String>(
                  value: _getLocaleKey(widget.controller.appLocale),
                  onChanged: (val) {
                    if (val == 'auto') {
                      widget.controller.changeLocale(null);
                    } else if (val == 'zh_Hant') {
                      widget.controller.changeLocale(
                        Locale.fromSubtags(
                          languageCode: 'zh',
                          scriptCode: 'Hant',
                        ),
                      );
                    } else if (val == 'zh') {
                      widget.controller.changeLocale(
                        Locale.fromSubtags(
                          languageCode: 'zh',
                          scriptCode: 'Hans',
                        ),
                      );
                    } else {
                      widget.controller.changeLocale(Locale(val!));
                    }
                    if (mounted) setState(() {});
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'auto',
                      child: Text('${t.auto} (Auto)'),
                    ),
                    const DropdownMenuItem(value: 'zh', child: Text('简体中文')),
                    const DropdownMenuItem(
                      value: 'zh_Hant',
                      child: Text('繁體中文'),
                    ),
                    const DropdownMenuItem(value: 'en', child: Text('English')),
                    const DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  ],
                ),
              ),
              const Divider(),
              _SettingsSectionTitle(title: t.pageturning),
              SwitchListTile(
                secondary: const Icon(Icons.touch_app),
                title: Text(t.halfscreenturnpages1),
                subtitle: Text(t.halfscreenturnpages2),
                value: widget.controller.useSideTap,
                onChanged: (val) => toggleSideTap(val),
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.volume_up,
                  color: isVolumeSupported ? null : Colors.grey,
                ),
                title: Text(t.volumeturnpages1),
                subtitle: Text(
                  isVolumeSupported ? t.volumeturnpages2 : t.volumeturnpages3,
                  style: TextStyle(
                    color: isVolumeSupported ? null : Colors.grey,
                  ),
                ),
                value: widget.controller.useVolumeKeys,
                onChanged: isVolumeSupported
                    ? (val) => toggleVolumeKeys(val)
                    : null,
              ),
              const Divider(),
              _SettingsSectionTitle(title: t.navbarlocation),
              ListTile(
                leading: const Icon(Icons.stay_current_landscape),
                title: Text(t.currlandscape),
                trailing: DropdownButton<LandscapeNavPosition>(
                  value: widget.controller.landscapeNavPosition,
                  onChanged: (val) {
                    if (val != null) {
                      debugPrint('[_SettingsViewState] 變更橫屏導航位置為: $val');
                      widget.controller.setLandscapeNavPosition(val);
                    }
                    if (mounted) setState(() {});
                  },
                  items: [
                    DropdownMenuItem(
                      value: LandscapeNavPosition.bottom,
                      child: Text(t.alwaysbottom),
                    ),
                    DropdownMenuItem(
                      value: LandscapeNavPosition.left,
                      child: Text(t.alwaysleft),
                    ),
                    DropdownMenuItem(
                      value: LandscapeNavPosition.right,
                      child: Text(t.alwaysright),
                    ),
                    DropdownMenuItem(
                      value: LandscapeNavPosition.top,
                      child: Text(t.alwaystop),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.stay_current_portrait),
                title: Text(t.currportrait),
                trailing: DropdownButton<PortraitNavPosition>(
                  value: widget.controller.portraitNavPosition,
                  onChanged: (val) {
                    if (val != null) {
                      debugPrint('[_SettingsViewState] 變更豎屏導航位置為: $val');
                      widget.controller.setPortraitNavPosition(val);
                    }
                    if (mounted) setState(() {});
                  },
                  items: [
                    DropdownMenuItem(
                      value: PortraitNavPosition.auto,
                      child: Text(t.navbarlocationauto),
                    ),
                    DropdownMenuItem(
                      value: PortraitNavPosition.bottom,
                      child: Text(t.alwaysbottom),
                    ),
                    DropdownMenuItem(
                      value: PortraitNavPosition.left,
                      child: Text(t.alwaysleft),
                    ),
                    DropdownMenuItem(
                      value: PortraitNavPosition.right,
                      child: Text(t.alwaysright),
                    ),
                    DropdownMenuItem(
                      value: PortraitNavPosition.top,
                      child: Text(t.alwaystop),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SettingsSectionTitle(title: t.datamanagement),
              ListTile(
                leading: const Icon(
                  Icons.file_upload,
                  color: Colors.blueAccent,
                ),
                title: Text(t.exportscreenconf1),
                subtitle: Text(t.exportscreenconf2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint('[_SettingsViewState] 使用者觸發資料匯出');
                  widget.controller.exportData(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.green),
                title: Text(t.importscreenconf1),
                subtitle: Text(t.importscreenconf2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmImport(context),
              ),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.redAccent),
                title: Text(t.allclear1),
                subtitle: Text(t.allclear2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmReset(context),
              ),
              const Divider(),
              _SettingsSectionTitle(title: t.helpinfo),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(t.help),
                subtitle: Text(t.help),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReadmeView()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(t.about),
                subtitle: Text('${t.version}: $_version ($_buildNumber)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _about(context),
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.power_settings_new),
                  title: Text(t.exit),
                  subtitle: Text(t.exit2),
                  onTap: _isExiting ? null : () => _performExitWithAnimation(),
                ),
            ],
          ),
        ),
        // 遮罩層：用於顯示退出時的黑屏動畫
        IgnorePointer(
          ignoring: !_isExiting,
          child: FadeTransition(
            opacity: _blackOutAnimation,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  /// 顯示匯入組態確認對話框。
  ///
  /// 此操作具有破壞性，會覆蓋現有資料，故需進行二次確認。
  void _confirmImport(BuildContext context) {
    debugPrint('[_SettingsViewState] 顯示匯入確認彈窗');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.importscreenconf1),
        content: Text(t.importscreenconf3),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者取消匯入');
              Navigator.pop(context);
            },
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者確認匯入，呼叫控制器邏輯');
              Navigator.pop(context);
              widget.controller.importData(context);
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  String _getLocaleKey(Locale? locale) {
    if (locale == null) return 'auto';
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return 'zh_Hant';
    }
    return locale.languageCode;
  }

  String _icp(Locale? locale) {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      return "";
    }
    bool sysischs = false;
    Locale systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'zh') {
      if (systemLocale.scriptCode == 'Hans' ||
          systemLocale.countryCode == 'CN') {
        sysischs = true;
      }
    }
    bool localechs = false;
    if (locale != null) {
      if (locale.languageCode == 'zh') {
        if (locale.scriptCode == 'Hans' || locale.countryCode == 'CN') {
          localechs = true;
        }
      }
    }
    if (sysischs == localechs) {
      if (kIsWeb) {
        String currentHost = Uri.base.host;
        for (var entry in _icpConfig.entries) {
          String domain = entry.key.toLowerCase();
          // 判斷邏輯：完全相等 或 以 ".domain" 結尾
          if (currentHost == domain || currentHost.endsWith('.$domain')) {
            return "\n${entry.value}";
          }
        }
      } else {
        return _icpConfig['localhost']!;
      }
    }
    return "";
  }

  /// 顯示還原出廠設定確認對話框。
  ///
  /// 執行後將清除所有本地儲存的持久化資料。
  void _confirmReset(BuildContext context) {
    debugPrint('[_SettingsViewState] 顯示還原重設確認彈窗');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.allclear1),
        content: Text(t.allclear3),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 取消重設');
              Navigator.pop(context);
            },
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 執行全域資料清空程序');
              widget.controller.clearAllData(context);
              Navigator.pop(context);
            },
            child: Text(t.ok, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 顯示「關於」資訊對話框。
  ///
  /// 展示應用程式名稱、圖示、版本資訊、法律聲明以及開發者連結。
  void _about(BuildContext context) {
    String icp = _icp(widget.controller.appLocale);
    debugPrint('[_SettingsViewState] 開啟「關於」資訊視窗');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, mSetState) {
            return AboutDialog(
              applicationName: t.appTitle,
              applicationIcon: SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(
                  'assets/appicon/adaptive_icon_foreground.png',
                  fit: BoxFit.contain,
                ),
              ),
              applicationVersion: "$_version+$_buildNumber",
              applicationLegalese:
                  "is licensed under Mulan PSL v2.\n© 2026 KagurazakaYashi(KagurazakaMiyabi)$icp\n",
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => jumpUrL(
                        path:
                            "/kagurazakayashi/EvernightBoard/blob/main/${t.readme}",
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          t.help,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => jumpUrL(
                        path: "/kagurazakayashi/EvernightBoard/issues",
                      ),
                      child: Text(
                        t.issues,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          jumpUrL(path: "/kagurazakayashi/EvernightBoard"),
                      child: Text(
                        t.srccode,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(" \n${t.privacylicense}"),
              ],
            );
          },
        );
      },
    );
  }

  /// 啟動退出動畫程序，並在完成後徹底關閉應用程式。
  void _performExitWithAnimation() {
    debugPrint('[_SettingsViewState] 執行退出動畫，準備釋放記憶體');
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _exitAnimationController.forward();
  }
}

/// 開啟外部瀏覽器跳轉至指定的 URL。
///
/// [scheme] 協定類型，預設為 https。
/// [host] 域名，預設為 github.com。
/// [path] 資源路徑。
Future jumpUrL({
  String scheme = "https",
  String host = "github.com",
  String path = "",
}) async {
  if (host == "") {
    debugPrint('[_SettingsViewState] 跳轉失敗：無效的 Host 內容');
    return;
  }
  final url = Uri(scheme: scheme, host: host, path: path);
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('[_SettingsViewState] 無法呼叫外部應用程式開啟 URL: $url');
    }
  } catch (e) {
    debugPrint('[_SettingsViewState] 執行 jumpUrL 時發生例外: $e');
  }
}

/// 設定頁面專用的區塊標題元件。
///
/// 負責呈現具有一致間距與主題色彩的群組化標題。
class _SettingsSectionTitle extends StatelessWidget {
  /// 顯示的標題文字。
  final String title;

  /// 建立區塊標題。
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 確保標題與清單項目對齊，並提供足夠的垂直間距
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
