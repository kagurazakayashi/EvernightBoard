import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evernight_board/global.dart';

class ReadmeView extends StatelessWidget {
  const ReadmeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.help), // 或者使用你定義的“使用說明”文案
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        // 非同步載入根目錄下的 README.md
        future: rootBundle.loadString(t.readme),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          return Markdown(
            data: snapshot.data ?? '',
            selectable: true,
            onTapLink: (text, href, title) async {
              if (href != null) {
                final url = Uri.parse(href);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              }
            },
          );
        },
      ),
    );
  }
}
