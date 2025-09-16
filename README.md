![icon](assets/appicon/icon.ico)

# EvernightBoard

**English** | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md) | [日本語](README.ja.md)

**Entrusting the soul's connection to the deep night, transforming ten thousand voices into this space.**

EvernightBoard is a display-assistive tool that prolongs your communication through preset images and text when both touchscreen access and verbal communication are limited.

Android | iOS | Windows | macOS | Linux

## Use Cases

`(￣▽￣)"` _A scenario where using a touchscreen is difficult and speaking is also difficult... when would such a situation occur?_

- When verbal communication is limited and **touchscreen precision is extremely low** (e.g., wearing gloves) or **the touchscreen is unusable**, use preset large text or images to quickly convey information to others.
- Presenting prompts to the stage from offstage.
- Scenarios where you simply need to display text messages or images in large sizes on the screen and be able to turn pages.

### Supported Page-Turning Methods

- **Switch screens using icon buttons in the navigation bar**: The most standard method for page navigation.
  - In portrait mode, the navigation bar automatically shifts to the slightly tilted side of the phone, ensuring the thumb of either hand can easily reach it.
  - In landscape mode, the navigation bar always remains at the bottom.
- **Touch half of the screen to switch screens**: Enables accurate page turning even with low touch precision.
  - Portrait mode: Top and bottom halves.
  - Landscape mode: Left and right halves.
- **Use volume buttons to turn pages**: Physical buttons serve as your most reliable backup. This feature must be enabled separately in the software settings.

## How to Use

### Preparation

1. After launching the APP, you will see blank content and an initial tab (**New Screen**). There are two main areas:
   1. **Navigation Bar Area**: Contains multiple customizable buttons; each button represents a "**Screen**."
   2. **Blank Area**: The current "**Screen**," where you can choose to display text or an image.
2. Tap the **currently selected** tab (the only one available if using it for the first time) to open the menu. The menu includes the following items:
   1. **Navigation Tab Related** (Light Blue)
      1. **Sidebar Icon**: Change the icon for the current item in the sidebar by selecting one from the icon library.
      2. **Sidebar Title**: The label below the icon. It does not support line breaks, and content should be kept as short as possible.
   2. **Navigation Tab Order Adjustment** (Green)
      1. **Move Up**: Move this icon to the previous position in the navigation bar. If it's already at the beginning, it moves to the end.
      2. **Move Down**: Move this icon to the next position in the navigation bar. If it's already at the end, it moves to the beginning.
   3. **Set Current Screen Content** (Orange)
      1. **Set as Text**: The current screen will display text you enter. It supports line breaks, and the text will auto-fill and be maximized.
      2. **Set as Image**: The current screen will display an image you select. Note: Avoid large image files to save RAM.
   4. **Set Color** (Pink): Color adjustments here also apply to the navigation bar **on the current screen**.
      1. **Text Color**: Sets the text color for the **Text Mode** on the current screen and the text color of the current navigation bar.
      2. **Background Color**: Sets the background color for the current screen and its navigation bar. Be careful not to set it to the same color as the text.
   5. **Add or Delete Screen** (Blue)
      1. **Add New Screen**: Create a new screen. You can tap the new button in the navigation bar to switch to it, and **tap it again** to open the edit menu.
      2. **Copy Screen**: Copy the current screen (including text/images/colors) to a new screen.
   6. **Delete Screen** (Red): Removes the current screen; all content on this screen will be lost.
   7. **App Settings** (Gray): Displays additional functions.
      1. Paging Interaction
         1. **Half-Screen Paging** Toggle: When enabled, tap either half of the screen to switch screens (top/bottom for portrait, left/right for landscape).
         2. **Volume Key Paging** Toggle: Use the device's volume buttons to switch screens, useful when the touchscreen is unavailable.
      2. Navigation Bar Position
         1. Position in **Landscape Mode**:
            1. **Always at Bottom** (Default).
            2. Can be changed to: Always at Top, Always on Left, or Always on Right.
         2. Position in **Portrait Mode**:
            1. **Auto-move to Slightly Tilted Side** (Default): The navigation bar automatically moves to the side the phone is slightly tilted toward (Left or Right) for easy thumb access.
            2. Can be changed to: Always at Top, Always on Left, Always on Right, or Always at Bottom.
      3. Configuration Management: Manage **Screen Settings** and **Data Settings**.
         1. **Export Config**: Export **Screen Configuration** to a JSON file. Embedded images will significantly increase the file size.
         2. **Import Config**: Import **Screen Configuration** from a JSON file. It is recommended to only import configs from the same APP version.
         3. **Restore Factory Settings**: Clear all **Screen Settings** and **Software Settings**.
      4. About
         1. **Help and Info**: Open the "About" window.
            1. **User Guide**, **Feedback**, **Source Code**: Opens the browser to visit related webpages.
            2. **View Licenses**: Lists the license agreements for this software and all third-party libraries used.
         2. **Exit Program**: Completely close the program and release RAM; no background processes will remain.

#### Other Suggestions

- Temporarily disable the phone's lock screen function.
- Place the app icon on the home screen or in an easy-to-launch location.

### Getting Started

After preparing multiple preset images or texts according to the preparation steps above, you can easily convey the preset information to others in the following situations.

1. Situations with extremely low touchscreen precision: Switch screens by tapping half of the screen.
2. Situations where the touchscreen is completely unusable: Use the volume buttons to switch screens.

#### Screen Setting Examples

1. "Hello"
2. "Can I take a photo with you?"
3. "Look over there, he's coming to take a picture."
4. "Thank you"
5. "You look great"
6. "I want to go over there"
7. "I want to go take a photo with him"
8. "Sorry, I didn't hear clearly"
9. "I cannot speak"
10. "Leave it to me"
11. "I want to rest for a while"
12. "Look at the messages in the group"
13. "My camera is running out of battery"
14. "My phone is running out of battery"
15. (Social Media Account QR Code)

`^ ✪ ω ✪ ^` _So, can you guess what scenario this application was originally designed for?_

## Compilation

### Environment Requirements

1. Flutter: You can see the optimal Flutter version in the comments at `dependencies:flutter:` in the `pubspec.yaml` file.
2. Run the `flutter doctor` command and follow the prompts to complete various configurations.
3. `cd` into the folder where this project is located.

### Compile in Windows

- Compile as a Windows application and run: `build.bat`.
- Compile as an Android application and install: `build_apk.bat`.

### Compile in macOS or Linux

- Compile as a macOS or Linux application and run: `./build`.
- Compile as an Android application and install: `./build_apk`.

### Compile for macOS or iOS

1. Try to compile it once first.
2. Use Xcode to open `Runner.xcworkspace` in the `macos` or `ios` folder to configure it (e.g., certificates and provisioning profiles).
3. Then proceed with the official compilation.

### Debugging

1. Run `flutter clean`.
2. Run `flutter pub get` to download required third-party libraries.
3. Run `generate_icons.bat` or `./generate_icons` to generate application icons of various specifications and styles.
4. Run `dart.bat run flutter_iconpicker:generate_packs --packs material` to prepare icon resources.
5. Run `flutter run` to start debugging.

## License

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
