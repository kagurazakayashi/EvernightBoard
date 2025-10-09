import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evernight_board/global.dart';

/// README 說明頁面。
///
/// 此元件負責從資源檔載入 Markdown 格式的 README 內容，
/// 並透過 `Markdown` 元件進行渲染顯示。
///
/// 功能包含：
/// - 非同步載入本地資源中的 README 檔案。
/// - 顯示載入中的進度指示器。
/// - 顯示載入失敗時的錯誤訊息。
/// - 支援點擊 Markdown 內的超連結，並以外部應用程式開啟。
class ReadmeView extends StatelessWidget {
  /// 建立 README 說明頁面。
  const ReadmeView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[ReadmeView] 建立 README 頁面並準備載入 Markdown 內容。');

    return Scaffold(
      appBar: AppBar(
        // 顯示說明頁標題文字。
        title: Text(t.help),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        // 非同步載入資源檔中指定路徑的 README Markdown 內容。
        future: rootBundle.loadString(t.readme),
        builder: (context, snapshot) {
          // 載入進行中時顯示圓形進度指示器。
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('[ReadmeView] README 內容載入中。');
            return const Center(child: CircularProgressIndicator());
          }

          // 載入失敗時顯示錯誤資訊，便於除錯與問題追蹤。
          if (snapshot.hasError) {
            debugPrint('[ReadmeView] README 載入失敗：${snapshot.error}');
            return Center(child: Text('${snapshot.error}'));
          }

          debugPrint('[ReadmeView] README 載入完成，準備渲染 Markdown。');

          return Markdown(
            // 使用載入完成的 Markdown 文字內容；若資料為空則以空字串避免例外。
            data: snapshot.data ?? '',
            // 允許使用者選取文字內容，方便複製或檢視。
            selectable: true,
            // 處理 Markdown 超連結點擊事件。
            onTapLink: (text, href, title) async {
              if (href != null) {
                debugPrint('[ReadmeView] 偵測到連結點擊：$href');

                final url = Uri.parse(href);

                if (await canLaunchUrl(url)) {
                  debugPrint('[ReadmeView] 可開啟連結，將使用外部應用程式啟動。');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('[ReadmeView] 無法開啟連結：$href');
                }
              } else {
                debugPrint('[ReadmeView] 點擊連結時 href 為空，已略過處理。');
              }
            },
          );
        },
      ),
    );
  }
}
