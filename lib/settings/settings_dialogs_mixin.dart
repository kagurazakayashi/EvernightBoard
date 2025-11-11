import 'package:flutter/material.dart';
import 'package:evernight_board/flavor.dart';
import 'package:evernight_board/settings/icp.dart';
import 'package:evernight_board/global.dart';
import 'package:evernight_board/restart_widget.dart';
import 'settings_view.dart';
import 'settings_utils.dart';

/// 封裝設定頁面中各類彈出式對話框邏輯的 Mixin。
///
/// 透過 `on State<SettingsView>` 約束此 Mixin 的使用對象，確保可直接存取
/// [widget.controller]、目前畫面狀態，以及與 [SettingsView] 相關的生命週期。
///
/// 此 Mixin 主要負責：
/// - 顯示資料匯入確認對話框
/// - 顯示資料重設確認對話框
/// - 顯示關於資訊對話框
/// - 提供語系值轉換工具方法
mixin SettingsDialogsMixin on State<SettingsView> {
  /// 用於產生 ICP 備案資訊字串的工具實例。
  final Icp icp = Icp();

  /// 顯示資料匯入確認對話框。
  ///
  /// 使用者確認後，會呼叫 [widget.controller.importData] 執行資料匯入流程。
  /// 若使用者取消，則僅關閉對話框，不進行任何後續操作。
  void confirmImport(BuildContext context) {
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
              debugPrint('[_SettingsViewState] 使用者確認資料匯入');
              Navigator.pop(context);
              widget.controller.importData(context);
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  /// 顯示重設所有資料的確認對話框。
  ///
  /// 此對話框會阻擋使用者點擊遮罩關閉，避免在高風險操作中誤觸離開。
  ///
  /// [exitController] 用於在確認清除後執行退出或重新載入動畫。
  /// [setExitFlag] 用於更新外部退出旗標，避免流程直接結束。
  void confirmReset(
    BuildContext context,
    AnimationController exitController,
    Function(bool) setExitFlag,
  ) {
    debugPrint('[_SettingsViewState] 顯示資料重設確認對話框');
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return isProcessing
                ? const SizedBox.shrink()
                : AlertDialog(
                    title: Text(t.allclear1),
                    content: Text(t.allclear3),
                    actions: [
                      TextButton(
                        onPressed: () {
                          debugPrint('[_SettingsViewState] 使用者取消清除全部資料');
                          Navigator.pop(context);
                        },
                        child: Text(t.cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          setDialogState(() => isProcessing = true);
                          debugPrint(
                            '[_SettingsViewState] 使用者確認清除全部資料，開始執行重設流程',
                          );

                          setExitFlag(false); // 設定 _isExit 為 false，避免流程直接結束。
                          // 等待退出動畫完成（畫面全黑）
                          await exitController.forward();
                          if (!mounted) return;
                          // 清除資料但不立即重啟
                          await widget.controller.clearAllData(
                            this.context,
                            restartImmediately: false,
                          );
                          if (!mounted) return;
                          // 重啟應用程式（對話框會自動關閉）
                          debugPrint('[_SettingsViewState] 動畫完成，重啟應用程式');
                          RestartWidget.restartApp(this.context);
                        },
                        child: Text(
                          t.ok,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
          },
        );
      },
    );
  }

  /// 顯示「關於」資訊對話框。
  ///
  /// 為避免與 Flutter 內建的 [showAboutDialog] 頂層函式命名衝突，
  /// 此處將方法命名為 [openAboutDialog]。
  ///
  /// [version] 為應用程式版本號主體。
  /// [buildNumber] 為建置版本號，通常用於區分不同建置批次。
  void openAboutDialog(
    BuildContext context,
    String version,
    String buildNumber,
  ) {
    String icpString = icp.icpString(widget.controller.appLocale);
    debugPrint(
      '[_SettingsViewState] 開啟關於資訊對話框，version=$version，buildNumber=$buildNumber',
    );

    // 此處會呼叫 Flutter material.dart 提供的 showAboutDialog 頂層函式。
    showAboutDialog(
      context: context,
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
          "v$version.$buildNumber (${Flavor.flavor.isEmpty ? "Debug" : Flavor.flavor})",
      applicationLegalese:
          "is licensed under Mulan PSL v2.\n© 2026 KagurazakaYashi(KagurazakaMiyabi)$icpString\n",
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LinkText(
              label: t.help,
              path: "${Flavor.github}/blob/main/${t.readme}",
            ),
            _LinkText(
              label: t.issues,
              path: "/kagurazakayashi/EvernightBoard/issues",
            ),
            _LinkText(
              label: t.srccode,
              path: "/kagurazakayashi/EvernightBoard",
            ),
          ],
        ),
        const SizedBox(height: 10), // 增加元件間距，提升版面可讀性。
        Text(t.privacylicense),
      ],
    );
  }

  /// 將 [Locale] 轉換為下拉選單使用的語系鍵值。
  ///
  /// 轉換規則如下：
  /// - `null` 轉為 `'auto'`，表示跟隨系統
  /// - 繁體中文（`zh` + `Hant`）轉為 `'zh_Hant'`
  /// - 其餘語系則回傳其 [Locale.languageCode]
  String getLocaleKey(Locale? locale) {
    if (locale == null) {
      debugPrint('[_SettingsViewState] 語系為空，回傳 auto');
      return 'auto';
    }
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      debugPrint('[_SettingsViewState] 偵測到繁體中文語系，回傳 zh_Hant');
      return 'zh_Hant';
    }
    debugPrint('[_SettingsViewState] 使用語系代碼：${locale.languageCode}');
    return locale.languageCode;
  }
}

/// 設定頁面內部使用的私有連結文字元件。
///
/// 此元件會以底線樣式呈現文字，並在使用者點擊後透過 [jumpUrL]
/// 開啟對應連結。
class _LinkText extends StatelessWidget {
  /// 顯示於畫面上的連結文字。
  final String label;

  /// 點擊後要開啟的目標路徑或網址。
  final String path;

  /// 建立一個可點擊的連結文字元件。
  const _LinkText({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('[_SettingsViewState] 點擊關於資訊連結：$path');
        jumpUrL(path: path);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
