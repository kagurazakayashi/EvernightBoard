import 'package:flutter/material.dart';
import 'home_controller.dart';

/// HomeView 為首頁畫面的 StatefulWidget。
///
/// 職責：
/// - 建立並顯示首頁 UI。
/// - 與 [HomeController] 綁定，依據控制器狀態更新畫面。
/// - 顯示中央文字內容與底部導覽列。
class HomeView extends StatefulWidget {
  /// 建立首頁畫面元件。
  const HomeView({super.key});

  /// 建立對應的 State 物件。
  @override
  State<HomeView> createState() => _HomeViewState();
}

/// [HomeView] 對應的狀態類別。
///
/// 主要負責：
/// - 初始化與釋放 [HomeController]
/// - 監聽控制器狀態變化並刷新 UI
/// - 根據畫面尺寸動態計算文字縮放比例
class _HomeViewState extends State<HomeView> {
  /// 首頁控制器實例。
  ///
  /// 用於管理目前顯示的內容、底部導覽列索引，以及頁面切換邏輯。
  final HomeController _controller = HomeController();

  /// State 初始化生命週期。
  ///
  /// 在元件第一次建立時呼叫：
  /// - 先執行父類別初始化
  /// - 註冊 controller 監聽器，當資料變化時透過 setState 重新建構畫面
  @override
  void initState() {
    super.initState();
    // 監聽 Controller 的變化，當內部狀態更新時重新刷新畫面
    _controller.addListener(() => setState(() {}));
  }

  /// State 釋放生命週期。
  ///
  /// 當畫面被移除時：
  /// - 先釋放 controller 資源，避免記憶體洩漏
  /// - 再呼叫父類別的 dispose
  @override
  void dispose() {
    // 釋放 Controller 佔用的資源
    _controller.dispose();
    super.dispose();
  }

  /// 建立首頁畫面。
  ///
  /// 畫面包含：
  /// - 使用 [LayoutBuilder] 動態計算可用空間
  /// - 中央顯示可自動縮放大小的文字
  /// - 底部導覽列，點擊後切換內容
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 之前討論的文字自適應邏輯 ---
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 從 Controller 取得目前要顯示的文字內容
          final String text = _controller.currentContent;

          // 定義文字的基礎樣式
          const TextStyle baseStyle = TextStyle(
            height: 1.1,
            color: Colors.blueAccent,
          );

          // 使用 TextPainter 先以固定字級 100 計算文字實際繪製尺寸
          // 這樣可以根據可用空間推算最適合的縮放比例
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: baseStyle.copyWith(fontSize: 100),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();

          // 計算寬度與高度方向各自可容納的縮放比例
          // 並取較小值，確保文字可完整顯示於畫面內
          double scale =
              (constraints.maxWidth / textPainter.width) <
                  (constraints.maxHeight / textPainter.height)
              ? (constraints.maxWidth / textPainter.width)
              : (constraints.maxHeight / textPainter.height);

          return Center(
            child: Text(
              // 顯示目前內容文字
              text,
              // 文字置中對齊
              textAlign: TextAlign.center,
              // 套用基礎樣式，並依縮放比例動態調整字級
              // 額外乘上 0.85 作為保留邊界，避免貼齊畫面
              style: baseStyle.copyWith(fontSize: (100 * scale) * 0.85),
            ),
          );
        },
      ),

      // --- 底部導覽列 ---
      bottomNavigationBar: BottomNavigationBar(
        // 目前選取的頁籤索引
        currentIndex: _controller.currentIndex,
        // 點擊頁籤時，呼叫 Controller 的切換方法
        onTap: _controller.changeIndex,
        // 根據 Controller 提供的項目清單動態建立底部導覽列項目
        items: _controller.items.map((item) {
          return BottomNavigationBarItem(
            // 顯示頁籤圖示
            icon: Icon(item.icon),
            // 顯示頁籤標題
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
}
