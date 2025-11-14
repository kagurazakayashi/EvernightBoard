# EvernightBoard 長夜錦書

![EvernightBoard](assets/appicon/icon.ico)

[English](README.md) | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md) | **日本語**

**常夜（とこよ）の錦言（きんげん）を綴（つづ）り、万言（ばんげん）をこの空間に。**

長夜錦書(EvernightBoard) は、事前に設定した画像やテキストを通じて、タッチパネルの操作や言葉でのコミュニケーションが制限されている状況において、コミュニケーションを継続するための表示補助ツールです。

[ダウンロード](https://github.com/kagurazakayashi/EvernightBoard/releases) | [ブラウザでオンライン体験](https://kagurazakayashi.github.io/EvernightBoard/)

このアプリケーションは、いかなるアプリストアにも「公式版」として公開されていません。一部のユーザーが、許可を得た場合または得ていない場合に、自身の開発者名義でアプリストアへ公開することがあります。許可を得たうえであれば私はそれを問題にしませんが、そのため、通常は [Releases](https://github.com/kagurazakayashi/EvernightBoard/releases) にあるバイナリのみを「公式版」と見なし、また [Issues](https://github.com/kagurazakayashi/EvernightBoard/issues) のみを最適なフィードバック窓口と見なしてください。

## 利用シーン

`(￣▽￣)"` _タッチパネルの使用が困難で、かつ話すことも困難な状況……どのような時にそのような場面があるのでしょうか？_

- 手袋を着用しているなどの理由で**タッチパネルの精度が極端に低い**、または**タッチパネルが使用できない**状態で、かつ会話によるコミュニケーションが制限されている場合、事前設定した大きな文字や画像を使用して、素早く他人に情報を伝えます。
- ステージ下からステージ上へプロンプトを提示する。
- 単純に画面に大きなテキストや画像を表示し、ページめくり操作を行いたいシーン。

### 対応するページめくり方法

- **ナビゲーションバーのアイコンボタンで画面を切り替える**：最も一般的なページめくりの方法です。
  - 縦向きの状態では、ナビゲーションバーがスマートフォンのわずかに傾いた側に自動的に移動し、左右どちらの手でも親指で簡単に届くようになります。
  - 横向きの状態では、ナビゲーションバーは常に最下部に配置されます。
- **画面の半分をタッチして画面を切り替える**：大まかなタッチ精度でも正確にページをめくることができます。
  - 縦向きの場合は上半分と下半分。
  - 横向きの場合は左半分と右半分。
- **音量ボタンでページをめくる**：物理ボタンは最も信頼できるバックアップです。ソフトウェア設定で個別に有効にする必要があります。

## 使用方法

### 準備

1. アプリを起動すると、空白のコンテンツと初期タブ（**新しい画面**）が表示されます。主に2つの領域があります：
   1. **ナビゲーションバー領域**：自由に変更・追加できる複数のボタンがあり、各ボタンが1つの「**画面**」を表します。
   2. **空白領域**：現在の「**画面**」です。ここにテキストまたは画像を表示するように指定できます。
2. **現在選択されている**タブ（初回使用時は唯一のタブ）をタップすると、メニューが開きます。メニューには以下の項目が含まれます：
   1. **ナビゲーションタブ関連**（水色）
      1. **サイドバーアイコン**：サイドバーの現在の項目のアイコンを変更できます。アイコンライブラリから選択してください。
      2. **サイドバータイトル**：アイコンの下のラベルです。改行はサポートされておらず、できるだけ短くすることをお勧めします。
   2. **ナビゲーションタブの順序調整**（緑色）
      1. **上へ移動**：このアイコンをナビゲーションバーの前の位置に移動します。先頭にある場合は自動的に最後尾に移動します。
      2. **下へ移動**：このアイコンをナビゲーションバーの次の位置に移動します。最後尾にある場合は自動的に先頭に移動します。
   3. **現在の画面内容の設定**（オレンジ色）
      1. **テキストに設定**：現在の画面に設定したテキストを表示します。改行に対応しており、テキストは自動的に最大化して表示されます。
      2. **画像に設定**：現在の画面に設定した画像を表示します。メモリ（RAM）の浪費を避けるため、画像ファイルが大きすぎないように注意してください。
   4. **色の設定**（ピンク色）：ここでの色の調整は、**現在の画面にある**ナビゲーションバーにも適用されます。
      1. **文字色**：現在の画面の**テキストモード**の文字色と、現在のナビゲーションバーの文字色を設定します。
      2. **背景色**：現在の画面の背景色と、現在のナビゲーションバーの背景色を設定します。文字と同じ色にしないよう注意してください。
   5. **画面の追加または削除**（青色）
      1. **新規画面を追加**：新しい画面を作成します。ナビゲーションバーの新しいボタンをタップして切り替え、**もう一度タップ**すると編集メニューが開きます。
      2. **画面をコピー**：現在の画面（テキスト/画像/色を含む）を新しい画面にコピーします。
   6. **画面を削除**（赤色）：現在の画面を削除します。現在の画面のすべての内容が失われます。
   7. **アプリ設定**（灰色）：さらに多くの機能を表示します。
      1. ページめくり操作
         1. **ハーフスクリーンめくり**スイッチ：オンにすると、画面の半分をタップして画面を切り替えられます（縦向きは上下、横向きは左右）。
         2. **音量キーめくり**スイッチ：デバイスの音量ボタンを使用して画面を切り替えます。タッチパネルが使用できない場合に適しています。
      2. ナビゲーションバーの位置
         1. **横向き時**のナビゲーションバーの位置：
            1. **常に下部**（デフォルト）。
            2. 上部、左側、右側に固定することも可能です。
         2. **縦向き時**のナビゲーションバーの位置：
            1. **わずかに傾いた側に自動移動**（デフォルト）：親指で届きやすいよう、スマホがわずかに傾いている側（左または右）に自動的に移動します。
            2. 上部、左側、右側、下部に固定することも可能です。
      3. 設定管理：**画面設定**と**データ設定**の管理。
         1. **設定をエクスポート**：**画面設定**を JSON ファイルに書き出します。画像が含まれる場合は埋め込まれるため、ファイルサイズが大幅に大きくなります。
         2. **設定をインポート**：JSON ファイルから**画面設定**を読み込みます。同じバージョンのアプリの設定のみをインポートすることをお勧めします。
         3. **工場出荷時設定にリセット**：すべての**画面設定**と**アプリ設定**を消去します。
      4. ヘルプと情報
         1. **使用説明書**：使用説明書 `README.md` を読む。
         2. **バージョン情報**：バージョン情報ウィンドウを開き、作成者とバージョン情報を確認する。
            1. **使用説明書**、**フィードバック**、**ソースコード**：ブラウザを開いて関連ページにアクセスする。
            2. **ライセンスの表示**：本ソフトウェアおよび本ソフトウェアが使用するすべてのサードパーティライブラリのライセンス規約を一覧表示する。
         3. **プログラムの終了**：プログラムを完全に終了し、メモリを解放します。バックグラウンドには残りません。

#### その他の推奨事項

- 操作が不便な状況において、スマートフォンのロック画面機能を一時的に無効化し、アプリのアイコンをホーム画面や起動しやすい場所に配置することで、本プログラムの画面へより簡単に戻れるようになります。
- アプリは TalkBack と VoiceOver をフルサポートしており、これらを使用してテキストを読み上げることができます。

### 使い始める

上記の準備作業に従って複数の画像やテキストを事前設定した後、以下の状況で事前設定した情報を他の人に簡単に伝えることができます。

1. タッチパネルの精度が極端に低い場合：画面の半分をタップして画面を切り替えます。
2. タッチパネルがまったく使用できない場合：音量ボタンを使用して画面を切り替えます。

#### 画面設定例

1. 「こんにちは」
2. 「一緒に写真を撮ってもいいですか」
3. 「あっちを見て、彼が写真を撮りに来たよ」
4. 「ありがとう」
5. 「かっこいいですね/かわいいですね」
6. 「あっちに行きたい」
7. 「彼と一緒に写真を撮りたい」
8. 「ごめんなさい、よく聞こえませんでした」
9. 「話すことができません」
10. 「私に任せてください」
11. 「少し休憩したいです」
12. 「グループのメッセージを見てください」
13. 「カメラのバッテリーが切れそうです」
14. 「スマホのバッテリーが切れそうです」
15. (SNSアカウントのQRコード)

`^ ✪ ω ✪ ^` _さて、このアプリはもともとどのようなシーンを想定して設計されたと思いますか？_

### トラブルシューティング

Windows:

- Q: 「このアプリはお使いの PC では実行できません」または「イメージファイルが無効です」というメッセージが表示されます。
  - A: このプログラムは、Windows 10 以降の 64 ビット x86 プロセッサでのみ動作します。ARM プロセッサおよび 32 ビット以下のプロセッサには対応していません。

macOS:

- Q: 「開発元を検証できないため、開けません」というメッセージが表示されます。
  - A: 「システム環境設定」の「セキュリティとプライバシー」を開き、「一般」タブに切り替えて「すべてのアプリケーションを許可」にチェックを入れてから、再度実行してください。そこに「開発元が未確認のため開けませんでした」と表示されている場合は、「このまま開く」ボタンを押してください。
- Q: 起動時にクラッシュし、クラッシュ情報に `codesign` 関連の内容が含まれています。
  - A: ローカルでの再署名を試みてください。コマンドは `codesign --force --deep --sign - evernight_board.app` です。コマンドが利用できない場合は、先に `xcode-select --install` を実行して Xcode をインストールしてください。

Linux:

- Q: 設定のインポートまたはエクスポート時にファイルダイアログが開かず、「システムに必要なコンポーネントが不足しています」と表示されます。
  - A: XDG Desktop Portal とそのバックエンドをインストールする必要があります。Arch Linux を例に説明します：
    1. メインサービスのインストール: `sudo pacman -S xdg-desktop-portal`
    2. デスクトップ環境に合わせてバックエンドを選択: `sudo pacman -S xdg-desktop-portal-gtk (xdg-desktop-portal-kde / xdg-desktop-portal-wlr / ...)`
    3. サービスの起動: `systemctl --user enable xdg-desktop-portal && systemctl --user start xdg-desktop-portal`
- Q: プログラムの画面表示が傾いている、または画面やアニメーションの表示が不完全・異常です。
  - A: `LIBGL_ALWAYS_SOFTWARE=1 ./evernight_board` を試してみてください。

## プライバシー

本プログラムは完全にオープンソースかつ無料で、お客様のプライバシーを尊重します。

本プログラムは以下のシナリオにおいてのみ権限を使用し、システム設定ですべての権限を無効にすることができます。

- フォトライブラリまたはファイルシステムへの**読み取り専用**アクセス：
  - 画像をインポートする場合。
  - 設定ファイルをインポートする場合。
- ファイルシステムへの**書き込み**：
  - 設定ファイルをエクスポートする場合。
- ネットワーク接続：
  - **本プログラムはいかなるネットワーク接続も行いません。**サプライチェーン攻撃やパッケージの改ざんを防止するため、オペレーティングシステムの設定で本アプリのネットワーク接続権限を完全に無効にすることをお勧めします。
  - 「バージョン情報」内の URL リンクはブラウザでウェブページを開きます。

## コンパイル

### 環境要件

1. Flutter: `pubspec.yaml` ファイルの `dependencies:flutter:` セクションにあるコメントで、最適な Flutter バージョンを確認できます。
2. `flutter doctor` コマンドを実行し、プロンプトに従って各種設定を完了させてください。
3. `cd` コマンドで本プロジェクトのフォルダに移動します。

### デバッグ

1. `flutter clean` を実行してキャッシュを削除します。
2. `flutter pub get` を実行して、必要なサードパーティ製パッケージをダウンロードします。
3. `generate_icons.bat`（Windows）または `./generate_icons.sh` を実行して、さまざまなサイズとスタイルのアプリアイコンを生成します。
4. `dart run flutter_native_splash:create` を実行してスプラッシュ画面を作成します。
5. `flutter gen-l10n` を実行して多言語テキストを生成します。
6. `dart run flutter_iconpicker:generate_packs --packs material` を実行してアイコンリソースを準備します。
7. `flutter run` を実行してデバッグを開始します。

- ソースコードを編集する必要がある場合は、IDE を起動する前に手順 1 から手順 5 までを完了する必要があります。
- ビルドを実行する必要がある場合は、ビルドコマンドを実行する前に手順 1 から手順 6 までを完了する必要があります。
  - `build_pre.bat`（Windows）または `./build_pre.sh` を実行すると、これらの手順を直接完了できます。

### 表示言語の編集

1. `lib/l10n/app_*.arb`（`*` は言語コード）を変更するか、指定形式に従って新規作成します。
2. このファイルは JSON 形式です。言語テキストを追加するには、`"変数名":"新しい言語テキスト"` の形式で設定するだけです。注意：
   1. 各言語テキストにはこの 1 行だけが必要です。例：`"textcolor": "文字顏色",` 。後続の `"@textcolor": ...` 部分は不要です。
   2. 変数名は、他の言語ファイルと同じようにすべて揃っている必要があります。
3. `dart l10n_metadata.dart` を実行して、すべての言語ファイルの `"@..."` 部分を自動補完します。
4. `flutter gen-l10n` を実行して多言語テキストを生成します。
5. 上記の [デバッグ](#デバッグ) 手順を続行します。

### 配布チャネルの違い

- チャネル変数は、異なる配布チャネルでソフトウェアを配布する際に、特定のチャネルに応じた内容を表示するために使用されます。
- チャネル変数を使用するには、`flutter run` および `flutter build` コマンドの末尾に以下を追加します：
  - `--dart-define-from-file="flavor/*.json"`
- チャネル設定ファイルは `flavor/` フォルダにあります。

このアプリケーションを中国のアプリストアで提供する場合は、ICP 登録番号を取得し、対応するプラットフォームの `"cnICPfiling":""` に記入する必要があります。詳細については、[App Store Connect Help の Availability in China mainland](https://developer.apple.com/help/app-store-connect/reference/app-information) に関する項目をご確認ください。

### Windows でビルドする

- Windows アプリケーションとしてビルドして実行する：`build.bat` 。
- Android アプリケーションとしてビルドしてインストールする：`build_apk.bat` 。

#### Windows 向けに手動でビルドする（Windows 上で操作する必要があります）

1. 上記の [デバッグ](#デバッグ) の手順 1 から手順 6 までを実行します。`build_pre.bat` を実行すると、これらの手順を直接完了できます。
2. `RD /S /Q build\windows` を使用して、前回ビルドしたファイルを削除します。
3. ビルドコマンドを実行します：
   - exe プログラムとしてビルドする：`flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"` 。
     - ローカルインストール用の exe インストーラーを作成する：`"%ProgramFiles(x86)%\NSIS\makensis.exe" installer.nsi`
   - Microsoft Store 向けのリリース版としてビルドする：
     1. exe プログラムをビルドする：`flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/msstore.json"` 。
     2. NOTICES.Z 警告に対応する：`DEL /Q "build\flutter_assets\*.Z" "build\windows\x64\runner\Release\data\flutter_assets\*.Z"` 。
     3. Microsoft Store 公開用の msix インストーラーを作成する：`dart.bat run msix:create` 。
     4. `Windows App Cert Kit` を使用して、この msix インストーラーを検証できます。
4. 生成されたファイルを確認する：`DIR "%CD%\build\windows\x64\runner\Release"` 。
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.exe"`
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.msix"`

### macOS または Linux でビルドする

- macOS または Linux アプリケーションとしてビルドして実行する：`./build.sh` 。
- Android アプリケーションとしてビルドしてインストールする：`./build_apk.sh` 。

### macOS または iOS 向けに手動でビルドする（macOS 上で操作する必要があります）

1. 上記の [デバッグ](#デバッグ) の手順 1 から手順 6 までを実行します。`./build_pre.sh` を実行すると、これらの手順を直接完了できます。
2. ビルドコマンドを実行します（失敗する可能性がありますが、無視してかまいません）。
   - macOS プログラムとしてビルドする：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/macos.json"`
   - iOS プログラムとしてビルドする：`flutter build ios --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"`
   - macOS App Store 向けのリリース版としてビルドする：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
   - iOS App Store 向けのリリース版としてビルドする：`flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
3. `cd macos` または `cd ios` を実行して、対応するプラットフォームフォルダーに移動します。
4. `pod install` を実行して、必要なサードパーティ製ライブラリをダウンロードします。
5. Xcode を起動し、`macos` または `ios` フォルダー内の `Runner.xcworkspace` を開いて設定します（証明書やプロビジョニングプロファイルなど）。
6. 正式にビルドします。

### Android 向けに手動ビルドする

1. 上記の [デバッグ](#デバッグ) の手順 1 から手順 6 までを実行します。`build_pre.bat`（Windows）または `./build_pre.sh` を実行すると、これらの手順を直接完了できます。
2. `RD /S /Q build\app`（Windows）または `rm -rf build/app` を使用して、前回のビルドで生成されたファイルを削除します。
3. ビルドコマンドを実行します：
   - apk インストールパッケージとしてビルド：`flutter build apk --no-tree-shake-icons --dart-define-from-file="flavor/android.json"` 。
   - Google Play 向けのリリース版としてビルド：`flutter build aab --no-tree-shake-icons --dart-define-from-file="flavor/googleplay.json"` 。
4. 生成されたファイルを確認します：
   - Windows：`DIR "build\app\outputs\flutter-apk"` 。
     - `ECHO "%CD%\build\app\outputs\flutter-apk\app-release.apk"`
     - `ECHO "%CD%\build\app\outputs\bundle\release\app-release.aab"`
   - macOS、Linux：`ls "build/app/outputs/flutter-apk"`
     - `ls -d "$PWD/build/app/outputs/flutter-apk/app-release.apk"`
     - `ls -d "$PWD/build/app/outputs/bundle/release/app-release.aab"`

### Web 向けに手動ビルドする

1. 上記の [デバッグ](#デバッグ) の手順 1 から手順 6 までを実行します。`build_pre.bat`（Windows）または `./build_pre.sh` を実行すると、これらの手順を直接完了できます。
2. `RD /S /Q build\web`（Windows）または `rm -rf build/web` を使用して、前回のビルドで生成されたファイルを削除します。
3. `flutter build web --wasm --no-tree-shake-icons --base-href "/EvernightBoard/" --dart-define-from-file="flavor/web.json"` を使用してビルドします。

- 古いバージョンのブラウザーとの互換性が必要な場合は、`--wasm` を削除してください。
- `"/EvernightBoard/"` は、必要な URL ルートパスに変更できます。

### Linux 向けに手動ビルドする（Linux 上で操作する必要があります）

1. 上記の [デバッグ](#デバッグ) の手順 1 から手順 6 までを実行します。`./build_pre.sh` を実行すると、これらの手順を直接完了できます。
2. `rm -rf build/linux` を使用して、前回のビルドで生成されたファイルを削除します。
3. `flutter build linux --no-tree-shake-icons --dart-define-from-file="flavor/linux.json"` を使用してビルドします。
4. 生成されたファイルを確認します：`ls "build/linux/x64/release/bundle"`
   - `ls -d "$PWD/build/linux/x64/release/bundle/evernight_board"`
   - 実行時にコアダンプやその他の画面表示異常が発生する場合は、`LIBGL_ALWAYS_SOFTWARE=1 "$PWD/build/linux/x64/release/bundle/evernight_board"` を試してください。

### スタートメニュー項目とデスクトップショートカットの作成 (Windows または Linux での操作が必要)

`.\shortcuts.ps1` (Windows) または `./shortcuts.sh` (Linux) を使用して、スタートメニュー項目やデスクトップショートカットを作成できます。

1. スクリプトを実行する前に、以下のファイルが **同一のフォルダー** 内にあることを確認してください：
   - **Linux**: `shortcuts.sh` (スクリプト)、`icon.png` (アイコンファイル)、`evernight_board` (実行ファイル)。
   - **Windows**: `shortcuts.ps1` (スクリプト)、`evernight_board.exe` (実行ファイル)。
2. スクリプトに実行権限を付与する
   - **Linux**: 実行前にスクリプトに実行権限を付与してください: `chmod +x shortcuts.sh` 。
   - **Windows**: 実行前に PowerShell スクリプトの実行権限が有効であることを確認してください: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` 。

#### ショートカットスクリプトの使用方法

コマンド形式: `./スクリプト名 [アクション] [ターゲット] [モード]` 。

1. アクション
   - `add` (または `a`): ショートカットを作成します。
   - `remove` (または `r`): ショートカットを削除します。
2. ターゲット
   - `menu` (または `m`): システムアプリケーションメニュー (デフォルト)。
   - `desktop` (または `d`): デスクトップショートカット。
3. モード
   - `--user` (または `-u`): 現在のユーザーのみを対象とする (デフォルト)。
   - `--system` (または `-s`): システム全体にインストールする (管理者/Root 権限が必要)。

#### ショートカットスクリプトのコマンド例

Linux の `sh` 例:

- **現在のユーザー**に**メニュー項目**を追加する: `./shortcuts.sh add` 。
- **システム全体**に**メニュー項目**を追加する: `sudo ./shortcuts.sh add menu --system` 。
- **現在のユーザー**に**メニュー項目**と**デスクトップショートカット**を同時追加する: `./shortcuts.sh add menu desktop` 。
- **システム全体**に**メニュー項目**と**デスクトップショートカット**を同時追加する: `sudo ./shortcuts.sh add menu desktop --system` 。
- 現在のユーザーのメニュー項目を**削除**する: `./shortcuts.sh remove` 。
- システム全体のメニュー項目とデスクトップショートカットを**削除**する: `sudo ./shortcuts.sh remove menu --system` 。

Windows の `Windows PowerShell` 例:

- 上記の例の `./shortcuts.sh` を `.\shortcuts.ps1` に置き換えてください。
- 上記の例の `sudo ./shortcuts.sh` を **管理者として実行** したウィンドウでの `.\shortcuts.ps1` に置き換えてください。
- 例: `.\shortcuts.ps1 add menu desktop --system` 。

### ユニットテスト

- すべてのテストを実行: `flutter test`
- 単一のテストファイルを実行: `flutter test test/home_item_test.dart`
- 実行して詳細な出力を表示: `flutter test --reporter expanded`
- テストを実行してカバレッジレポートを生成: `flutter test --coverage`
- カバレッジを確認する (事前に lcov のインストールが必要): `genhtml coverage/lcov.info -o coverage/html`

テストファイルリスト:

- `test/home_item_test.dart` - HomeItem モデルの完全なテスト (toJson、fromJson、copyWith、シリアライズの往復)
- `test/home_controller_test.dart` - HomeController のテスト (ナビゲーション、インデックス切り替え、言語切り替え、設定、カラーユーティリティ)
- `test/file_service_test.dart` - FileService のテスト (境界条件、無効な入力の処理)
- `test/data_export_service_test.dart` - DataExportService のテスト (インポート/エクスポートの中止シナリオ)
- `test/restart_widget_test.dart` - RestartWidget コンポーネントのテスト (再構築機能)
- `test/snack_bar_utils_test.dart` - SnackBarUtils コンポーネントのテスト (成功/エラー通知、直前の通知の消去)

## ライセンス

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
