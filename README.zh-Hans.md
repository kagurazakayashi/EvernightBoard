# EvernightBoard 长夜锦书

![EvernightBoard](assets/appicon/icon.ico)

[English](README.md) | **简体中文** | [繁體中文](README.zh-Hant.md) | [日本語](README.ja.md)

**揽长夜之锦字，化万语为此间。**

长夜锦书(EvernightBoard) 是一款通过预设图文，在触屏和语言交流都受限时为您延续沟通的展示辅助工具。

[下载 (Android/iOS/Windows/macOS/Linux)](https://github.com/kagurazakayashi/EvernightBoard/releases) | [在浏览器中在线体验](https://kagurazakayashi.github.io/EvernightBoard/)

本应用程序没有“官方版”发布到任何应用商店。一些网友可能会在获得授权或者未获得授权的情况下，以他们的开发者名称发布到应用商店。我不介意在获得授权的情况下这样做，但因此在通常情况下，只有 [Releases](https://github.com/kagurazakayashi/EvernightBoard/releases) 中的二进制文件可视为“官方版”，只有 [Issues](https://github.com/kagurazakayashi/EvernightBoard/issues) 可视为最佳的反馈渠道。

## 使用场景

`(￣▽￣)"` _使用触摸屏困难并且说话也困难这种情景……什么时候会有这种情景啊？_

- 在使用手套等**触摸屏精度极低**或**无法使用触摸屏**，同时言语交流受限的时候，使用预设的大号文字或图片，快捷向别人传达信息。
- 在台下向台上展示提示词。
- 单纯需要在屏幕上大字显示文本信息或图片并能操作换页的情景。

### 支持的换页方式

- **使用导航栏中的图标按钮切换屏幕**：最常规的换页方式。
  - 竖屏状态下，导航栏会自动移到手机略微倾斜的一侧，以便左右手都可以轻松用拇指够到；
  - 横屏状态下，导航栏会始终在最下方。
- **触控半边屏幕切换屏幕**：只需要非常粗略的触控精度就可以准确翻页。
  - 竖屏为上半部分和下半部分；
  - 横屏为左半部分和右半部分。
- **按音量按钮换页**：物理按钮是你最靠谱的后盾。需要在软件设置中单独开启。

## 使用方法

### 准备工作

1. 启动 APP 后，可以看到空白内容和一个初始标签（**新屏幕**）。可以看到有两个区域：
   1. **导航栏区域**：内含多个可自行修改和添加的按钮，每个按钮代表一个“**屏幕**”。
   2. **空白区域**：即当前“**屏幕**”，你可以指定它显示一些文字还是图片。
2. 按**当前选中的**标签（如果是第一次使用那个唯一的就是），可以打开菜单。菜单中包括以下项目：
   1. **导航栏标签相关**（淡蓝色）
      1. **边栏图标**：可以更换边栏中当前项目的图标，你可以从打开的图标库中选择一个。
      2. **边栏标题**：图标下面的标签，不支持换行，并且内容建议尽可能简短。
   2. **导航栏标签顺序调整**（绿色）
      1. **上移**：将这个图标在导航栏中移动到前一个位置，如果已经在最前则自动移动到最后。
      2. **下移**：将这个图标在导航栏中移动到后一个位置，如果已经在最后则自动移动到最前。
   3. **设置当前屏幕内容**（橙色）
      1. **设为文字**：当前屏幕将显示一段你设置的文字，支持换行，文字将自动填充并最大化显示。
      2. **设为图片**：当前屏幕将显示一张你设置的图片，注意图片文件不要太大以免浪费运行内存。
   4. **设置颜色**（粉红色）：这里调整的颜色对**位于当前屏幕**的导航栏也有效。
      1. **文字颜色**：设置当前屏幕的**文字模式**的文字颜色 和 当前屏幕的导航栏的文字颜色。
      2. **背景颜色**：设置当前屏幕的背景颜色 和 当前屏幕的导航栏的背景颜色，小心不要和文字设置为同样的颜色。
   5. **添加或删除屏幕**（蓝色）
      1. **新增屏幕**：创建一个新屏幕，你可以点击导航栏中新的屏幕按钮切换到它，**再次点它**可以打开菜单进行编辑。
      2. **复制屏幕**：复制当前屏幕到一个新的屏幕，包括文本/图片/颜色。
   6. **删除屏幕**（红色）：将会移除当前屏幕，将丢失当前屏幕的所有内容。
   7. **应用设置**（灰色）：显示更多功能。
      1. 翻页交互
         1. **点击半屏翻页**开关：打开后可以按半边屏幕切换屏幕（竖屏为上半部分和下半部分，横屏为左半部分和右半部分）
         2. **音量键翻页**开关：使用设备的音量按钮来切换屏幕，适用于完全无法使用触屏的场合。
      2. 导航栏位置
         1. **横屏状态下**的导航栏位置：
            1. **始终在底端**（这是默认值）
            2. 你也可以修改到始终在顶部、始终在左侧、始终在右侧。
         2. **竖屏状态下**的导航栏位置：
            1. **自动移到微倾斜侧**（这是默认值）：导航栏会自动移到手机略微倾斜的一侧（左侧或右侧），以便左右手都可以轻松用拇指够到。
            2. 你也可以修改到始终在顶部、始终在左侧、始终在右侧、始终在底部。
      3. 配置管理：分配**屏幕设置**和**数据设置**。
         1. **导出配置**：将**屏幕配置**导出到 JSON 文件。如果有图片将会嵌入，导致导出文件显著变大。
         2. **导入配置**：从 JSON 文件导入**屏幕配置**，建议仅导入相同版本 APP 的配置。
         3. **恢复出厂设置**：清空所有**屏幕设置**和**软件设置**。
      4. 帮助和信息
         1. **使用说明**：阅读使用说明 `README.md`
         2. **关于**：打开关于窗口，查看作者和版本信息。
            1. **使用说明**、**问题反馈**、**源代码**：打开浏览器访问相关网页。
            2. **查看协议**：列出本软件和本软件使用的所有第三方库的许可协议。
         3. **退出程序**：完全退出程序，释放运行内存，不会在后台留存。

#### 其他建议

- 在不便操作的場合，暫時停用手機的鎖定螢幕功能，並將應用程式圖示放在主畫面或易於啟動的位置，可以讓您更輕鬆地回到本程式的畫面。
- 應用程式完整支援 TalkBack 與 VoiceOver，可以使用它們朗讀文字。

### 开始使用

按照上面的准备工作准备好多个预设的图片或文字之后，即可在以下场合轻松向别人告知预设的信息。

1. 触控屏幕精度极低的场合：按半边屏幕切换屏幕。
2. 完全无法使用触屏的场合：使用音量按钮切换屏幕。

#### 屏幕设置示例

1. “你好”
2. “我可以和你合影吗”
3. “看那边，他来拍照”
4. “谢谢”
5. “你很好看”
6. “我想去那边”
7. “我想去和他合影”
8. “抱歉，我没有听清楚”
9. “我没办法说话”
10. “交给我吧”
11. “我想休息一会”
12. “看一下群里的消息”
13. “我的相机要没电了”
14. “我的手机要没电了”
15. (社交账户二维码)

`^ ✪ ω ✪ ^` _所以你猜这个应用程序最初设计是为了什么情景的？_

### 疑难排解

Windows:

- Q: 收到提示信息: “此应用无法在你的电脑上运行”或者“映像文件无效”。
  - A: 这个程序只能在 Windows 10 及以上版本的 64 位 x86 处理器上运行。不支持 ARM 处理器和 32 位及以下处理器。

macOS:

- Q: 收到提示信息: “无法打开，因为无法验证开发者。”
  - A: 打开“系统偏好设置”中的“安全性与隐私”，切换到“通用”标签页，勾选“任何来源”，再次运行。如果这里有“已阻止使用，因为来自身份不明的开发者”，请按“仍要打开”按钮。
- Q: 启动直接崩溃，崩溃信息里有 `codesign` 相关内容。
  - A: 请尝试使用本机重签，命令是: `codesign --force --deep --sign - evernight_board.app` 。如果没有命令，先运行 `xcode-select --install` 安装 Xcode 。

Linux:

- Q: 在导入或导出配置时，无法打开文件对话框，而是提示“系统缺少必要组件”，怎么办？
  - A: 需要安装 XDG Desktop Portal 及后端。以 Arch Linux 为例:
    1. 安装主服务: `sudo pacman -S xdg-desktop-portal`
    2. 根据你的桌面环境选择一个后端: `sudo pacman -S xdg-desktop-portal-gtk (xdg-desktop-portal-kde / xdg-desktop-portal-wlr / ...)`
    3. 启动服务: `systemctl --user enable xdg-desktop-portal && systemctl --user start xdg-desktop-portal`
- Q: 程序的画面显示出现倾倒，或者画面、动画显示不完整或异常。
  - A: 请尝试 `LIBGL_ALWAYS_SOFTWARE=1 ./evernight_board` 。

## 隐私权

本程序完全开源、免费，并且尊重您的隐私。

本程序只会在以下场景使用权限，并且您可以在系统中禁用其所有权限。

- **只读**访问您的相册或文件系统：
  - 导入图片时。
  - 导入配置文件时。
- **写入**您的文件系统：
  - 导出配置文件时。
- 网络连接：
  - **本程序不会产生任何网络连接。**为了防止供应链攻击或者程序包被修改，建议您直接在操作系统中完全禁用本应用的网络连接权限。
  - “关于”中的 URL 链接会在浏览器中打开网页。

## 编译

### 环境要求

1. Flutter : 你可以在 `pubspec.yaml` 文件的 `dependencies:flutter:` 处的注释看到最佳的 Flutter 版本。
2. 运行 `flutter doctor` 命令，根据提示完成各种配置。
3. `cd` 进入本项目所在的文件夹。

### 调试

1. 运行 `flutter clean` 清理缓存。
2. 运行 `flutter pub get` 下载所需第三方库。
3. 运行 `generate_icons.bat` (Windows) 或 `./generate_icons.sh` 生成各种规格和样式的应用图标。
4. 运行 `dart run flutter_native_splash:create` 构建启动画面。
5. 运行 `flutter gen-l10n` 构建多语言文本。
6. 运行 `dart run flutter_iconpicker:generate_packs --packs material` 准备图标资源。
7. 运行 `flutter run` 开始调试。

- 如果需要编辑源代码，必须在启动 IDE 前完成第 1 步到第 5 步。
- 如果需要执行编译，必须在编译命令执行前完成第 1 步到第 6 步。
  - 你可以运行 `build_pre.bat` (Windows) 或 `./build_pre.sh` 直接完成这些步骤。

### 编辑显示语言

1. 修改或者按格式新建 `lib/l10n/app_*.arb` （ `*` 是语言代码）。
2. 该文件是 JSON 格式，要添加语言文本，只需要按照 `"变量名":"新语言文本"` 来设定即可。注意：
   1. 每个语言文本只需要这一行，例如 `"textcolor": "文字顏色",` ，不需要后面的 `"@textcolor": ...` 部分。
   2. 变量名必须和其他语言文件一样齐全。
3. 运行 `dart l10n_metadata.dart` 自动补齐所有语言文件的 `"@..."` 部分。
4. 运行 `flutter gen-l10n` 构建多语言文本。
5. 继续上述的 [调试](#调试) 步骤。

### 发布渠道差异

- 渠道变量用于在不同渠道分发软件时，根据特定的渠道显示特定的内容。
- 要使用渠道变量，在 `flutter run` 和 `flutter build` 命令最后添加:
  - `--dart-define-from-file="flavor/*.json"`
- 渠道文件见 `flavor/` 文件夹。

如果要在中国的应用商店中提供本程序，你必须拥有 ICP 备案号并将其填写到对应平台的 `"cnICPfiling":""` 中。详情请了解 [App Store Connect Help 中有关 Availability in China mainland](https://developer.apple.com/help/app-store-connect/reference/app-information) 的部分。

### 在 Windows 中编译

- 编译为 Windows 应用程序并运行: `build.bat` 。
- 编译为 Android 应用程序并安装: `build_apk.bat` 。

#### 手动编译为 Windows (需要在 Windows 中操作)

1. 运行上面的 [调试](#调试) 中的第 1 步到第 6 步。你可以运行 `build_pre.bat` 直接完成这些步骤。
2. 使用 `RD /S /Q build\windows` 删除上次编译的文件。
3. 执行编译命令：
   - 编译为 exe 程序: `flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/windows.json"` 。
     - 创建用于 本地安装 的 exe 安装包: `"%ProgramFiles(x86)%\NSIS\makensis.exe" installer.nsi`
   - 编译为用于 Microsoft Store 的发布版:
     1. 编译 exe 程序: `flutter.bat build windows --no-tree-shake-icons --dart-define-from-file="flavor/msstore.json"` 。
     2. 处理 NOTICES.Z 警告: `DEL /Q "build\flutter_assets\*.Z" "build\windows\x64\runner\Release\data\flutter_assets\*.Z"` 。
     3. 创建用于 Microsoft Store 发布的 msix 安装包: `dart.bat run msix:create` 。
     4. 可以使用 `Windows App Cert Kit` 验证该 msix 安装包。
4. 查看生成的文件: `DIR "%CD%\build\windows\x64\runner\Release"` 。
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.exe"`
   - `ECHO "%CD%\build\windows\x64\runner\Release\evernight_board.msix"`

### 在 macOS 或 Linux 中编译

- 编译为 macOS 或 Linux 应用程序并运行: `./build.sh` 。
- 编译为 Android 应用程序并安装: `./build_apk.sh` 。

### 手动编译为 macOS 或 iOS (需要在 macOS 中操作)

1. 运行上面的 [调试](#调试) 中的第 1 步到第 6 步。你可以运行 `./build_pre.sh` 直接完成这些步骤。
2. 执行编译命令（这可能会失败，不用管它）。
   - 编译为 macOS 程序: `flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/macos.json"`
   - 编译为 iOS 程序: `flutter build ios --no-tree-shake-icons --dart-define-from-file="flavor/ios.json"`
   - 编译为用于 macOS App Store 的发布版: `flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
   - 编译为用于 iOS App Store 的发布版: `flutter build macos --no-tree-shake-icons --dart-define-from-file="flavor/appstore.json"`
3. 运行 `cd macos` 或 `cd ios` 进入相应平台文件夹。
4. 运行 `pod install` 下载所需第三方库。
5. 运行 Xcode ，打开 `macos` 或 `ios` 文件夹中的 `Runner.xcworkspace` 进行配置（例如证书和描述文件）。
6. 进行正式编译。

### 手动编译为 Android

1. 运行上面的 [调试](#调试) 中的第 1 步到第 6 步。你可以运行 `build_pre.bat` (Windows) 或 `./build_pre.sh` 直接完成这些步骤。
2. 使用 `RD /S /Q build\app` (Windows) 或 `rm -rf build/app` 删除上次编译的文件。
3. 执行编译命令：
   - 编译为 apk 安装包: `flutter build apk --no-tree-shake-icons --dart-define-from-file="flavor/android.json"` 。
   - 编译为用于 Google Play 的发布版: `flutter build aab --no-tree-shake-icons --dart-define-from-file="flavor/googleplay.json"` 。
4. 查看生成的文件:
   - Windows: `DIR "build\app\outputs\flutter-apk"` 。
     - `ECHO "%CD%\build\app\outputs\flutter-apk\app-release.apk"`
     - `ECHO "%CD%\build\app\outputs\bundle\release\app-release.aab"`
   - macOS,Linux: `ls "build/app/outputs/flutter-apk"`
     - `ls -d "$PWD/build/app/outputs/flutter-apk/app-release.apk"`
     - `ls -d "$PWD/build/app/outputs/bundle/release/app-release.aab"`

### 手动编译为 Web

1. 运行上面的 [调试](#调试) 中的第 1 步到第 6 步。你可以运行 `build_pre.bat` (Windows) 或 `./build_pre.sh` 直接完成这些步骤。
2. 使用 `RD /S /Q build\web` (Windows) 或 `rm -rf build/web` 删除上次编译的文件。
3. 使用 `flutter build web --wasm --no-tree-shake-icons --base-href "/EvernightBoard/" --dart-define-from-file="flavor/web.json"` 进行编译。

- 如果需要兼容旧版本浏览器，移除 `--wasm` 。
- 可以将 `"/EvernightBoard/"` 改为所需的 URL 根路径。

### 手动编译为 Linux (需要在 Linux 中操作)

1. 运行上面的 [调试](#调试) 中的第 1 步到第 6 步。你可以运行 `./build_pre.sh` 直接完成这些步骤。
2. 使用 `rm -rf build/linux` 删除上次编译的文件。
3. 使用 `flutter build linux --no-tree-shake-icons --dart-define-from-file="flavor/linux.json"` 进行编译。
4. 查看生成的文件: `ls "build/linux/x64/release/bundle"`
   - `ls -d "$PWD/build/linux/x64/release/bundle/evernight_board"`
   - 如果运行时显示出现倾倒或其他画面异常，请尝试 `LIBGL_ALWAYS_SOFTWARE=1 "$PWD/build/linux/x64/release/bundle/evernight_board"` 。

### 建立启动或开始菜单项和桌面快捷方式 (需要在 Windows 或 Linux 中操作)

你可以使用 `.\shortcuts.ps1` (Windows) 或 `./shortcuts.sh` (Linux) 建立启动或开始菜单项和桌面快捷方式。

1. 在运行脚本前，请确保以下文件位于 **同一个文件夹** 中：
   - **Linux**: `shortcuts.sh` (脚本)、`icon.png` (图标文件)、`evernight_board` (执行文件)。
   - **Windows**: `shortcuts.ps1` (脚本)、`evernight_board.exe` (执行文件)。
2. 赋予脚本执行权限
   - **Linux**: 运行前请先赋予脚本执行权限: `chmod +x shortcuts.sh` 。
   - **Windows**: 运行前请确保已开启 PowerShell 脚本运行权限: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` 。

#### 快捷方式脚本的使用方式

命令格式: `./脚本名称 [动作] [目标] [模式]` 。

1. 动作
   - `add` (或 `a`): 创建快捷方式。
   - `remove` (或 `r`): 移除快捷方式。
2. 目标
   - `menu` (或 `m`): 系统应用程序菜单 (默认值)。
   - `desktop` (或 `d`): 桌面快捷方式。
3. 模式
   - `--user` (或 `-u`): 仅针对当前用户 (默认值)。
   - `--system` (或 `-s`): 全系统安装 (需具备管理员/Root 权限)。

#### 快捷方式脚本的命令示例

Linux 的 `sh` 示例:

- 为**当前用户**添加**菜单项**: `./shortcuts.sh add` 。
- **全系统**添加**菜单项**: `sudo ./shortcuts.sh add menu --system` 。
- 为**当前用户**同时添加**菜单项**与**桌面快捷方式**: `./shortcuts.sh add menu desktop` 。
- **全系统**添加**菜单项**与**桌面快捷方式**: `sudo ./shortcuts.sh add menu desktop --system` 。
- **移除**当前用户的菜单项: `./shortcuts.sh remove` 。
- 全系统**移除**菜单项与桌面快捷方式: `sudo ./shortcuts.sh remove menu --system` 。

Windows 的 `Windows PowerShell` 示例:

- 把上述示例的 `./shortcuts.sh` 改成 `.\shortcuts.ps1` 。
- 把上述示例的 `sudo ./shortcuts.sh` 改成 **以管理员身份运行**的窗口的 `.\shortcuts.ps1` 。
- 示例: `.\shortcuts.ps1 add menu desktop --system` 。

### 单元测试

- 运行所有测试: `flutter test`
- 运行单个测试文件: `flutter test test/home_item_test.dart`
- 运行并显示详细输出: `flutter test --reporter expanded`
- 运行测试并生成覆盖率报告: `flutter test --coverage`
- 查看覆盖率（需要先安装 lcov）: `genhtml coverage/lcov.info -o coverage/html`

测试文件清单:

- `test/home_item_test.dart` - HomeItem 模型的完整测试（toJson、fromJson、copyWith、序列化往返）
- `test/home_controller_test.dart` - HomeController 测试（导航、索引切换、语言切换、设置、颜色工具）
- `test/file_service_test.dart` - FileService 测试（边界条件、无效输入处理）
- `test/data_export_service_test.dart` - DataExportService 测试（导入/导出取消场景）
- `test/restart_widget_test.dart` - RestartWidget 组件测试（重建功能）
- `test/snack_bar_utils_test.dart` - SnackBarUtils 组件测试（成功/错误提示、清除前一条）

## 许可协议

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
