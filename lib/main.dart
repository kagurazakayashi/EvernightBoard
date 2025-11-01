import 'dart:io';

import 'package:evernight_board/restart_widget.dart';
import 'package:flutter/material.dart';
import 'home/home_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:evernight_board/l10n/app_localizations.dart';
import 'global.dart';
import 'package:evernight_board/home/home_controller.dart';
import 'package:window_manager/window_manager.dart';

/// 判斷目前執行環境是否為桌面平台。
///
/// 僅在非 Web 環境，且作業系統為 Windows、macOS 或 Linux 時回傳 `true`。
/// 此判斷主要用於控制桌面視窗初始化，以及桌面平台專屬的視窗生命週期邏輯。
bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// 應用程式進入點。
///
/// 負責執行下列初始化流程：
///
/// 1. 依建置模式調整 `debugPrint` 行為
/// 2. 初始化 Flutter Framework 與原生平台通道
/// 3. 於桌面平台初始化視窗管理器與預設視窗選項
/// 4. 註冊授權與隱私權文件至 Flutter LicenseRegistry
/// 5. 以 [RestartWidget] 包裝根元件，支援全域重新啟動應用程式
void main() {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  } else {
    debugPrint('[main] kReleaseMode=$kReleaseMode');
    debugPrint('[main] 開始初始化應用程式');
  }

  // 確保 Flutter 綁定、外掛，以及原生平台通道皆已完成初始化。
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktop) {
    debugPrint('[main] 偵測到桌面平台，準備初始化視窗管理器');
    windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(1366, 768), // 設定預設視窗尺寸。
      // center: true, // 啟動時將視窗置中顯示。
      // backgroundColor: Colors.transparent,
      // skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      debugPrint('[main] 視窗已就緒，準備顯示視窗並取得焦點');
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    debugPrint('[main] 目前非桌面平台，略過視窗管理器初始化');
  }

  // 註冊自訂授權資訊，讓授權頁面可顯示 LICENSE 與隱私權文件內容。
  LicenseRegistry.addLicense(() async* {
    debugPrint('[main] 開始載入授權與隱私權文件');
    final license = await rootBundle.loadString('LICENSE');
    final privacy = await rootBundle.loadString(t.privacyfile);

    yield LicenseEntryWithLineBreaks([
      '\u0001 ${t.appTitle} ${t.license}',
    ], license);

    yield LicenseEntryWithLineBreaks([
      '\u0001 ${t.appTitle} ${t.privacy}',
    ], privacy);

    debugPrint('[main] 已完成註冊授權與隱私權文件');
  });

  // 使用 RestartWidget 包裝根元件，以支援應用程式層級的重新啟動能力。
  runApp(RestartWidget(child: const EvernightBoardAPP()));
}

/// Evernight Board 應用程式根元件。
///
/// 此元件採用 [StatefulWidget]，目的是將 [HomeController] 的生命週期
/// 與 Widget Tree 綁定，確保應用程式重新啟動時可正確重建控制器實例。
class EvernightBoardAPP extends StatefulWidget {
  const EvernightBoardAPP({super.key});

  @override
  State<EvernightBoardAPP> createState() => _EvernightBoardAPPState();
}

/// [EvernightBoardAPP] 的狀態物件。
///
/// 此類別同時實作 [WindowListener]，用於監聽桌面平台視窗事件，
/// 並管理應用程式主要控制器 [HomeController] 的建立與釋放流程。
class _EvernightBoardAPPState extends State<EvernightBoardAPP>
    with WindowListener, WidgetsBindingObserver {
  /// 應用程式主控制器。
  ///
  /// 使用 `late final` 可保證：
  /// - 僅在 [initState] 中初始化一次
  /// - 於 State 存活期間維持單一實例
  /// - 當 [RestartWidget] 重建此 State 時會重新建立新實例
  late final HomeController _appController;

  @override
  void initState() {
    super.initState();
    
    // 註冊 WidgetsBindingObserver 以監聽無障礙特性變化
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[_EvernightBoardAPPState] 已註冊 WidgetsBindingObserver');

    // 建立應用程式主控制器，供整體 UI 與狀態同步使用。
    _appController = HomeController();
    debugPrint('[_EvernightBoardAPPState] 已建立 HomeController 實例');

    if (isDesktop) {
      // 註冊視窗事件監聽器，以接收關閉視窗等生命週期事件。
      windowManager.addListener(this);
      debugPrint('[_EvernightBoardAPPState] 已註冊桌面視窗監聽器');

      // 防止使用者直接關閉視窗，改由程式自行控管結束流程。
      windowManager.setPreventClose(true);
      debugPrint('[_EvernightBoardAPPState] 已啟用禁止直接關閉視窗機制');
    }

    // 在下一帧触发无障碍状态检查，解决启动时检测不准确的问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('[_EvernightBoardAPPState] 首帧渲染完成，触发无障碍状态检查');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 移除 WidgetsBindingObserver
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[_EvernightBoardAPPState] 已移除 WidgetsBindingObserver');

    if (isDesktop) {
      // 移除視窗事件監聽器，避免 State 銷毀後仍殘留監聽。
      windowManager.removeListener(this);
      debugPrint('[_EvernightBoardAPPState] 已移除桌面視窗監聽器');
    }

    debugPrint('[_EvernightBoardAPPState] State 即將銷毀');
    super.dispose();
  }

  @override
  void onWindowClose() async {
    debugPrint('[_EvernightBoardAPPState] 收到視窗關閉事件');

    if (isDesktop) {
      // 主動銷毀視窗資源，確保桌面平台完整結束應用程式。
      await windowManager.destroy();
      debugPrint('[_EvernightBoardAPPState] 視窗已銷毀，準備結束應用程式');

      // 即使在 macOS 上，也強制結束整個應用程式行程。
      exit(0);
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    debugPrint('[_EvernightBoardAPPState] 無障礙特性已變更，觸發畫面重建');
    // 觸發畫面重建，讓 HomeView 可以讀取最新的無障礙狀態
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Colors.red;
    const appTitle = "EvernightBoard";

    return ListenableBuilder(
      listenable: _appController,
      builder: (context, _) {
        debugPrint('[_EvernightBoardAPPState] 重新建構 MaterialApp');

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // 套用控制器維護的語系設定，讓整體應用程式可依狀態切換語言。
          locale: _appController.appLocale,
          title: appTitle,

          onGenerateTitle: (context) {
            final localizations = AppLocalizations.of(context);
            String title = localizations?.appTitle ?? appTitle;

            if (isDesktop) {
              windowManager.setTitle(title);
              debugPrint('[_EvernightBoardAPPState] 已更新桌面視窗標題：$title');
            }

            return title;
          },

          // 多語系代理設定，提供 Material / Widgets / Cupertino 與自訂語系資源。
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 宣告應用程式支援的語系列表。
          supportedLocales: const [
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
            Locale('en'),
            Locale('ja'),
          ],

          builder: (context, child) {
            // 於根層建構時注入全域 context，供全域功能存取目前環境資訊。
            Global.init(context);
            debugPrint('[_EvernightBoardAPPState] 已完成 Global.init(context)');
            return child!;
          },

          // 亮色主題設定。
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),

          // 暗色主題設定。
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),

          // 跟隨系統亮暗模式。
          themeMode: ThemeMode.system,

          // 將同一個控制器實例注入首頁，確保狀態一致性。
          home: HomeView(controller: _appController),
        );
      },
    );
  }
}
