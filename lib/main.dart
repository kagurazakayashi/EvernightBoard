import 'package:flutter/material.dart';
import 'home/home_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'restart_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:evernight_board/l10n/app_localizations.dart';
import 'global.dart';
import 'package:evernight_board/home/home_controller.dart';

final HomeController _appController = HomeController();

/// 應用程式進入點。
///
/// 會先確保 Flutter 繫結初始化完成，
/// 再啟動整個應用程式。
void main() {
  // 確保外掛與原生層初始化（在非同步呼叫前必須執行）
  WidgetsFlutterBinding.ensureInitialized();

  // 註冊你的自定義許可
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['\u0001 ${t.appTitle}'], license);
  });

  // 若未來需要支援整體 Widget 樹重建，可改用 RestartWidget 包裝根元件。
  // runApp(const RestartWidget(child: EvernightBoardAPP()));
  runApp(EvernightBoardAPP());
}

/// Evernight Board 應用程式根元件。
///
/// 負責建立全域 [MaterialApp]，並統一設定：
/// - 亮色／暗色主題
/// - 全域色彩種子
/// - 主題模式
/// - 首頁入口
class EvernightBoardAPP extends StatelessWidget {
  /// 建立應用程式根元件。
  const EvernightBoardAPP({super.key});

  @override
  Widget build(BuildContext context) {
    // 定義基礎主題色，供亮色與暗色主題共同衍生色彩系統使用
    const Color seedColor = Colors.red;

    return ListenableBuilder(
      listenable: _appController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _appController.appLocale,

          // 提供翻譯字典的代理
          localizationsDelegates: const [
            AppLocalizations.delegate, // 生成的代理
            GlobalMaterialLocalizations.delegate, // Material 元件的內建多語言
            GlobalWidgetsLocalizations.delegate, // Widget 元件的內建多語言
            GlobalCupertinoLocalizations.delegate, // Cupertino 元件的內建多語言
          ],
          // 宣告 APP 支援的語言列表
          supportedLocales: const [
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
            Locale('en'),
            Locale('ja'),
          ],
          // 使用 builder 攔截 context 並初始化 Global
          builder: (context, child) {
            Global.init(context);
            return child!;
          },

          // 亮色主題設定
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ),
            // 集中調整全域元件樣式
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating, // 強制使用浮動樣式，不會緊貼底部
            ),
          ),

          // 暗色主題設定。
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark, // 指定使用暗色亮度配置
            ),
            // 暗色模式下額外指定頁面背景色，避免預設背景不符合整體視覺風格。
            scaffoldBackgroundColor: const Color(0xFF121212), // 經典深色背景
          ),

          // 設定主題模式跟隨系統。
          themeMode: ThemeMode.system,

          // 應用程式首頁入口。
          home: HomeView(controller: _appController),
        );
      },
    );
  }
}
