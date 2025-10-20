import 'dart:io';

import 'package:evernight_board/flavor.dart';
import 'package:evernight_board/settings/icp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:evernight_board/global.dart';
import 'readme_view.dart';

/// 設定頁面視圖元件。
///
/// 負責顯示並管理應用程式的全域設定項目，包含語言切換、翻頁行為、
/// 導覽列位置、資料匯入匯出、資料重設，以及關於頁相關資訊。
///
/// 此元件本身不直接持有設定資料，而是透過 [HomeController] 讀取與寫入
/// 應用程式層級的狀態。
class SettingsView extends StatefulWidget {
  /// 設定頁面所依賴的首頁控制器。
  ///
  /// 用於存取目前設定值，並將使用者在介面上的操作同步回應用程式狀態。
  final HomeController controller;

  /// 建立設定頁面實例。
  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

/// [SettingsView] 的狀態管理類別。
///
/// 負責：
/// - 初始化版本資訊。
/// - 管理退出動畫。
/// - 處理使用者在設定頁上的互動事件。
/// - 顯示各類確認對話框與關於資訊。
class _SettingsViewState extends State<SettingsView>
    with TickerProviderStateMixin {
  /// 控制應用程式退出時的淡出動畫。
  ///
  /// 當使用者觸發退出動作時，會驅動黑色遮罩由透明漸變為全黑。
  late AnimationController _exitAnimationController;

  /// 黑色遮罩的不透明度動畫。
  ///
  /// 數值範圍為 0.0 到 1.0，對應遮罩從完全透明到完全不透明。
  late Animation<double> _blackOutAnimation;

  /// 是否正在執行退出流程。
  ///
  /// 用於避免重複觸發退出邏輯，並在動畫進行期間停用相關操作。
  bool _isExiting = false;

  /// 應用程式版本號。
  ///
  /// 預設值為佔位內容，待平台資訊初始化完成後會更新為實際值。
  String _version = '0.0.0';

  /// 應用程式建置編號。
  ///
  /// 預設值為佔位內容，待平台資訊初始化完成後會更新為實際值。
  String _buildNumber = '0';

  /// ICP 與相關備案資訊工具物件。
  ///
  /// 用於在關於對話框中依當前語系產生對應的顯示字串。
  Icp icp = Icp();

  @override
  void initState() {
    super.initState();
    debugPrint('[_SettingsViewState] 開始初始化設定頁面狀態');
    _initPackageInfo();

    /// 初始化退出動畫控制器。
    ///
    /// 動畫總時長為 600 毫秒，配合黑色遮罩淡入效果，提供較平滑的退出視覺體驗。
    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    /// 建立黑色遮罩的不透明度動畫。
    ///
    /// 使用 easeInOut 曲線，讓淡入過程在視覺上更自然。
    _blackOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    /// 監聽退出動畫狀態。
    ///
    /// 當畫面已完全轉黑且動畫結束後，直接呼叫 [exit] 結束應用程式行程。
    _exitAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('[_SettingsViewState] 退出動畫完成，準備結束應用程式');
        exit(0);
      }
    });
  }

  /// 從平台層讀取應用程式版本資訊。
  ///
  /// 透過 [PackageInfo.fromPlatform] 取得版本號與建置編號，
  /// 並在元件仍掛載於 Widget Tree 時更新畫面狀態。
  ///
  /// 若讀取過程發生例外，僅輸出除錯訊息，不中斷畫面流程。
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
          '[_SettingsViewState] 版本資訊載入成功：version=$_version, build=$_buildNumber',
        );
      } else {
        debugPrint('[_SettingsViewState] 版本資訊已取得，但元件已卸載，略過狀態更新');
      }
    } catch (e) {
      debugPrint('[_SettingsViewState] 讀取版本資訊失敗：$e');
    }
  }

  /// 切換側邊點擊翻頁功能。
  ///
  /// [val] 為使用者在介面上選取的新狀態。
  ///
  /// 此方法會將設定同步至 [HomeController]，並在元件仍存在時刷新畫面。
  void toggleSideTap(bool val) {
    debugPrint('[_SettingsViewState] 更新半螢幕點擊翻頁設定：$val');
    widget.controller.toggleSideTap(val);
    if (mounted) {
      setState(() {});
    }
  }

  /// 切換實體音量鍵翻頁功能。
  ///
  /// [val] 為使用者在介面上選取的新狀態。
  ///
  /// 此功能僅在支援實體音量鍵的平台上可用，實際平台判斷邏輯位於 [build] 中。
  void toggleVolumeKeys(bool val) {
    debugPrint('[_SettingsViewState] 更新音量鍵翻頁設定：$val');
    widget.controller.toggleVolumeKeys(val);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 判斷目前平台是否支援實體音量鍵翻頁。
    final bool isVolumeSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    /// 判斷目前平台是否支援重力感測器 (Web 與桌面版不支援)。
    final bool isSensorSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    /// 判斷目前語言顯示是否需要額外補充英文說明。
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
                      debugPrint('[_SettingsViewState] 更新橫向模式導覽列位置：$val');
                      widget.controller.setLandscapeNavPosition(val);
                    }
                    if (mounted) {
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
                trailing: DropdownButton<PortraitNavPosition>(
                  // 如果不支援感測器，且當前值為 auto，則 UI 強制顯示為 right
                  value:
                      (!isSensorSupported &&
                          widget.controller.portraitNavPosition ==
                              PortraitNavPosition.auto)
                      ? PortraitNavPosition.right
                      : widget.controller.portraitNavPosition,
                  onChanged: (val) {
                    if (val != null) {
                      // 安全檢查：如果不支援感應器，不允許切換到 auto
                      if (!isSensorSupported &&
                          val == PortraitNavPosition.auto) {
                        return;
                      }
                      debugPrint('[_SettingsViewState] 更新直向模式導覽列位置：$val');
                      widget.controller.setPortraitNavPosition(val);
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: PortraitNavPosition.auto,
                      enabled: isSensorSupported, // 不支援時停用該選項，使其不可被點擊
                      child: Text(
                        t.navbarlocationauto,
                        style: TextStyle(
                          // 不支援時將字體顏色設為灰色
                          color: isSensorSupported ? null : Colors.grey,
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

        /// 退出流程專用遮罩層。
        ///
        /// 當 [_isExiting] 為 `true` 時，啟用黑色淡入遮罩並攔截操作，
        /// 避免使用者在退出過程中再次觸發互動。
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

  /// 顯示資料匯入確認對話框。
  ///
  /// 匯入操作會覆蓋目前既有資料，屬於具破壞性的行為，
  /// 因此在正式執行前需要再次向使用者確認。
  void _confirmImport(BuildContext context) {
    debugPrint('[_SettingsViewState] 顯示資料匯入確認對話框');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.importscreenconf1),
        content: Text(t.importscreenconf3),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者取消資料匯入');
              Navigator.pop(context);
            },
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者確認資料匯入，準備呼叫控制器');
              Navigator.pop(context);
              widget.controller.importData(context);
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  /// 將 [Locale] 轉換為下拉選單使用的語系鍵值。
  ///
  /// 當 [locale] 為 `null` 時，代表使用系統自動語言設定，回傳 `auto`。
  /// 若為繁體中文，則依既有規則回傳 `zh_Hant`。
  String _getLocaleKey(Locale? locale) {
    if (locale == null) return 'auto';
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return 'zh_Hant';
    }
    return locale.languageCode;
  }

  /// 顯示重設所有資料的確認對話框。
  ///
  /// 執行後將清除本機儲存的所有資料，屬不可逆操作，
  /// 因此需透過對話框進行二次確認。
  void _confirmReset(BuildContext context) {
    debugPrint('[_SettingsViewState] 顯示資料重設確認對話框');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.allclear1),
        content: Text(t.allclear3),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者取消資料重設');
              Navigator.pop(context);
            },
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              debugPrint('[_SettingsViewState] 使用者確認清除全部資料');
              widget.controller.clearAllData(context);
              Navigator.pop(context);
            },
            child: Text(t.ok, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 顯示「關於」對話框。
  ///
  /// 對話框中包含：
  /// - 應用程式名稱與圖示
  /// - 版本資訊
  /// - 授權與版權資訊
  /// - 說明、問題回報與原始碼連結
  void _about(BuildContext context) {
    String icpString = icp.icpString(widget.controller.appLocale);
    debugPrint('[_SettingsViewState] 開啟關於資訊對話框');
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
              applicationVersion:
                  "v$_version.$_buildNumber (${Flavor.flavor.isEmpty ? "Debug" : Flavor.flavor})",
              applicationLegalese:
                  "is licensed under Mulan PSL v2.\n© 2026 KagurazakaYashi(KagurazakaMiyabi)$icpString\n",
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => jumpUrL(
                        path: "${Flavor.github}/blob/main/${t.readme}",
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

  /// 執行退出動畫並在動畫結束後關閉應用程式。
  ///
  /// 若目前已處於退出流程中，則直接返回，避免重複執行動畫與結束邏輯。
  void _performExitWithAnimation() {
    if (_isExiting) {
      debugPrint('[_SettingsViewState] 退出流程已在進行中，忽略重複請求');
      return;
    }
    debugPrint('[_SettingsViewState] 開始執行退出動畫');
    setState(() => _isExiting = true);
    _exitAnimationController.forward();
  }
}

/// 使用外部應用程式開啟指定網址。
///
/// 預設組合為 `https://github.com`，並可透過參數覆寫協定、主機與路徑。
///
/// 參數說明：
/// - [scheme]：URL 協定，預設為 `https`。
/// - [host]：主機名稱，預設為 `github.com`。
/// - [path]：資源路徑。
///
/// 若主機名稱為空字串，將直接略過開啟流程。
Future jumpUrL({
  String scheme = "https",
  String host = "github.com",
  String path = "",
}) async {
  if (host == "") {
    debugPrint('[jumpUrL] 無效的 host 參數，取消開啟網址');
    return;
  }
  final url = Uri(scheme: scheme, host: host, path: path);
  debugPrint('[jumpUrL] 準備開啟外部網址：$url');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('[jumpUrL] 無法使用外部應用程式開啟網址：$url');
    } else {
      debugPrint('[jumpUrL] 已成功送出外部開啟請求：$url');
    }
  } catch (e) {
    debugPrint('[jumpUrL] 開啟網址時發生例外：$e');
  }
}

/// 設定頁面中的區塊標題元件。
///
/// 用於在長列表中分隔不同設定群組，提供一致的留白、字重與主題色彩，
/// 提升整體資訊層次與可讀性。
class _SettingsSectionTitle extends StatelessWidget {
  /// 區塊標題文字內容。
  final String title;

  /// 建立設定區塊標題元件。
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      /// 控制標題與相鄰清單項目的間距，使群組分段更清楚。
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
