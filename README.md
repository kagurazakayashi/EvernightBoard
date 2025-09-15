![icon](assets/appicon/icon.ico)

# EvernightBoard

**English** | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md) | [日本語](README.ja.md)

**Entrusting the soul's connection to the deep night, transforming ten thousand voices into this space.**

EvernightBoard is a display-assistive tool that prolongs your communication through preset images and text when both touchscreen access and verbal communication are limited.

Android | iOS | Windows | macOS | Linux

## Use Cases

- When verbal communication is limited and **touchscreen precision is extremely low** (e.g., wearing gloves) or **the touchscreen is unusable**, use preset large text or images to quickly convey information to others.
- Scenarios where you simply need to display text messages or images in large sizes on the screen and be able to turn pages.

### Supported Page-Turning Methods

- Switching screen tabs via the navigation bar
- Switching screen tabs by tapping half of the screen
  - Top and bottom halves in portrait mode
  - Left and right halves in landscape mode

## How to Use

### Preparation

1. After launching the App, you will see blank content and an initial tab (**New Screen**). You will see two areas:
    1. **Navigation Bar Area**: Contains multiple buttons that can be modified and added by yourself; each button represents a "**Screen**".
    2. **Blank Area**: This is the current "**Screen**", where you can specify whether it displays text or an image.
2. Press the **currently selected** tab (if it's your first time using it, it will be the only tab) to open the menu. The menu includes the following items:
    1. **Navigation Bar Tab Related** (Light Blue)
        1. **Sidebar Icon**: You can change the icon of the current item in the sidebar by selecting one from the opened icon library.
        2. **Sidebar Title**: The label below the icon. Line breaks are not supported, and it is recommended to keep the content as brief as possible.
    2. **Navigation Bar Tab Order Adjustment** (Green)
        1. **Move Up**: Moves this icon to the previous position in the navigation bar. If it is already at the front, it will automatically move to the back.
        2. **Move Down**: Moves this icon to the next position in the navigation bar. If it is already at the back, it will automatically move to the front.
    3. **Set Current Screen Content** (Orange)
        1. **Set to Text**: The current screen will display a text segment you set. Line breaks are supported, and the text will automatically fill the screen and be maximized.
        2. **Set to Image**: The current screen will display an image you set. Be careful not to use image files that are too large to avoid wasting RAM.
    4. **Set Color** (Pink): The colors adjusted here also apply to the navigation bar **located on the current screen**.
        1. **Text Color**: Set the text color of the **text mode** on the current screen and the text color of the navigation bar on the current screen.
        2. **Background Color**: Set the background color of the current screen and the background color of the navigation bar on the current screen. Be careful not to set it to the same color as the text.
    5. **Add or Delete Screen** (Blue)
        1. **Add Screen**: Create a new screen. You can tap the new screen button in the navigation bar to switch to it, and **tap it again** to open the menu for editing.
        2. **Duplicate Screen**: Copy the current screen to a new screen, including the text/image/color.
    6. **Delete Screen** (Red): This will remove the current screen, and all content on the current screen will be lost.
    7. **App Settings** (Gray): Display more functions.
        1. Page-Turning Interaction
            1. **Half-Screen Tap Page Turn** Switch: When turned on, you can switch screens by tapping half of the screen (top and bottom halves in portrait mode, left and right halves in landscape mode).
            2. **Volume Button Page Turn** Switch: Use the device's volume buttons to switch screens, suitable for situations where the touchscreen is completely unusable.
        2. Configuration Management: Allocates **Screen Settings** and **Data Settings**.
            1. **Export Configuration**: Export **Screen Configuration** to a JSON file. If there are images, they will be embedded, causing the exported file to become significantly larger.
            2. **Import Configuration**: Import **Screen Configuration** from a JSON file. It is recommended to only import configurations from the same App version.
            3. **Restore Factory Settings**: Clear all **Screen Settings** and **Software Settings**.
        3. About
            1. **Help and Information**: Open the about window.
                1. **Instructions**, **Feedback**, **Source Code**: Open the browser to visit relevant web pages.
                2. **View License**: List the licensing agreements of this software and all third-party libraries used by this software.
            2. **Exit Program**: Completely exit the program and release RAM. It will not be kept in the background.

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

So, can you guess what scenario this application was originally designed for? `^_^`

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
