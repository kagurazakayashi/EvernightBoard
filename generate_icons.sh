#!/usr/bin/env bash
set -u

# Image files assets/appicon/iconforeground.png and assets/appicon/iconbackground.png
# should be larger than 1024x1024 pixels.

echo "========================================"
echo "Flutter App Icon Generation Script by KagurazakaYashi"
echo "========================================"

# =========================================================
# HELPERS
# =========================================================

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$script_dir"

fail() {
  echo "[ERROR] $1"
  exit 1
}

warn() {
  echo "[WARN] $1"
}

info() {
  echo "[INFO] $1"
}

ok() {
  echo "[OK] $1"
}

run_cmd() {
  "$@"
  local rc=$?
  if [ $rc -ne 0 ]; then
    return $rc
  fi
  return 0
}

# =========================================================
# CHECK DEPENDENCIES
# =========================================================

info "Checking ImageMagick..."
if command magick >/dev/null 2>&1; then
  MAGICK_CMD="magick"
elif command magick.exe >/dev/null 2>&1; then
  MAGICK_CMD="magick.exe"
else
  fail "ImageMagick not found. Please install and add it to PATH."
fi
ok "ImageMagick detected."

info "Checking Dart / Flutter..."
if command dart >/dev/null 2>&1; then
  DART_CMD="dart"
elif command dart.exe >/dev/null 2>&1; then
  DART_CMD="dart.exe"
elif command flutter >/dev/null 2>&1; then
  DART_CMD=""
else
  fail "Dart/Flutter not found. Please install Flutter SDK."
fi
ok "Dart / Flutter detected."

# =========================================================
# CLEAN OLD FILES
# =========================================================

info "Cleaning old icon files..."

rm -f "$project_root"/web/icons/*.png
rm -f "$project_root"/macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png
rm -f "$project_root"/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
rm -f "$project_root"/web/favicon.png
rm -f "$project_root"/windows/runner/resources/app_icon.ico
rm -f "$project_root"/assets/appicon/*_*.png

ok "Old files cleaned."

# =========================================================
# CLEAN ANDROID RESOURCES
# =========================================================

info "Cleaning Android resource directories..."
android_res_dir="$project_root/android/app/src/main/res"

[ -d "$android_res_dir" ] || fail "Failed to enter Android res directory."

cd "$android_res_dir" || fail "Failed to enter Android res directory."

shopt -s nullglob

for dir in mipmap-*; do
  if [ -d "$dir" ]; then
    info "Removing folder $dir"
    rm -rf "$dir"
  fi
done

for dir in drawable-*; do
  if [ -d "$dir" ]; then
    info "Removing folder $dir"
    rm -rf "$dir"
  fi
done

cd "$project_root" || fail "Failed to return to project root."

ok "Android resources cleaned."

# =========================================================
# GENERATE ICONS
# =========================================================

info "Generating icon assets..."
appicon_dir="$project_root/assets/appicon"

cd "$appicon_dir" || fail "Failed to enter assets/appicon directory."

[ -f "iconbackground.png" ] || fail "Missing iconbackground.png"
[ -f "iconforeground.png" ] || fail "Missing iconforeground.png"

info "Creating adaptive_icon_background.png"
run_cmd "$MAGICK_CMD" "iconbackground.png" -resize "1024x1024!" "adaptive_icon_background.png" \
  || fail "Failed to generate adaptive_icon_background.png"

info "Creating adaptive_icon_round_background.png"
run_cmd "$MAGICK_CMD" "adaptive_icon_background.png" \
  \( -size 1024x1024 xc:black -fill white -draw "roundrectangle 0,0 1023,1023 220,220" \) \
  -alpha off -compose copy_opacity -composite "adaptive_icon_round_background.png" \
  || fail "Failed to generate adaptive_icon_round_background.png"

info "Creating adaptive_icon_foreground.png"
run_cmd "$MAGICK_CMD" "iconforeground.png" -resize "1024x1024!" "adaptive_icon_foreground.png" \
  || fail "Failed to generate adaptive_icon_foreground.png"

info "Creating launcher_icons.png"
run_cmd "$MAGICK_CMD" "adaptive_icon_background.png" "adaptive_icon_foreground.png" \
  -gravity center -composite "launcher_icons.png" \
  || fail "Failed to generate launcher_icons.png"

info "Creating launcher_round_icons.png"
run_cmd "$MAGICK_CMD" "launcher_icons.png" \
  \( -size 1024x1024 xc:black -fill white -draw "roundrectangle 0,0 1023,1023 220,220" \) \
  -alpha off -compose copy_opacity -composite "launcher_round_icons.png" \
  || fail "Failed to generate launcher_round_icons.png"

info "Creating web_round_icon.png"
run_cmd "$MAGICK_CMD" "launcher_icons.png" \
  \( -size 1024x1024 xc:none -fill white -draw "circle 512,512 512,1" \) \
  -compose dst-in -composite "web_round_icon.png" \
  || fail "Failed to generate web_round_icon.png"

cd "$project_root" || fail "Failed to return to root directory."

ok "Icon assets generated."

# =========================================================
# RUN FLUTTER TOOL
# =========================================================

info "Running flutter_launcher_icons..."

if [ -n "${DART_CMD:-}" ]; then
  "$DART_CMD" run flutter_launcher_icons
  rc=$?
  if [ $rc -ne 0 ]; then
    warn "$DART_CMD failed, trying dart run..."
    dart run flutter_launcher_icons || fail "flutter_launcher_icons execution failed."
  fi
else
  dart run flutter_launcher_icons || fail "flutter_launcher_icons execution failed."
fi

ok "flutter_launcher_icons completed."

# =========================================================
# DONE
# =========================================================

echo "========================================"
echo "[SUCCESS] All steps completed successfully."
echo "========================================"

exit 0
