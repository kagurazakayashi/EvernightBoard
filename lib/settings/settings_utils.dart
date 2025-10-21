import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 使用外部應用程式開啟指定網址。
///
/// 此函式會依據傳入的 [scheme]、[host] 與 [path] 組合出一個 [Uri]，
/// 並透過 [launchUrl] 以 [LaunchMode.externalApplication] 模式開啟，
/// 讓系統交由外部應用程式處理該連結。
///
/// 預設會組合為 `https://github.com`，可依需求覆寫協定、主機與路徑。
///
/// 參數說明：
/// - [scheme]：URL 使用的通訊協定，預設為 `https`。
/// - [host]：目標網址的主機名稱，預設為 `github.com`。
/// - [path]：附加於主機後的資源路徑，預設為空字串。
///
/// 注意事項：
/// - 當 [host] 為空字串時，函式會直接中止，不執行開啟流程。
/// - 此函式僅負責送出開啟請求，實際開啟結果仍取決於裝置環境與系統可用的外部應用程式。
Future<void> jumpUrL({
  String scheme = "https",
  String host = "github.com",
  String path = "",
}) async {
  if (host == "") {
    debugPrint('[jumpUrL] 偵測到無效的 host 參數，已取消網址開啟流程');
    return;
  }
  final url = Uri(scheme: scheme, host: host, path: path);
  debugPrint('[jumpUrL] 準備以外部應用程式開啟網址：$url');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('[jumpUrL] 外部應用程式開啟失敗：$url');
    } else {
      debugPrint('[jumpUrL] 已成功送出外部開啟請求：$url');
    }
  } catch (e) {
    debugPrint('[jumpUrL] 開啟網址時發生例外：$e');
  }
}
