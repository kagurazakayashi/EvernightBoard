# EvernightBoard 長夜錦書

![EvernightBoard](assets/appicon/icon.ico)

[English](README.md) | [简体中文](README.zh-Hans.md) | **繁體中文** | [日本語](README.ja.md)

**攬長夜之錦字，化萬語為此間。**

長夜錦書(EvernightBoard) 是一款透過預設圖文，在觸控螢幕和語言交流都受限時為您延續溝通的展示輔助工具。

[下載](https://github.com/kagurazakayashi/EvernightBoard/releases) | [在瀏覽器中線上體驗](https://kagurazakayashi.github.io/EvernightBoard/)

本應用程式並未以「官方版」名義發布到任何應用商店。一些網友可能會在取得授權或未取得授權的情況下，以他們自己的開發者名稱將其發布到應用商店。我不介意在取得授權的情況下這麼做，但也因此，一般而言，只有 [Releases](https://github.com/kagurazakayashi/EvernightBoard/releases) 中提供的二進位檔可視為「官方版」，且只有 [Issues](https://github.com/kagurazakayashi/EvernightBoard/issues) 可視為最佳的意見回饋管道。

## 應用場景

`(￣▽￣)"` _使用觸控螢幕困難且說話也困難這種情境……什麼時候會有這種情境啊？_

- 在使用手套等**觸控螢幕精準度極低**或**無法使用觸控螢幕**，同時言語交流受限的時候，使用預設的大型文字或圖片，快速向他人傳達資訊。
- 在台下向台上展示提示詞。
- 單純需要在螢幕上以大字顯示文字訊息或圖片，並能操作換頁的情境。

### 支援的換頁方式

- **使用導覽列中的圖示按鈕切換螢幕**：最常規的換頁方式。
  - 直向狀態下，導覽列會自動移到手機略微傾斜的一側，以便左右手都可以輕鬆用拇指夠到；
  - 橫向狀態下，導覽列會始終在最下方。
- **觸控半邊螢幕切換螢幕**：只需要非常粗略的觸控精度就可以準確翻頁。
  - 直向為上半部分和下半部分；
  - 橫向為左半部分和右半部分。
- **按音量按鈕換頁**：實體按鈕是你最靠譜的後盾。需要在軟體設定中個別開啟。

## 使用方法

### 準備工作

1. 啟動 APP 後，可以看到空白內容和一個初始標籤（**新螢幕**）。可以看到有兩個區域：
   1. **導覽列區域**：內含多個可自行修改和新增的按鈕，每個按鈕代表一個「**螢幕**」。
   2. **空白區域**：即當前「**螢幕**」，你可以指定它顯示文字或圖片。
2. 按下**當前選中的**標籤（如果是第一次使用，即是唯一的那一個），可以打開選單。選單中包括以下項目：
   1. **導覽列標籤相關**（淡藍色）
      1. **側邊欄圖示**：可以更換側邊欄中當前項目的圖示，你可以從打開的圖示庫中選擇一個。
      2. **側邊欄標題**：圖示下方的標籤，不支援換行，且內容建議盡可能簡短。
   2. **導覽列標籤順序調整**（綠色）
      1. **上移**：將此圖示在導覽列中移動到前一個位置，若已在最前則自動移動到最後。
      2. **下移**：將此圖示在導覽列中移動到後一個位置，若已在最後則自動移動到最前。
   3. **設定當前螢幕內容**（橘色）
      1. **設為文字**：當前螢幕將顯示一段你設定的文字，支援換行，文字將自動填滿並最大化顯示。
      2. **設為圖片**：當前螢幕將顯示一張你設定的圖片，注意圖片檔案不要太大，以免浪費執行記憶體（RAM）。
   4. **設定顏色**（粉紅色）：此處調整的顏色對**位於當前螢幕**的導覽列也有效。
      1. **文字顏色**：設定當前螢幕**文字模式**的文字顏色，以及當前螢幕導覽列的文字顏色。
      2. **背景顏色**：設定當前螢幕的背景顏色，以及當前螢幕導覽列的背景顏色。請小心不要將背景設為與文字相同的顏色。
   5. **新增或刪除螢幕**（藍色）
      1. **新增螢幕**：建立一個新螢幕，你可以點擊導覽列中新的螢幕按鈕切換至該螢幕，**再次點擊**即可打開選單進行編輯。
      2. **複製螢幕**：將當前螢幕複製到一個新螢幕，包含文字、圖片與顏色設定。
   6. **刪除螢幕**（紅色）：將移除當前螢幕，且會遺失當前螢幕的所有內容。
   7. **應用程式設定**（灰色）：顯示更多功能。
      1. 翻頁互動
         1. **點擊半螢幕翻頁**開關：開啟後可按半邊螢幕切換螢幕（縱向為上半部與下半部，橫向為左半部與右半部）。
         2. **音量鍵翻頁**開關：使用裝置的音量按鈕來切換螢幕，適用於完全無法使用觸控螢幕的場合。
      2. 導覽列位置
         1. **橫向狀態下**的導覽列位置：
            1. **始終在底端**（此為預設值）。
            2. 你也可以修改為：始終在頂端、始終在左側、始終在右側。
         2. **縱向狀態下**的導覽列位置：
            1. **自動移至微傾斜側**（此為預設值）：導覽列會自動移至手機略微傾斜的一側（左側或右側），以便左右手都能輕鬆用拇指操作。
            2. 你也可以修改為：始終在頂端、始終在左側、始終在右側、始終在底端。
      3. 配置管理：分配**螢幕設定**與**數據設定**。
         1. **匯出配置**：將**螢幕配置**匯出為 JSON 檔案。若含有圖片將會嵌入，導致匯出檔案顯著變大。
         2. **匯入配置**：從 JSON 檔案匯入**螢幕配置**，建議僅匯入相同版本 APP 的配置。
         3. **恢復出廠設定**：清空所有**螢幕設定**與**軟體設定**。
      4. 說明與資訊
         1. **使用說明**：閱讀使用說明 `README.md`
         2. **關於**：開啟關於視窗，查看作者與版本資訊。
            1. **使用說明**、**問題回饋**、**原始碼**：開啟瀏覽器造訪相關網頁。
            2. **查看授權協議**：列出本軟體及本軟體使用的所有第三方函式庫的許可協議。
         3. **結束程式**：完全結束程式，釋放執行記憶體，不會在背景留存。

#### 其他建議

- 在不便操作的場合，暫時停用手機的鎖定螢幕功能，並將應用程式圖示放在主畫面或易於啟動的位置，可以讓您更輕鬆地回到本程式的畫面。
- 應用程式完整支援 TalkBack 與 VoiceOver，可以使用它們朗讀文字。

### 開始使用

按照上面的準備工作準備好多個預設的圖片或文字之後，即可在以下場合輕鬆向別人告知預設的資訊。

1. 觸控螢幕精準度極低的場合：按半邊螢幕切換螢幕。
2. 完全無法使用觸控螢幕的場合：使用音量按鈕切換螢幕。

#### 螢幕設定範例

1. 「你好」
2. 「我可以和你合照嗎」
3. 「看那邊，他來拍照」
4. 「謝謝」
5. 「你很好看」
6. 「我想去那邊」
7. 「我想去和他合照」
8. 「抱歉，我沒有聽清楚」
9. 「我沒辦法說話」
10. 「交給我吧」
11. 「我想休息一會」
12. 「看一下群組裡的訊息」
13. 「我的相機要沒電了」
14. 「我的手機要沒電了」
15. (社群帳號 QR Code)

`^ ✪ ω ✪ ^` _所以你猜這款應用程式最初是為了什麼情境而設計的？_

## 隱私權

本程式完全開源、免費，並且尊重您的隱私。

本程式僅會在以下場景使用權限，且您可以在系統中禁用其所有權限。

- **唯讀**存取您的相簿或檔案系統：
  - 匯入圖片時。
  - 匯入設定檔時。
- **寫入**您的檔案系統：
  - 匯出設定檔時。
- 網路連線：
  - **本程式不會產生任何網路連線。**為了防止供應鏈攻擊或程式包被修改，建議您直接在作業系統中完全禁用本應用程式的網路連線權限。
  - 「關於」中的 URL 連結會在瀏覽器中開啟網頁。

## 編譯

### 環境需求

1. Flutter：您可以在 `pubspec.yaml` 檔案中 `dependencies:flutter:` 處的註解看到最佳的 Flutter 版本。
2. 執行 `flutter doctor` 指令，根據提示完成各種配置。
3. `cd` 進入本專案所在的資料夾。

### 偵錯

1. 執行 `flutter clean` 清理快取。
2. 執行 `flutter pub get` 下載所需的第三方套件。
3. 執行 `generate_icons.bat`（Windows）或 `./generate_icons.sh` 產生各種規格與樣式的應用程式圖示。
4. 執行 `dart run flutter_native_splash:create` 建立啟動畫面。
5. 執行 `flutter gen-l10n` 建立多語系文字。
6. 執行 `dart run flutter_iconpicker:generate_packs --packs material` 準備圖示資源。
7. 執行 `flutter run` 開始偵錯。

- 如果需要編輯原始碼，必須在啟動 IDE 前完成第 1 步到第 5 步。
- 如果需要執行編譯，必須在執行編譯指令前完成第 1 步到第 6 步。
  - 你可以執行 `build_pre.bat`（Windows）或 `./build_pre.sh` 直接完成這些步驟。

### 編輯顯示語言

1. 修改或依格式新增 `lib/l10n/app_*.arb`（`*` 為語言代碼）。
2. 此檔案為 JSON 格式。若要新增語言文字，只需要按照 `"變數名稱":"新語言文字"` 的格式設定即可。注意：
   1. 每個語言文字只需要這一行，例如 `"textcolor": "文字顏色",`，不需要後面的 `"@textcolor": ...` 部分。
   2. 變數名稱必須與其他語言檔案一樣完整。
3. 執行 `dart l10n_metadata.dart` 自動補齊所有語言檔案中的 `"@..."` 部分。
4. 執行 `flutter gen-l10n` 建立多語系文字。
5. 繼續上述的 [偵錯](#偵錯) 步驟。

### 發佈渠道差異

- 渠道變數用於在不同渠道發佈軟體時，根據特定渠道顯示對應的內容。
- 若要使用渠道變數，請在 `flutter run` 和 `flutter build` 指令最後加入：
  - `--dart-define-from-file="flavor/*.json"`
- 渠道設定檔位於 `flavor/` 資料夾中。

如果要在中國的應用程式商店中提供本程式，你必須持有 ICP 備案號，並將其填入對應平台的 `"cnICPfiling":""` 中。詳情請參閱 [App Store Connect Help 中關於 Availability in China mainland](https://developer.apple.com/help/app-store-connect/reference/app-information) 的相關內容。

### 在 Windows 中編譯

- 編譯為 Windows 應用程式並執行：`build.bat`。
- 編譯為 Android 應用程式並安裝：`build_apk.bat`。

#### 手動編譯為 Windows（需要在 Windows 中操作）

1. 執行上方 [偵錯](#偵錯) 中的第 1 步到第 6 步。你可以執行 `build_pre.bat` 直接完成這些步驟。
2. 使用 `RD /S /Q build\windows` 刪除上次編譯的檔案。
3. 執行編譯命令：
   - 編譯為 exe 程式：`flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"`。
     - 建立用於本機安裝的 exe 安裝套件：`"%ProgramFiles(x86)%\NSIS\makensis.exe" installer.nsi`
   - 編譯為用於 Microsoft Store 的發行版：
     1. 編譯 exe 程式：`flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/msstore.json"`
     2. 處理 NOTICES.Z 警告：`DEL "build\flutter_assets\*.Z" "build\windows\x64\runner\Release\data\flutter_assets\*.Z"`
     3. 建立用於 Microsoft Store 發佈的 msix 安裝套件：`dart.bat run msix:create`。
     4. 可以使用 `Windows App Cert Kit` 驗證該 msix 安裝套件。
4. 查看產生的檔案：`DIR "%CD%\build\windows\x64\runner\Release"`。
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.exe"`
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.msix"`

### 在 macOS 或 Linux 中編譯

- 編譯為 macOS 或 Linux 應用程式並執行：`./build.sh`。
- 編譯為 Android 應用程式並安裝：`./build_apk.sh`。

### 手動編譯為 macOS 或 iOS（需要在 macOS 中操作）

1. 執行上方 [偵錯](#偵錯) 中的第 1 步到第 6 步。你可以執行 `./build_pre.sh` 直接完成這些步驟。
2. 執行編譯命令（這可能會失敗，不用理會）。
   - 編譯為 macOS 程式：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/macos.json"`
   - 編譯為 iOS 程式：`flutter build ios --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"`
   - 編譯為用於 macOS App Store 的發行版：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
   - 編譯為用於 iOS App Store 的發行版：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
3. 執行 `cd macos` 或 `cd ios` 進入對應的平台資料夾。
4. 執行 `pod install` 下載所需的第三方函式庫。
5. 執行 Xcode，開啟 `macos` 或 `ios` 資料夾中的 `Runner.xcworkspace` 進行設定（例如憑證和描述檔）。
6. 進行正式編譯。

### 手動編譯為 Android

1. 執行上方 [偵錯](#偵錯) 中的第 1 步到第 6 步。你可以執行 `build_pre.bat`（Windows）或 `./build_pre.sh` 直接完成這些步驟。
2. 使用 `RD /S /Q build\app`（Windows）或 `rm -rf build/app` 刪除上次編譯產生的檔案。
3. 執行編譯命令：
   - 編譯為 apk 安裝套件：`flutter build apk --no-tree-shake-icons --dart-define-from-file="flavor/android.json"`。
   - 編譯為用於 Google Play 的發布版本：`flutter build aab --no-tree-shake-icons --dart-define-from-file="flavor/googleplay.json"`。
4. 檢視產生的檔案：
   - Windows：`DIR "build\app\outputs\flutter-apk"`。
     - `ECHO "%CD%\build\app\outputs\flutter-apk\app-release.apk"`
     - `ECHO "%CD%\build\app\outputs\bundle\release\app-release.aab"`
   - macOS、Linux：`ls "build/app/outputs/flutter-apk"`
     - `ls -d "$PWD/build/app/outputs/flutter-apk/app-release.apk"`
     - `ls -d "$PWD/build/app/outputs/bundle/release/app-release.aab"`

### 手動編譯為 Web

1. 執行上方 [偵錯](#偵錯) 中的第 1 步到第 6 步。你可以執行 `build_pre.bat`（Windows）或 `./build_pre.sh` 直接完成這些步驟。
2. 使用 `RD /S /Q build\web`（Windows）或 `rm -rf build/web` 刪除上次編譯產生的檔案。
3. 使用 `flutter build web --wasm --no-tree-shake-icons --base-href "/EvernightBoard/" --dart-define-from-file="flavor/web.json"` 進行編譯。

- 如需相容舊版瀏覽器，請移除 `--wasm`。
- 可以將 `"/EvernightBoard/"` 改為所需的 URL 根路徑。

### 手動編譯為 Linux（需要在 Linux 中操作）

1. 執行上方 [偵錯](#偵錯) 中的第 1 步到第 6 步。你可以執行 `./build_pre.sh` 直接完成這些步驟。
2. 使用 `rm -rf build/linux` 刪除上次編譯產生的檔案。
3. 使用 `flutter build linux --no-tree-shake-icons --dart-define-from-file="flavor/linux.json"` 進行編譯。
4. 檢視產生的檔案：`ls "build/linux/x64/release/bundle"`
   - `ls -d "$PWD/build/linux/x64/release/bundle/evernight_board"`
   - 如果執行時顯示傾印或其他畫面異常，請嘗試 `LIBGL_ALWAYS_SOFTWARE=1 "$PWD/build/linux/x64/release/bundle/evernight_board"`。

## 授權條款

```LICENSE
Copyright (c) 2026 KagurazakaYashi(KagurazakaMiyabi)
EvernightBoard is licensed under Mulan PSL v2.
You can use this software according to the terms and conditions of the Mulan PSL v2.
You may obtain a copy of Mulan PSL v2 at:
         http://license.coscl.org.cn/MulanPSL2
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
See the Mulan PSL v2 for more details.
```
