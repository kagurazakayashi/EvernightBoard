import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:evernight_board/global.dart';
import '../home/home_controller.dart';
import 'readme_view.dart';
import 'settings_widgets.dart';
import 'settings_dialogs_mixin.dart';
import 'package:device_accessibility_info/device_accessibility_info.dart';

/// 設定頁面主視圖元件。
///
/// 此元件負責呈現應用程式的設定介面，包含：
/// - 語言切換
/// - 翻頁行為設定
/// - 導覽列位置設定
/// - 資料匯入／匯出／重設
/// - 說明與關於資訊
/// - 應用程式退出流程
class SettingsView extends StatefulWidget {
  /// 設定頁面所依賴的控制器實例。
  final HomeController controller;

  /// 建立設定頁面主視圖。
  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

/// [SettingsView] 的狀態實作。
///
/// 混入 [TickerProviderStateMixin] 以提供動畫所需的 `vsync`，
/// 並混入 [SettingsDialogsMixin] 以共用各類設定對話框邏輯。
class _SettingsViewState extends State<SettingsView>
    with TickerProviderStateMixin, SettingsDialogsMixin, WidgetsBindingObserver {
  /// 檢測螢幕朗讀模式是否啟用
  ///
  /// 使用 device_accessibility_info 插件檢測輔助功能開關狀態，
  /// 以避免某些定制系統中 MediaQuery 回報不準確的問題。
  bool get _isScreenReaderActive => _screenReaderEnabled;

  /// 控制退出畫面淡出動畫的控制器。
  late AnimationController _exitAnimationController;

  /// 黑幕遮罩透明度動畫，用於退出時的黑屏過場效果。
  late Animation<double> _blackOutAnimation;

  /// 用於延遲檢查無障礙狀態的定時器
  Timer? _accessibilityCheckTimer;

  /// 螢幕朗讀模式是否啟用（由 device_accessibility_info 插件維護）
  bool _screenReaderEnabled = false;

  /// 螢幕朗讀狀態變更的訂閱物件
  StreamSubscription<bool>? _screenReaderSubscription;

  /// 是否已進入退出流程，避免重複觸發退出動畫。
  bool _isExiting = false;

  /// 是否在退出動畫完成後真正結束應用程式。
  ///
  /// 某些流程（例如清除資料後重新初始化）會將此值設為 `false`，
  /// 以避免動畫結束後直接呼叫 `exit(0)`。
  bool _isExit = true;

  /// 應用程式版本號。
  String _version = '0.0.0';

  /// 應用程式建置版本號。
  String _buildNumber = '0';

  @override
  void initState() {
    super.initState();
    debugPrint('[_SettingsViewState] 開始初始化設定頁面狀態');
    _initPackageInfo();

    // 註冊無障礙特性變化監聽器
    WidgetsBinding.instance.addObserver(this);

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

    _exitAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isExit) {
        debugPrint('[_SettingsViewState] 退出動畫完成，準備結束應用程式');
        exit(0);
      }
    });

    // 在下一帧触发一次无障碍状态检查，解决启动时检测不准确的问题
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        debugPrint('[_SettingsViewState] 首帧渲染完成，触发无障碍状态检查');
        // 初始化 device_accessibility_info 插件
        try {
          final plugin = DeviceAccessibilityInfo();
          // 获取当前屏幕朗读状态
          final bool isEnabled = await plugin.isScreenReaderEnabled();
          debugPrint('[_SettingsViewState] 当前屏幕朗读状态: $isEnabled');
          if (mounted) {
            setState(() {
              _screenReaderEnabled = isEnabled;
            });
          }
          // 订阅屏幕朗读状态变化
          _screenReaderSubscription = plugin.screenReaderStatusChanged.listen((bool isEnabled) {
            debugPrint('[_SettingsViewState] 屏幕朗读状态变化: $isEnabled');
            if (mounted) {
              setState(() {
                _screenReaderEnabled = isEnabled;
              });
            }
          });
        } catch (e) {
          debugPrint('[_SettingsViewState] device_accessibility_info 初始化失败: $e');
        }
      }
    });

    // 啟動延遲檢查定時器，解決應用啟動時無障礙狀態可能檢測不準的問題
    _accessibilityCheckTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        debugPrint('[_SettingsViewState] 延遲無障礙狀態檢查定時器觸發，強制重建畫面');
        setState(() {});
      }
    });

    debugPrint('[_SettingsViewState] 設定頁面初始化完成');
  }

  /// 初始化應用程式版本資訊。
  ///
  /// 透過 [PackageInfo.fromPlatform] 讀取目前平台的版本號與建置號，
  /// 並在元件仍掛載於樹上時更新畫面狀態。
  Future<void> _initPackageInfo() async {
    debugPrint('[_SettingsViewState] 開始讀取應用程式版本資訊');
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
        debugPrint(
          '[_SettingsViewState] 版本資訊讀取完成：version=$_version，buildNumber=$_buildNumber',
        );
      }
    } catch (e) {
      debugPrint('[_SettingsViewState] 讀取版本資訊失敗：$e');
    }
  }

  /// 執行帶有過場動畫的退出流程。
  ///
  /// 若目前已在退出中，則直接忽略，避免重複觸發動畫與退出邏輯。
  void _performExitWithAnimation() {
    if (_isExiting) {
      debugPrint('[_SettingsViewState] 退出流程已在執行中，忽略重複觸發');
      return;
    }
    debugPrint('[_SettingsViewState] 開始執行退出動畫流程');
    setState(() => _isExiting = true);
    _exitAnimationController.forward();
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    debugPrint('[_SettingsViewState] 無障礙特性發生變化，重新檢查螢幕朗讀狀態');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 判斷目前平台是否支援實體音量鍵翻頁。
    final bool isVolumeSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    /// 判斷目前平台是否支援重力感測器。
    ///
    /// Web 與桌面平台通常不支援此能力，因此僅在 Android 與 iOS 啟用。
    final bool isSensorSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    /// 判斷目前語言顯示是否需要額外補充英文說明。
    ///
    /// 當目前語系不是英文時，額外顯示 `Language` 以提升辨識度。
    bool isEnglish = t.language != "Language";

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(t.appsettings), centerTitle: true),
          body: ListView(
            children: [
              SettingsSectionTitle(title: t.language),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(t.language),
                subtitle: isEnglish ? const Text("Language") : null,
                trailing: DropdownButton<String>(
                  value: getLocaleKey(widget.controller.appLocale),
                  onChanged: (val) {
                    debugPrint('[_SettingsViewState] 使用者選擇語系值：$val');
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
                    if (mounted) {
                      debugPrint('[_SettingsViewState] 語系設定已更新，重新整理畫面');
                      setState(() {});
                    }
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
              SettingsSectionTitle(title: t.pageturning),
              SwitchListTile(
                secondary: const Icon(Icons.touch_app),
                title: Text(t.halfscreenturnpages1),
                subtitle: Text(t.halfscreenturnpages2),
                value: widget.controller.useSideTap,
                onChanged: (val) {
                  debugPrint('[_SettingsViewState] 更新半螢幕點擊翻頁設定：$val');
                  widget.controller.toggleSideTap(val);
                },
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
                    ? (val) {
                        debugPrint('[_SettingsViewState] 更新音量鍵翻頁設定：$val');
                        widget.controller.toggleVolumeKeys(val);
                      }
                    : null,
              ),
              const Divider(),
              SettingsSectionTitle(title: t.navbarlocation),
              ListTile(
                leading: const Icon(Icons.stay_current_landscape),
                title: Text(t.currlandscape),
                trailing: DropdownButton<LandscapeNavPosition>(
                  value: widget.controller.landscapeNavPosition,
                  onChanged: (val) {
                    if (val != null) {
                      debugPrint('[_SettingsViewState] 更新橫向模式導覽列位置：$val');
                      widget.controller.setLandscapeNavPosition(val);
                    }
                    if (mounted) {
                      debugPrint('[_SettingsViewState] 橫向模式導覽列位置已更新，重新整理畫面');
                      setState(() {});
                    }
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
                subtitle: _isScreenReaderActive ? Text(t.accessibilityAutoDisabled) : (!isSensorSupported ? Text(t.sensorAutoDisabled) : null),
                trailing: DropdownButton<PortraitNavPosition>(
                  // 若平台不支援感測器或螢幕朗讀模式啟用，且目前值為 auto，則介面上強制顯示為 right。
                  value:
                      ((!isSensorSupported || _isScreenReaderActive) &&
                          widget.controller.portraitNavPosition ==
                              PortraitNavPosition.auto)
                      ? PortraitNavPosition.right
                      : widget.controller.portraitNavPosition,
                  onChanged: (val) {
                     if (val != null) {
                       // 安全檢查：若不支援感測器或螢幕朗讀模式啟用，不允許切換至 auto。
                        if ((!isSensorSupported || _isScreenReaderActive) &&
                            val == PortraitNavPosition.auto) {
                         debugPrint(
                           '[_SettingsViewState] 目前平台不支援感測器或螢幕朗讀模式啟用，忽略直向模式 auto 導覽列設定',
                         );
                         return;
                       }
                       debugPrint('[_SettingsViewState] 更新直向模式導覽列位置：$val');
                       widget.controller.setPortraitNavPosition(val);
                     }
                    if (mounted) {
                      debugPrint('[_SettingsViewState] 直向模式導覽列位置已更新，重新整理畫面');
                      setState(() {});
                    }
                  },
                  items: [
                     DropdownMenuItem(
                       value: PortraitNavPosition.auto,
                        enabled: isSensorSupported && !_isScreenReaderActive, // 不支援感測器或螢幕朗讀模式啟用時停用此選項
                       child: Text(
                         t.navbarlocationauto,
                         style: TextStyle(
                           // 不支援感測器或螢幕朗讀模式啟用時將文字顏色顯示為灰色。
                            color: isSensorSupported && !_isScreenReaderActive ? null : Colors.grey,
                         ),
                       ),
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
              SettingsSectionTitle(title: t.datamanagement),
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
                onTap: () {
                  debugPrint('[_SettingsViewState] 使用者點擊資料匯入項目');
                  confirmImport(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.redAccent),
                title: Text(t.allclear1),
                subtitle: Text(t.allclear2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint('[_SettingsViewState] 使用者點擊資料重設項目');
                  confirmReset(
                    context,
                    _exitAnimationController,
                    (val) => _isExit = val,
                  );
                },
              ),
              const Divider(),
              SettingsSectionTitle(title: t.helpinfo),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(t.help),
                subtitle: Text(t.help),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint('[_SettingsViewState] 開啟說明頁面');
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
                onTap: () {
                  debugPrint('[_SettingsViewState] 使用者開啟關於資訊對話框');
                  openAboutDialog(context, _version, _buildNumber);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.power_settings_new),
                  title: Text(t.exit),
                  subtitle: Text(t.exit2),
                  onTap: _isExiting
                      ? null
                      : () {
                          debugPrint('[_SettingsViewState] 使用者觸發應用程式退出');
                          _performExitWithAnimation();
                        },
                ),
            ],
          ),
        ),

        /// 退出流程專用遮罩層。
        ///
        /// 當 [_isExiting] 為 `true` 時，啟用黑色淡入遮罩並攔截操作，
        /// 避免使用者於退出過程中再次觸發互動。
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

  @override
  void dispose() {
    debugPrint('[_SettingsViewState] 釋放設定頁面資源');
    // 移除無障礙特性變化監聽器
    WidgetsBinding.instance.removeObserver(this);
    // 取消螢幕朗讀狀態訂閱
    _screenReaderSubscription?.cancel();
    // 取消延遲檢查定時器
    _accessibilityCheckTimer?.cancel();
    _exitAnimationController.dispose();
    super.dispose();
  }
}
