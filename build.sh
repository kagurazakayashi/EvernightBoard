#!/usr/bin/env bash
set -e

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
flutter clean
flutter pub get
bash generate_icons.sh
echo "Running: flutter build $TARGET"
flutter build "$TARGET" -v --no-tree-shake-icons

echo "Resolving executable path..."

APP_NAME="$(basename "$PROJECT_ROOT")"

case "$PLATFORM" in
  macos)
    APP_BUNDLE_PATH="$PROJECT_ROOT/build/macos/Build/Products/Release/${APP_NAME}.app"
    EXECUTABLE_PATH="$APP_BUNDLE_PATH/Contents/MacOS/$APP_NAME"

    if [ ! -f "$EXECUTABLE_PATH" ]; then
      echo "Build succeeded, but executable was not found:"
      echo "$EXECUTABLE_PATH"
      echo "Please check whether the app name matches your actual macOS bundle name."
      exit 1
    fi
    ;;
  linux)
    EXECUTABLE_PATH="$PROJECT_ROOT/build/linux/x64/release/bundle/$APP_NAME"

    if [ ! -f "$EXECUTABLE_PATH" ]; then
      echo "Build succeeded, but executable was not found:"
      echo "$EXECUTABLE_PATH"
      echo "Please check your Linux bundle output directory."
      exit 1
    fi
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
    echo "Internal error: unknown platform $PLATFORM"
    exit 1
    ;;
esac

echo "Build completed successfully."
echo "Executable path: $EXECUTABLE_PATH"
echo "Launching application..."

case "$PLATFORM" in
  windows)
    "$EXECUTABLE_PATH"
    ;;
  *)
    chmod +x "$EXECUTABLE_PATH"
    "$EXECUTABLE_PATH"
    ;;
esac
