#!/usr/bin/env bash
set -e
PROJECT_ROOT=$PWD
APP_NAME="evernight_board"
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "APP_NAME: $APP_NAME"

OS="$(uname -s)"

case "$OS" in
  Darwin)
    TARGET="macos"
    ;;
  Linux)
    TARGET="linux"
    ;;
  MINGW*|MSYS*|CYGWIN*|Windows*)
    TARGET="windows"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Detected OS: $OS"
sh build_pre.sh
echo "Running: flutter build $TARGET"
flutter build "$TARGET" --no-tree-shake-icons --dart-define-from-file="flavor/$TARGET.json"

echo "Resolving executable path..."

case "$TARGET" in
  macos)
    EXECUTABLE_PATH="$PROJECT_ROOT/build/macos/Build/Products/Release/${APP_NAME}.app"

    if [ ! -f "$EXECUTABLE_PATH/Contents/MacOS/$APP_NAME" ]; then
      echo "Build succeeded, but executable was not found:"
      echo "$EXECUTABLE_PATH"
      echo "Please check whether the app name matches your actual macOS bundle name."
      exit 1
    fi

    open "$PROJECT_ROOT/build/macos/Build/Products/Release"
    ;;
  linux)
    EXECUTABLE_PATH="$PROJECT_ROOT/build/linux/x64/release/bundle/$APP_NAME"

    if [ ! -f "$EXECUTABLE_PATH" ]; then
      echo "Build succeeded, but executable was not found:"
      echo "$EXECUTABLE_PATH"
      echo "Please check your Linux bundle output directory."
      exit 1
    fi
    cp "$PROJECT_ROOT/linux_menu.sh" "$(dirname "$EXECUTABLE_PATH")"
    cp "$PROJECT_ROOT/assets/appicon/launcher_round_icons.png" "$(dirname "$EXECUTABLE_PATH")/icon.png"
    echo "Copied linux_menu.sh and icon.png to the bundle directory."
    ;;
  windows)
    EXECUTABLE_PATH="$PROJECT_ROOT/build/windows/x64/runner/Release/${APP_NAME}.exe"

    if [ ! -f "$EXECUTABLE_PATH" ]; then
      echo "Build succeeded, but executable was not found:"
      echo "$EXECUTABLE_PATH"
      echo "Please check whether the executable name matches your actual Windows runner output."
      exit 1
    fi
    ;;
  *)
    echo "Internal error: unknown platform $TARGET"
    exit 1
    ;;
esac

echo "Copying LICENSE and markdown files to build directory..."
TARGET_DIR=$(dirname "$EXECUTABLE_PATH")
shopt -s nullglob
for f in "$PROJECT_ROOT"/LICENSE* "$PROJECT_ROOT"/*.md; do
  cp "$f" "$TARGET_DIR/"
done
shopt -u nullglob

echo "Build completed successfully."
echo "Executable path: $EXECUTABLE_PATH"
echo "Launching application..."

case "$TARGET" in
  windows)
    "$EXECUTABLE_PATH"
    ;;
  macos)
    open "$EXECUTABLE_PATH"
    ;;
  *)
    chmod +x "$EXECUTABLE_PATH"
    "$EXECUTABLE_PATH"
    ;;
esac
