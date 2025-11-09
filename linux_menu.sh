#!/bin/bash

# ==============================================================================
# @file         linux_menu.sh
# @brief        長夜錦書 (EvernightBoard) Linux 桌面入口管理工具
# @description  此腳本用於管理「長夜錦書」在 Linux 系統中的 .desktop 檔案。
#               支援新增/刪除「應用程式選單」與「桌面快捷方式」，並具備多語言偵測功能。
# @author       雅詩 (Yashi)
# @date         2026-04-23
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 項目基本定義 (Metadata)
# ------------------------------------------------------------------------------
APP_FILENAME="evernight_board"   # 程式執行檔名稱
ICON_NAME="icon.png"             # 圖示檔案名稱
CATEGORY="Graphics"              # 應用程式分類 (圖形界面)

# 定義可複用的 UI 分割線
SEP_EQUAL="=================================================="
SEP_DASH="--------------------------------------------------"

# ------------------------------------------------------------------------------
# 2. 多語言文本池 (Multi-language Strings)
# ------------------------------------------------------------------------------

# 項目名稱與簡介 (用於 .desktop 檔案)
APP_NAME_EN="EvernightBoard"; APP_NAME_ZH_CN="长夜锦书"; APP_NAME_ZH_TW="長夜錦書"; APP_NAME_JA="長夜錦書"

APP_COMMENT_EN="EvernightBoard is a display-assistive tool that prolongs your communication through preset images and text when both touchscreen access and verbal communication are limited."
APP_COMMENT_ZH_CN="长夜锦书(EvernightBoard) 是一款通过预设图文，在触屏和语言交流都受限时为您延续沟通的展示辅助工具。"
APP_COMMENT_ZH_TW="長夜錦書(EvernightBoard) 是一款透過預設圖文，在觸控螢幕和語言交流都受限時為您延續溝通的展示輔助工具。"
APP_COMMENT_JA="長夜錦書(EvernightBoard) は、事前に設定した画像やテキストを通じて、コミュニケーションを継続するための表示補助ツールです。"

# 預設英文文本 (Default EN Terminal Strings)
USAGE_HEAD="Usage"; USAGE_ACTION="Action"; USAGE_TARGET="Target"; USAGE_MODE="Mode"; USAGE_EX="Examples"
MSG_BANNER_MANAGE="This script helps you create or remove system menu entries and desktop shortcuts. Please ensure this script, the executable, and the icon file are placed in your desired installation directory before running it."
MSG_ERR_ROOT="Error: System-level operations require root privileges. Please use sudo."
MSG_ERR_EXEC="Error: Executable file not found in"
MSG_SUCCESS_MENU="Success! Desktop entry created at:"
MSG_SUCCESS_SHORTCUT="Success! Desktop shortcut created at:"
MSG_REMOVE_MENU="Success: Menu entry removed."
MSG_REMOVE_SHORTCUT="Success: Desktop shortcut removed."
MSG_NOTICE_NONE="Notice: No entries found to remove."
MSG_INSTALL_DONE="Installation complete."

# ------------------------------------------------------------------------------
# 3. 語言偵測與切換邏輯 (Locale Detection)
# ------------------------------------------------------------------------------
DETECTED_LANG="EN"
case "$LANG" in
    zh_CN*)
        DETECTED_LANG="ZH_CN"
        USAGE_HEAD="用法"; USAGE_ACTION="操作"; USAGE_TARGET="目标"; USAGE_MODE="模式"; USAGE_EX="示例"
        MSG_BANNER_MANAGE="该脚本可以帮助您创建或删除系统菜单项和桌面快捷方式。请在运行前，确保将本脚本、程序文件及图标文件放置于目标安装目录中，并运行该目录下的本脚本。"
        MSG_ERR_ROOT="错误：系统級操作需要 root 权限，请使用 sudo。"
        MSG_ERR_EXEC="错误：在此目录下找不到可执行文件："
        MSG_SUCCESS_MENU="成功！已创建菜单入口："
        MSG_SUCCESS_SHORTCUT="成功！已创建桌面快捷方式："
        MSG_REMOVE_MENU="成功：已移除菜单入口。"
        MSG_REMOVE_SHORTCUT="成功：已移除桌面快捷方式。"
        MSG_NOTICE_NONE="通知：未发现可移除的项。"
        MSG_INSTALL_DONE="安装完成。"
        ;;
    zh_TW*|zh_HK*|zh_MO*)
        DETECTED_LANG="ZH_TW"
        USAGE_HEAD="用法"; USAGE_ACTION="動作"; USAGE_TARGET="目標"; USAGE_MODE="模式"; USAGE_EX="範例"
        MSG_BANNER_MANAGE="此腳本可以幫助您建立或刪除系統功能表項目和桌面捷徑。請在執行前，確保將本腳本、執行檔及圖示檔案放置於目標安裝目錄中，並執行該目錄下的本腳本。"
        MSG_ERR_ROOT="錯誤：系統級操作需要 root 權限，請使用 sudo。"
        MSG_ERR_EXEC="錯誤：在此目錄下找不到執行檔："
        MSG_SUCCESS_MENU="成功！已建立選單入口："
        MSG_SUCCESS_SHORTCUT="成功！已建立桌面捷徑："
        MSG_REMOVE_MENU="成功：已移除選單入口。"
        MSG_REMOVE_SHORTCUT="成功：已移除桌面捷徑。"
        MSG_NOTICE_NONE="通知：未發現可移除的項目。"
        MSG_INSTALL_DONE="安裝完成。"
        ;;
    ja*)
        DETECTED_LANG="JA"
        USAGE_HEAD="使用法"; USAGE_ACTION="アクション"; USAGE_TARGET="ターゲット"; USAGE_MODE="モード"; USAGE_EX="例"
        MSG_BANNER_MANAGE="このスクリプトは、システムメニューエントリやデスクトップショートカットの作成または削除を支援します。実行する前に、このスクリプト、実行ファイル、およびアイコンファイルがディレクトリに配置されていることを確認してください。"
        MSG_ERR_ROOT="エラー：システムレベルの操作には root 権限が必要です。sudo を使用してください。"
        MSG_ERR_EXEC="エラー：実行ファイルが見つかりません："
        MSG_SUCCESS_MENU="成功！メニューエントリを作成しました："
        MSG_SUCCESS_SHORTCUT="成功！デスクトップショートカットを作成しました："
        MSG_REMOVE_MENU="成功：メニューエントリを削除しました。"
        MSG_REMOVE_SHORTCUT="成功：デスクトップショートカットを削除しました。"
        MSG_NOTICE_NONE="通知：削除対象が見つかりません。"
        MSG_INSTALL_DONE="インストールが完了しました。"
        ;;
esac

# ------------------------------------------------------------------------------
# 4. 參數解析與狀態初始化 (Argument Parsing)
# ------------------------------------------------------------------------------
ACTION=""; TARGET_MENU=false; TARGET_DESKTOP=false; MODE="user"

for arg in "$@"; do
    case "$arg" in
        add|a)          ACTION="add" ;;
        remove|r|rm)    ACTION="remove" ;;
        menu|m)         TARGET_MENU=true ;;
        desktop|d)      TARGET_DESKTOP=true ;;
        --user|-u)      MODE="user" ;;
        --system|-s)    MODE="system" ;;
    esac
done

# 如果指定了動作但未指定目標，預設操作應用程式選單
[ -n "$ACTION" ] && [ "$TARGET_MENU" = false ] && [ "$TARGET_DESKTOP" = false ] && TARGET_MENU=true

# ------------------------------------------------------------------------------
# 5. 核心功能函式 (Core Functions)
# ------------------------------------------------------------------------------

##
# @fn init_paths
# @brief 初始化選單與桌面路徑，並處理系統級權限檢查。
##
init_paths() {
    if [ "$MODE" == "system" ]; then
        MENU_DIR="/usr/share/applications"
        # 僅在需要執行動作時檢查 Root
        [ "$EUID" -ne 0 ] && [ -n "$ACTION" ] && { echo "$MSG_ERR_ROOT"; echo "$SEP_DASH"; exit 1; }
    else
        MENU_DIR="$HOME/.local/share/applications"
    fi
    # 偵測桌面路徑
    DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
    DESKTOP_FILE_NAME="evernight_board.desktop"
    MENU_PATH="$MENU_DIR/$DESKTOP_FILE_NAME"
    SHORTCUT_PATH="$DESKTOP_DIR/$DESKTOP_FILE_NAME"
}

##
# @fn print_banner
# @brief 在終端機輸出程式橫幅與提示文字。
##
print_banner() {
    local name="APP_NAME_$DETECTED_LANG"
    local comm="APP_COMMENT_$DETECTED_LANG"
    echo "$SEP_EQUAL"
    echo "${!name}"
    echo "${!comm}"
    echo " "
    echo "$MSG_BANNER_MANAGE"
    echo "$SEP_EQUAL"
}

##
# @fn usage
# @brief 顯示命令列使用指南與範例。
##
usage() {
    echo "$USAGE_HEAD: $0 [$USAGE_ACTION] [$USAGE_TARGET] [$USAGE_MODE]"
    echo " "
    echo "$USAGE_ACTION:  add (a), remove (r)"
    echo "$USAGE_TARGET:  menu (m), desktop (d)"
    echo "$USAGE_MODE:    --user (-u), --system (-s)"
    echo " "
    echo "$USAGE_EX:"
    echo "  # $0 add"
    echo "  # $0 add menu desktop --system"
    echo "  # $0 remove menu desktop --system"
    echo "$SEP_DASH"
    exit 1
}

##
# @fn generate_content
# @brief 生成 .desktop 檔案的標準內容。
# @param $1 執行檔絕對路徑
# @param $2 圖示檔案絕對路徑
# @param $3 程式工作目錄 (Path)
##
generate_content() {
    cat <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=$APP_NAME_EN
Name[zh_CN]=$APP_NAME_ZH_CN
Name[zh_TW]=$APP_NAME_ZH_TW
Name[ja]=$APP_NAME_JA
Comment=$APP_COMMENT_EN
Comment[zh_CN]=$APP_COMMENT_ZH_CN
Comment[zh_TW]=$APP_COMMENT_ZH_TW
Comment[ja]=$APP_COMMENT_JA
Exec=$1
Icon=$2
Path=$3
Terminal=false
Categories=$CATEGORY;
EOF
}

##
# @fn do_add
# @brief 執行新增動作，建立選單項及桌面快捷方式。
##
do_add() {
    INSTALL_DIR=$(cd "$(dirname "$0")" && pwd)
    EXEC_FILE="$INSTALL_DIR/$APP_FILENAME"
    ICON_FILE="$INSTALL_DIR/$ICON_NAME"
    
    # 驗證執行檔是否存在
    [ ! -f "$EXEC_FILE" ] && { echo "$MSG_ERR_EXEC $INSTALL_DIR"; echo "$SEP_DASH"; exit 1; }

    # 處理選單項
    if [ "$TARGET_MENU" = true ]; then
        [ "$MODE" == "user" ] && mkdir -p "$MENU_DIR"
        generate_content "$EXEC_FILE" "$ICON_FILE" "$INSTALL_DIR" > "$MENU_PATH"
        chmod +x "$MENU_PATH"
        echo "$MSG_SUCCESS_MENU $MENU_PATH"
    fi
    
    # 處理桌面快捷方式
    if [ "$TARGET_DESKTOP" = true ]; then
        generate_content "$EXEC_FILE" "$ICON_FILE" "$INSTALL_DIR" > "$SHORTCUT_PATH"
        chmod +x "$SHORTCUT_PATH"
        # 針對支援 gio 的桌面環境設定信任標記以顯示圖示
        gio set "$SHORTCUT_PATH" metadata::trusted true 2>/dev/null || true
        echo "$MSG_SUCCESS_SHORTCUT $SHORTCUT_PATH"
    fi
    echo "$MSG_INSTALL_DONE"
    echo "$SEP_DASH"
}

##
# @fn do_remove
# @brief 執行移除動作，刪除現有的選單項及桌面快捷方式。
##
do_remove() {
    local removed=false
    if [ "$TARGET_MENU" = true ] && [ -f "$MENU_PATH" ]; then
        rm "$MENU_PATH"; echo "$MSG_REMOVE_MENU"; removed=true
    fi
    if [ "$TARGET_DESKTOP" = true ] && [ -f "$SHORTCUT_PATH" ]; then
        rm "$SHORTCUT_PATH"; echo "$MSG_REMOVE_SHORTCUT"; removed=true
    fi
    [ "$removed" = false ] && echo "$MSG_NOTICE_NONE"
    echo "$SEP_DASH"
}

# ------------------------------------------------------------------------------
# 6. 腳本主執行流程 (Main Execution Flow)
# ------------------------------------------------------------------------------

# 第一步：初始化路徑與語系設定
init_paths

# 第二步：無論如何優先輸出 Banner 橫幅
print_banner

# 第三步：檢查動作指令，若未輸入參數則顯示用法說明並退出
[ -z "$ACTION" ] && usage

# 第四步：根據 ACTION 變數分流執行 add 或 remove 邏輯
if [ "$ACTION" == "add" ]; then
    do_add
else
    do_remove
fi