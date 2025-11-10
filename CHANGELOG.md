# CHANGELOG

## v1.0.0

- 有关该版本的使用说明，请参见源代码压缩包中的 README(en/ja/zh-Hans/zh-Hant).md 或应用程序内的“使用说明”。
- 以下所有软件包均需要 64 位处理器。
- 适用于 iOS 的 .ipa 程序的额外说明
  - 该程序包含 Ad-Hoc 签名，在安装前需要使用你自己的签名重新签名才能安装。
- 适用于 macOS 的额外说明
  - 该程序在 Apple silicon 和 Intel 处理器中均可使用。
  - 该程序包含正式签名，可以直接运行。但不确保签名始终有效，如果遇到安全阻止或者启动时崩溃，请尝试使用本机重签，命令是:
    - `codesign --force --deep --sign - evernight_board.app`
- 适用于 Linux 的额外说明
  - 请先使用 `chmod +x ./evernight_board` 给予执行权限。
  - 如果显示出现倾倒，请尝试 `LIBGL_ALWAYS_SOFTWARE=1 ./evernight_board` 。

- For usage instructions regarding this version, please refer to README(en/ja/zh-Hans/zh-Hant).md in the source code archive or the "Usage Instructions" within the application.
- All the following packages require a 64-bit processor.
- Additional notes for the iOS .ipa program:
  - This program contains an Ad-Hoc signature and must be re-signed with your own signature before installation.
- Additional notes for the macOS .app program:
  - This program is compatible with both Apple silicon and Intel processors.
  - This program includes an official signature and can be run directly. However, there is no guarantee that the signature will remain valid indefinitely. If you encounter security blocks or crashes on startup, please try local re-signing using the following command:
    - `codesign --force --deep --sign - evernight_board.app`
- Additional notes for the Linux program:
  - Please use `chmod +x ./evernight_board` to grant execution permissions first.
  - If the display appears corrupted or glitched, please try `LIBGL_ALWAYS_SOFTWARE=1 ./evernight_board`.

- 本バージョンの使用説明については、ソースコード圧縮パッケージ内の README(en/ja/zh-Hans/zh-Hant).md またはアプリ内の「使用説明」をご参照ください。
- 以下のすべてのパッケージは 64 ビットプロセッサを必要とします。
- iOS 用 .ipa プログラムに関する追加事項：
  - このプログラムにはアドホック（Ad-Hoc）署名が含まれています。インストール前にご自身の署名で再署名する必要があります。
- macOS 用 .app プログラムに関する追加事項：
  - このプログラムは、AppleシリコンとIntelプロセッサの両方で動作可能です。
  - このプログラムには正式な署名が含まれており、そのまま実行できます。ただし、署名の有効性が常に保証されるわけではありません。セキュリティブロックや起動時のクラッシュが発生した場合は、以下のコマンドを使用してローカルでの再署名を試みてください：
    - `codesign --force --deep --sign - evernight_board.app`
- Linux 用プログラムに関する追加事項：
  - まず `chmod +x ./evernight_board` を使用して実行権限を付与してください。
  - 表示が乱れる場合は、`LIBGL_ALWAYS_SOFTWARE=1 ./evernight_board` をお試しください。

**新增功能**  **New Features**  **新機能**

- 多平台支持。
- 多语言支持 (English | 简体中文 | 繁体中文 | 日语)。
- 支持使用音量按钮翻页。
- 支持竖屏状态下导航栏移动到设备微倾斜的一侧。
- 支持配置的导入和导出。
- 更丰富的提示信息。

- Multi-platform support.
- Multi-language support (English | Simplified Chinese | Traditional Chinese | Japanese).
- Supports page turning using volume buttons.
- Support for moving the navigation bar to the side towards which the device is slightly tilted in portrait mode.
- Supports import and export of configurations.
- Enhanced prompt messages.

- マルチプラットフォーム対応。
- 多言語対応 (English | 簡体字中国語 | 繁体字中国語 | 日本語)。
- 音量ボタンによるページめくりに対応。
- 縦向き状態で、デバイスがわずかに傾いている側へナビゲーションバーを移動する機能に対応。
- 設定のインポートおよびエクスポートに対応。
- より詳細なヒントメッセージ。

## v1.1.0

- 有关该版本的使用说明，请参见源代码压缩包中的 README(en/ja/zh-Hans/zh-Hant).md 或应用程序内的“使用说明”。
- 有关下载和启动程序的注意事项，请参考 `v1.0.0` 的描述。以下是对这些描述的补充说明：
- 适用于 Windows 的额外说明
  - 如果你不想通过安装程序安装，可以使用解压缩软件直接解压缩安装包到需要的地方即可。
- 适用于 Linux 的额外说明
  - 如果需要创建程序菜单项或者桌面快捷方式，请运行 `shortcuts.sh` 。

- For instructions regarding this version, please refer to `README(en/ja/zh-Hans/zh-Hant).md` in the source code archive or the "Instructions" within the application.
- For notes on downloading and launching the program, please refer to the description of `v1.0.0`. The following are supplementary notes to those descriptions:
- Additional notes for Windows
  - If you do not wish to use the installer, you can simply use decompression software to extract the installation package directly to your desired location.
- Additional notes for Linux
  - To create program menu items or desktop shortcuts, please run `shortcuts.sh`.

- このバージョンの使用方法については、ソースコードのアーカイブに含まれる `README(en/ja/zh-Hans/zh-Hant).md` またはアプリケーション内の「使用説明」をご参照ください。
- プログラムのダウンロードと起動に関する注意事項については、`v1.0.0` の説明をご参照ください。以下は、それらの説明に対する補足事項です。
- Windows に関する補足事項
  - インストーラーによるインストールを行いたくない場合は、解凍ソフトを使用してインストールパッケージを任意の場所に直接展開してください。
- Linux に関する補足事項
  - プログラムのメニュー項目やデスクトップショートカットを作成する必要がある場合は、`shortcuts.sh` を実行してください。

**新增功能**  **New Features**  **新機能**

- 修正在手动指定语言后，重新打开程序后恢复到“自动”的问题。
- 适配操作系统的“无障碍”功能。
- 在 TalkBack 和 VoiceOver 启用时，暂停导航栏的自动移动位置功能。
- 在某些功能被禁用时，显示提示信息并说明原因。
- 适配新版本系统。

- Fixed an issue where the language setting would revert to "Auto" upon restarting the program after being manually specified.
- Adapted to the operating system's "Accessibility" features.
- Paused the navigation bar's automatic positioning feature when TalkBack or VoiceOver is enabled.
- Displays prompt messages explaining the reason when certain features are disabled.
- Adapted for newer operating system versions.

- 言語を手動で指定した後、プログラムを再起動すると「自動」に戻ってしまう問題を修正しました。
- オペレーティングシステムの「アクセシビリティ」機能に対応しました。
- TalkBack または VoiceOver が有効な場合、ナビゲーションバーの自動位置移動機能を一時停止するようにしました。
- 特定の機能が無効化されている際に、プロンプトを表示してその理由を説明するようにしました。
- 新しいバージョンの OS に対応しました。
