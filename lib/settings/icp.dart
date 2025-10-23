import 'dart:io';
import 'dart:ui';

import 'package:evernight_board/flavor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// ICP 備案資訊顯示判斷工具。
///
/// 負責綜合多個環境條件，判斷目前是否應顯示中國地區的 ICP 備案資訊，
/// 例如系統語系、應用程式語系、裝置地區、時區，以及執行平台。
///
/// 此類別主要提供 [icpString] 作為外部取得顯示字串的入口，
/// 並保留 [showICP] 供外部模組讀取或控制顯示狀態。
class Icp {
  /// 是否顯示 ICP 備案資訊。
  ///
  /// 此欄位提供外部呼叫端讀取或控制使用，本類別本身不直接以此欄位作為
  /// 最終顯示判斷依據。
  bool showICP = false;

  /// 系統語系是否判定為簡體中文。
  ///
  /// 於建構時透過 [chkSysIsChs] 初始化。
  bool sysIsChs = false;

  /// 裝置時區是否判定為中國時區。
  ///
  /// 於 [init] 中以非同步方式初始化。
  bool tzIsChs = false;

  /// 裝置地區資訊是否判定為中國。
  ///
  /// 於建構時透過 [isCN] 初始化。
  bool regionIsChs = false;

  /// 建立 ICP 判斷工具實例。
  ///
  /// 建構時會先同步初始化系統語系與地區判斷，
  /// 再啟動時區的非同步檢查流程。
  Icp() {
    sysIsChs = chkSysIsChs();
    regionIsChs = kIsWeb ? false : isCN();
    init();
  }

  /// 初始化時區判斷結果。
  ///
  /// 由於時區資訊需透過非同步 API 取得，因此此方法會更新 [tzIsChs]，
  /// 供後續 [icpString] 判斷是否顯示 ICP 備案資訊。
  void init() async {
    tzIsChs = await isCNTimeZone();
  }

  /// 依目前環境與語系條件回傳 ICP 備案資訊字串。
  ///
  /// [locale] 為應用程式目前使用的語系；若為 `null`，表示可能採用系統語系。
  ///
  /// 回傳規則如下：
  /// - 若未設定 ICP 備案字串，直接回傳空字串。
  /// - 若目前平台不是 Web、Android 或 iOS，直接回傳空字串。
  /// - 僅當系統語系、應用程式語系、中國時區與中國地區條件皆符合時，
  ///   才回傳帶有換行的 ICP 備案資訊。
  /// - 其餘情況皆回傳空字串。
  String icpString(Locale? locale) {
    // 檢查是否配置了 ICP 字串
    if (Flavor.cnICPfiling.isEmpty) {
      debugPrint('[Icp] 停用');
      return "";
    }

    // 限制平臺僅限 iOS (排除 Web 和 Android)
    if (kIsWeb || !Platform.isIOS) {
      debugPrint('[Icp] 跳過平臺');
      return "";
    }

    // 判定有效的語系是否為簡體中文
    // 如果是自動(null)，則看系統語系；如果是手動，則看手動設定的語系
    bool isEffectiveChs = (locale == null) ? sysIsChs : chkLocaleChs(locale);

    // 綜合判定：有效語系是簡中 && 時區是中國 && 地區是中國
    if (isEffectiveChs && tzIsChs && regionIsChs) {
      debugPrint('[Icp] 顯示 ICP: ${Flavor.cnICPfiling}');
      return "\n${Flavor.cnICPfiling}";
    }

    debugPrint('[Icp] 不顯示');
    return "";
  }

  /// 判斷系統語系是否為簡體中文。
  ///
  /// 判斷條件為：
  /// - `languageCode` 為 `zh`，且
  /// - `scriptCode` 為 `Hans`，或 `countryCode` 為 `CN`。
  ///
  /// 回傳 `true` 代表系統語系符合簡體中文條件。
  bool chkSysIsChs() {
    bool sysischs = false;
    Locale systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'zh') {
      if (systemLocale.scriptCode == 'Hans' ||
          systemLocale.countryCode == 'CN') {
        sysischs = true;
      }
    }
    debugPrint(
      '[Icp] 系統語系: languageCode=${systemLocale.languageCode}, scriptCode=${systemLocale.scriptCode}, countryCode=${systemLocale.countryCode}, sysIsChs=$sysischs',
    );
    return sysischs;
  }

  /// 判斷指定語系是否為簡體中文。
  ///
  /// [locale] 為欲檢查的語系設定。
  ///
  /// 判斷條件為：
  /// - `languageCode` 為 `zh`，且
  /// - `scriptCode` 為 `Hans`，或 `countryCode` 為 `CN`。
  ///
  /// 當 [locale] 為 `null` 時，直接回傳 `false`。
  bool chkLocaleChs(Locale? locale) {
    bool localechs = false;

    if (locale == null) {
      debugPrint('[Icp] Locale: null');
      return localechs;
    }

    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hans' || locale.countryCode == 'CN') {
        localechs = true;
      }
    }

    debugPrint(
      '[Icp] 語系: languageCode=${locale.languageCode}, scriptCode=${locale.scriptCode}, countryCode=${locale.countryCode}, localeIsChs=$localechs',
    );
    return localechs;
  }

  /// 依平台語系名稱判斷裝置地區是否可能為中國。
  ///
  /// 此方法透過 [Platform.localeName] 是否包含 `CN` 進行簡易判定，
  /// 屬於輕量級區域推測邏輯，而非嚴格地理定位。
  bool isCN() {
    final String locale = Platform.localeName;
    final bool result = locale.contains('CN');
    debugPrint('[Icp] 地區: Platform.localeName=$locale, regionIsChs=$result');
    return result;
  }

  /// 判斷目前裝置時區是否符合中國時區特徵。
  ///
  /// 判斷條件包含：
  /// - 時區名稱為 `Asia/Shanghai`。
  /// - 或目前時區偏移量為 UTC+8。
  ///
  /// 只要任一條件成立，即回傳 `true`。
  Future<bool> isCNTimeZone() async {
    final TimezoneInfo currentTimezone =
        await FlutterTimezone.getLocalTimezone();
    String timeZoneID = currentTimezone.identifier;
    bool isShanghaiTz = (timeZoneID == "Asia/Shanghai");
    bool isPlusEight = DateTime.now().timeZoneOffset.inHours == 8;
    final bool result = isShanghaiTz || isPlusEight;

    debugPrint(
      '[Icp] 時區: timeZoneID=$timeZoneID, isShanghaiTz=$isShanghaiTz, isPlusEight=$isPlusEight, tzIsChs=$result',
    );

    return result;
  }
}
