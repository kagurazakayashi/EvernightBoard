import 'package:flutter/widgets.dart';
import 'l10n/app_localizations.dart';

class Global {
  static AppLocalizations? _instance;
  static void init(BuildContext context) =>
      _instance = AppLocalizations.of(context);
  static AppLocalizations get t => _instance!;
}

// g.t.app_title
AppLocalizations get t => Global.t;

// 全域性單例
final Global g = Global();
