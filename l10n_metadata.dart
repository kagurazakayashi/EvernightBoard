import 'dart:io';
import 'dart:convert';
import 'dart:collection';

/// 腳本功能：解決 lib/l10n/app_*.arb 的 “The message with key "locale" does not have metadata defined.” 警告。
/// 1. 讀取 `lib/l10n/` 目錄下的所有 `app_*.arb` 檔案。
/// 2. 將 `app_zh.arb` 的 description 設為 `app_en.arb` 的對應 value。
/// 3. 將其他 `.arb` 檔案的 description 設為 `app_zh.arb` 的對應 value。
/// 4. 針對所有非 `@` 開頭的 key 進行字母排序。
/// 5. 將對應的 metadata (`@key`) 緊接在對應的 key 之後，並覆寫/新增 description。
/// 執行： dart l10n_metadata.dart

void main() async {
  stdout.writeln('[INFO] Starting ARB metadata generation script...');

  // 定義 l10n 資料夾路徑 (定義專案中的 l10n 目錄路徑)
  final Directory l10nDir = Directory('lib/l10n');

  if (!await l10nDir.exists()) {
    stderr.writeln(
      '[ERROR] Directory "lib/l10n" does not exist. Please run this script from the project root.',
    );
    exit(1);
  }

  // 取得所有 app_*.arb 檔案 (過濾出所有符合命名規則的檔案)
  final List<File> arbFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb') && file.path.contains('app_'))
      .toList();

  if (arbFiles.isEmpty) {
    stdout.writeln('[WARN] No "app_*.arb" files found in "lib/l10n". Exiting.');
    return;
  }

  // 預先載入 en 和 zh 的資料，作為 description 的參考來源 (預載英文與中文的字典檔作為參考基礎)
  Map<String, dynamic> enData = {};
  Map<String, dynamic> zhData = {};

  final File enFile = File('lib/l10n/app_en.arb');
  final File zhFile = File('lib/l10n/app_zh.arb');

  if (await enFile.exists()) {
    enData = jsonDecode(await enFile.readAsString());
    stdout.writeln('[INFO] Loaded base EN data from ${enFile.path}');
  } else {
    stdout.writeln(
      '[WARN] "app_en.arb" not found. zh descriptions might be empty.',
    );
  }

  if (await zhFile.exists()) {
    zhData = jsonDecode(await zhFile.readAsString());
    stdout.writeln('[INFO] Loaded base ZH data from ${zhFile.path}');
  } else {
    stdout.writeln(
      '[WARN] "app_zh.arb" not found. Other locales descriptions might be empty.',
    );
  }

  // 處理每一個 arb 檔案 (逐一處理每個多國語系檔案)
  for (final File file in arbFiles) {
    final String fileName = file.uri.pathSegments.last;
    stdout.writeln('\n[INFO] Processing file: $fileName');

    final String content = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(content);

    // 分離全域 metadata (例如 @@locale) 與一般的 keys (分離全域設定與翻譯鍵值)
    final Map<String, dynamic> globalMetadata = {};
    final List<String> translationKeys = [];

    jsonData.forEach((key, value) {
      if (key.startsWith('@@')) {
        globalMetadata[key] = value;
      } else if (!key.startsWith('@')) {
        translationKeys.add(key);
      }
    });

    // 針對翻譯鍵進行字母排序 (將一般的 key 依字母順序排列)
    translationKeys.sort();
    stdout.writeln('[INFO] Sorted ${translationKeys.length} keys in $fileName');

    // 使用 LinkedHashMap 來保持插入順序 (建立新的 Map 並確保寫入順序)
    final LinkedHashMap<String, dynamic> newJsonData =
        LinkedHashMap<String, dynamic>();

    // 1. 首先放入全域 metadata (先寫入 @@ 開頭的全域設定)
    globalMetadata.forEach((key, value) {
      newJsonData[key] = value;
    });

    // 2. 依序放入排序後的 keys 以及它們的 metadata (依序寫入鍵值及對應的 @metadata)
    int updatedDescriptionsCount = 0;

    for (final String key in translationKeys) {
      // 寫入翻譯鍵與值 (寫入原始翻譯字串)
      newJsonData[key] = jsonData[key];

      // 決定這個 key 應該使用的 description 來源 (判斷該從哪裡取得 description)
      String targetDescription = '';
      if (fileName == 'app_zh.arb') {
        // zh 的 description 來自 en 的 value
        targetDescription = enData[key] is String ? enData[key] : '';
      } else {
        // 其他語言 (包含 en) 的 description 來自 zh 的 value
        targetDescription = zhData[key] is String ? zhData[key] : '';
      }

      // 取得現有的 metadata 或建立新的 Map (保留原有的 placeholders 等設定)
      final String metaKey = '@$key';
      Map<String, dynamic> currentMetadata = {};
      if (jsonData.containsKey(metaKey) && jsonData[metaKey] is Map) {
        currentMetadata = Map<String, dynamic>.from(jsonData[metaKey]);
      }

      // 覆寫或新增 description (寫入或更新 description 欄位)
      if (targetDescription.isNotEmpty) {
        currentMetadata['description'] = targetDescription;
        updatedDescriptionsCount++;
      } else if (!currentMetadata.containsKey('description')) {
        // 若找不到參考值，給予預設提示避免警告 (避免 Flutter 繼續報錯)
        currentMetadata['description'] = 'No description provided';
      }

      // 將 metadata 緊接在 key 之後寫入 (將 @key 緊跟在 key 後方寫入)
      newJsonData[metaKey] = currentMetadata;
    }

    // 將處理後的資料轉換回格式化的 JSON 字串 (使用兩個空格進行排版)
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String newContent = encoder.convert(newJsonData);

    // 覆寫回原檔案 (將結果儲存回硬碟)
    await file.writeAsString(newContent);
    stdout.writeln(
      '[SUCCESS] Saved $fileName. Updated $updatedDescriptionsCount descriptions.',
    );
  }

  stdout.writeln('\n[INFO] All ARB files processed successfully!');
}
