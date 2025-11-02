import 'package:flutter/material.dart';

/// 提供整個應用程式樹重新建立能力的包裝元件。
///
/// 此元件會透過替換內部的 [KeyedSubtree] Key，
/// 強制其子樹全部重新建立，常用於：
/// - 需要模擬「重新啟動 App」的情境
/// - 匯入設定後，希望整體 UI 狀態完整重建
/// - 需要清空部分 Widget 狀態快取時
///
/// 注意：
/// 這並不是真正重新啟動原生應用程式，
/// 而是讓 Flutter Widget 樹自目前節點往下重新建構。
class RestartWidget extends StatefulWidget {
  /// 需要被包裝、並可在重建時整體刷新的子元件。
  final Widget child;

  /// 建立可重建子樹的包裝元件。
  const RestartWidget({super.key, required this.child});

  /// 供外部從 [BuildContext] 觸發整體子樹重建的靜態方法。
  ///
  /// 會往上尋找最近的 [_RestartWidgetState]，
  /// 若找到則呼叫其 [restartApp] 方法。
  static void restartApp(BuildContext context) {
    debugPrint('[RestartWidget] 嘗試觸發應用程式子樹重建');
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    if (state != null) {
      state.restartApp();
    } else {
      debugPrint('[RestartWidget] 錯誤：找不到 _RestartWidgetState，無法重啟應用程式');
    }
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

/// [RestartWidget] 的狀態類別。
///
/// 透過更新 [key] 來強制 [KeyedSubtree] 重建，
/// 使其下方整個 Widget 子樹重新初始化。
class _RestartWidgetState extends State<RestartWidget> {
  /// 目前子樹所使用的唯一 Key。
  ///
  /// 每次重建時都會產生新的 [UniqueKey]，
  /// 以觸發 Flutter 將該子樹視為全新節點重新建立。
  Key key = UniqueKey();

  /// 重新建立目前包裝的子樹。
  ///
  /// 透過替換 [key] 的方式，迫使 [KeyedSubtree]
  /// 及其下方所有子元件重新建構。
  void restartApp() {
    debugPrint('[RestartWidget] 開始重新建立應用程式子樹');
    setState(() {
      key = UniqueKey();
    });
    debugPrint('[RestartWidget] 應用程式子樹已重新建立');
  }

  @override
  Widget build(BuildContext context) {
    // 使用 KeyedSubtree 綁定動態 Key，當 Key 改變時強制整個子樹重建。
    return KeyedSubtree(key: key, child: widget.child);
  }
}
