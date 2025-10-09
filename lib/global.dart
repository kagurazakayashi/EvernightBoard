import 'package:flutter/widgets.dart';
import 'l10n/app_localizations.dart';

/// 提供全域存取 `AppLocalizations` 實例的工具類別。
///
/// 此類別會在應用程式初始化或切換語系後，透過 [init] 將當前
/// [BuildContext] 對應的 `AppLocalizations` 實例保存起來，方便其他
/// 區域以靜態方式快速存取多語系資源。
///
/// 注意：
/// - 在呼叫 [t] 之前，必須先完成 [init]。
/// - 若尚未初始化即存取 [t]，會因 `_instance!` 而拋出例外。
class Global {
  /// 儲存目前可用的多語系實例。
  static AppLocalizations? _instance;

  /// 使用指定的 [context] 初始化全域多語系實例。
  ///
  /// 通常應於應用程式啟動完成後，或可取得正確語系 `context` 的時機點呼叫。
  static void init(BuildContext context) =>
      _instance = AppLocalizations.of(context);

  /// 取得目前已初始化的多語系實例。
  ///
  /// 呼叫端可透過 `Global.t.xxx` 存取對應的多語系字串。
  static AppLocalizations get t => _instance!;
}

// g.t.app_title

/// 提供較簡潔的全域多語系存取入口。
///
/// 可直接使用 `t.xxx` 取得對應的多語系字串，效果等同於 `Global.t.xxx`。
AppLocalizations get t => Global.t;

/// 全域 `Global` 單例存取點。
///
/// 雖然 [Global] 主要透過靜態成員運作，此實例仍可作為統一的全域存取入口，
/// 例如以 `g.t.xxx` 的形式讀取多語系內容。
final Global g = Global();
