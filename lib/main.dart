import 'package:flutter/material.dart';
import 'home/home_view.dart';
// import 'restart_widget.dart';

/// 應用程式進入點。
///
/// 會先確保 Flutter 繫結初始化完成，
/// 再啟動整個應用程式。
void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    // 定義基礎主題色，供亮色與暗色主題共同衍生色彩系統使用。
    const Color seedColor = Colors.red;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 亮色主題設定。
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        // 可於此集中調整全域元件樣式，例如 AppBar 外觀。
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
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
      home: const HomeView(),
    );
  }
}
