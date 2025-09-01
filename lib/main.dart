import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'home/home_view.dart';

/// 應用程式進入點。
///
/// 負責先初始化 Flutter 綁定，確保在執行應用程式前，
/// Flutter 與平台層之間的溝通機制已就緒，接著再啟動根元件。
void main() {
  // 確保 Flutter 引擎綁定已完成初始化。
  // 若後續需要在 runApp 前呼叫平台通道、載入設定或進行其他初始化作業，
  // 通常都應先執行這一行。
  WidgetsFlutterBinding.ensureInitialized();

  // 啟動應用程式，並將 DemoMasterApp 設為根元件。
  runApp(DemoMasterApp());
}

/// 應用程式的根元件。
///
/// 此元件負責建立整體 MaterialApp 設定，例如：
/// 顯示模式、深色主題、主題切換策略，以及預設首頁。
class DemoMasterApp extends StatelessWidget {
  /// 建立應用程式根元件。
  const DemoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 提供深色主題設定，讓應用程式在深色模式下使用對應配色。
      darkTheme: ThemeData(colorScheme: ColorScheme.dark()),

      // 主題模式跟隨系統設定，自動於淺色與深色模式間切換。
      themeMode: ThemeMode.system,

      // 應用程式啟動後顯示的首頁畫面。
      home: HomeView(),
    );
  }
}
