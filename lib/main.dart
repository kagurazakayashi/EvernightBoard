import 'package:flutter/material.dart';
import 'home/home_view.dart'; // 匯入功能頁面的主視圖

/// 應用程式進入點。
///
/// Flutter 會從這裡開始執行，並載入根元件 [MyApp]。
void main() {
  runApp(const MyApp()); // 啟動應用程式，並將 MyApp 掛載到畫面樹中
}

/// 應用程式的根元件。
///
/// 此元件負責建立整個 App 的基礎設定，包含：
/// - 應用程式標題
/// - 除錯標籤顯示設定
/// - 全域主題樣式
/// - 首頁入口頁面
class MyApp extends StatelessWidget {
  /// 建立 [MyApp] 根元件。
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvernightBoard', // 設定應用程式標題
      debugShowCheckedModeBanner: false, // 關閉右上角的 DEBUG 標籤
      theme: ThemeData(
        primarySwatch: Colors.blue, // 設定主要色票為藍色
        useMaterial3: true, // 啟用 Material 3 設計風格
      ),
      // 這裡的 HomeView 是我們功能模組的入口
      home: const HomeView(), // 指定應用程式啟動後顯示的首頁
    );
  }
}
