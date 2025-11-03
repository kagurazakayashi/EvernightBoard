; 使用 Unicode 版安裝程式，確保多語系字串（中日文等）能正確顯示
Unicode true

; 指定壓縮器為 LZMA，並啟用 /SOLID 模式以提升壓縮率
SetCompressor /SOLID lzma

; 設定壓縮字典大小為 64 MB
SetCompressorDictSize 64

; 啟用資料區塊最佳化，減少安裝檔體積
SetDatablockOptimize on

; =========================
; 應用程式基本資訊定義
; =========================

; 應用程式名稱，會顯示在安裝精靈、捷徑與解除安裝資訊中
!define APP_NAME "EvernightBoard"

; 主執行檔名稱
!define EXE_NAME "evernight_board.exe"

; 發行者名稱，會寫入 Windows 的解除安裝資訊
!define PUBLISHER "KagurazakaYashi"

; 版本號，會用於輸出安裝檔名稱與登錄資訊
!define VERSION "1.1.0.0"

; 預設安裝目錄，這裡指定安裝到 64 位元 Program Files 底下
!define INSTALL_DIR "$PROGRAMFILES64\evernight_board"

; 解除安裝資訊所使用的登錄路徑
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

; 安裝程式與解除安裝程式使用的圖示
!define MUI_ICON "assets\appicon\icon.ico"
!define MUI_UNICON "assets\appicon\icon.ico"

; Modern UI 歡迎頁與完成頁使用的側邊點陣圖
!define MUI_WELCOMEFINISHPAGE_BITMAP "assets\appicon\installer_nsi.bmp" 
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "assets\appicon\installer_nsi.bmp"

; 載入 NSIS Modern UI 2 巨集庫
!include "MUI2.nsh"

; =========================
; 安裝頁面流程設定
; =========================

; 歡迎頁
!insertmacro MUI_PAGE_WELCOME

; 第一個授權/說明頁：顯示 README
; 這裡先覆蓋頁首標題與副標題，供下一個 license page 使用
!define MUI_PAGE_HEADER_TEXT "$(Title_Readme)"
!define MUI_PAGE_HEADER_SUBTEXT "$(SubTitle_Readme)"

; 授權頁下方按鈕顯示為「下一步」
!define MUI_LICENSEPAGE_BUTTON "$(^NextBtn)"

; 授權頁底部文字設為空白
!define MUI_LICENSEPAGE_TEXT_BOTTOM " "

; 顯示 README 檔案內容（利用授權頁版型來展示）
!insertmacro MUI_PAGE_LICENSE "$(ReadmePath)"

; 第二個授權/說明頁：顯示 LICENSE
; 這裡使用前面相同的頁首設定
!insertmacro MUI_PAGE_LICENSE "$(MUILicense)"

; 第三個授權/說明頁：顯示隱私政策
; 重新定義頁首標題與副標題，供下一個 license page 使用
!define MUI_PAGE_HEADER_TEXT "$(Title_Privacy)"
!define MUI_PAGE_HEADER_SUBTEXT "$(SubTitle_Privacy)"

; 顯示隱私政策檔案
!insertmacro MUI_PAGE_LICENSE "$(PrivacyPath)"

; 安裝目錄選擇頁
!insertmacro MUI_PAGE_DIRECTORY

; 安裝執行進度頁
!insertmacro MUI_PAGE_INSTFILES

; 完成頁執行程式選項：指定勾選後要執行的程式
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXE_NAME}"

; 完成頁中執行程式選項的顯示文字
!define MUI_FINISHPAGE_RUN_TEXT "$(DESC_RunApp)"

; 啟用完成頁的額外勾選項，但不顯示 README 檔案，而是拿來當作開啟網站用途
!define MUI_FINISHPAGE_SHOWREADME ""

; 完成頁額外勾選項的顯示文字
!define MUI_FINISHPAGE_SHOWREADME_TEXT "$(DESC_VisitGitHub)"

; 當使用者勾選該項目時，執行自訂函式 OpenHomeSite
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION "OpenHomeSite"

; 預設不要勾選該選項
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

; 完成頁
!insertmacro MUI_PAGE_FINISH

; =========================
; 解除安裝頁面流程設定
; =========================

; 解除安裝確認頁
!insertmacro MUI_UNPAGE_CONFIRM

; 解除安裝執行進度頁
!insertmacro MUI_UNPAGE_INSTFILES

; =========================
; 多語系支援
; =========================

; 宣告安裝程式支援的語言
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Japanese"

; =========================
; 多語系檔案路徑設定
; =========================

; LICENSE 檔案路徑
LicenseLangString MUILicense ${LANG_SIMPCHINESE} "LICENSE.zh-CN"
LicenseLangString MUILicense ${LANG_TRADCHINESE} "LICENSE.zh-CN"
LicenseLangString MUILicense ${LANG_ENGLISH}     "LICENSE"
LicenseLangString MUILicense ${LANG_JAPANESE}    "LICENSE"

; 隱私政策檔案路徑
LicenseLangString PrivacyPath ${LANG_SIMPCHINESE} ".\PRIVACY.zh-Hans.md"
LicenseLangString PrivacyPath ${LANG_TRADCHINESE} ".\PRIVACY.zh-Hant.md"
LicenseLangString PrivacyPath ${LANG_JAPANESE}    ".\PRIVACY.ja.md"
LicenseLangString PrivacyPath ${LANG_ENGLISH}     ".\PRIVACY.md"

; README 檔案路徑
LicenseLangString ReadmePath ${LANG_SIMPCHINESE} ".\README.zh-Hans.md"
LicenseLangString ReadmePath ${LANG_TRADCHINESE} ".\README.zh-Hant.md"
LicenseLangString ReadmePath ${LANG_JAPANESE}    ".\README.ja.md"
LicenseLangString ReadmePath ${LANG_ENGLISH}     ".\README.md"

; =========================
; 多語系顯示字串
; =========================

; 完成頁：執行應用程式
LangString DESC_RunApp ${LANG_SIMPCHINESE} "运行 ${APP_NAME}"
LangString DESC_RunApp ${LANG_TRADCHINESE} "執行 ${APP_NAME}"
LangString DESC_RunApp ${LANG_ENGLISH} "Launch ${APP_NAME}"
LangString DESC_RunApp ${LANG_JAPANESE} "${APP_NAME} を起動する"

; 官方網站描述字串
LangString DESC_VisitWeb ${LANG_SIMPCHINESE} "访问官方网站"
LangString DESC_VisitWeb ${LANG_TRADCHINESE} "瀏覽官方網站"
LangString DESC_VisitWeb ${LANG_ENGLISH} "Visit Official Website"
LangString DESC_VisitWeb ${LANG_JAPANESE} "公式サイトを開く"

; GitHub 頁面描述字串
LangString DESC_VisitGitHub ${LANG_SIMPCHINESE} "访问该项目的 GitHub"
LangString DESC_VisitGitHub ${LANG_TRADCHINESE} "瀏覽該項目的 GitHub"
LangString DESC_VisitGitHub ${LANG_ENGLISH} "Visit this project's GitHub"
LangString DESC_VisitGitHub ${LANG_JAPANESE} "このプロジェクトの GitHub を表示する"

; 隱私政策頁標題
LangString Title_Privacy ${LANG_SIMPCHINESE} "隐私协议"
LangString Title_Privacy ${LANG_TRADCHINESE} "隱私協議"
LangString Title_Privacy ${LANG_JAPANESE}    "プライバシーポリシー"
LangString Title_Privacy ${LANG_ENGLISH}     "Privacy Policy"

; 隱私政策頁副標題
LangString SubTitle_Privacy ${LANG_SIMPCHINESE} "在安装之前，请阅读隐私保护条款。"
LangString SubTitle_Privacy ${LANG_TRADCHINESE} "在安裝之前，請閱讀隱私保護條款。"
LangString SubTitle_Privacy ${LANG_JAPANESE}    "インストールする前に、プライバシーポリシーを確認してください。"
LangString SubTitle_Privacy ${LANG_ENGLISH}     "Please review the privacy policy before installing."

; README 頁標題
LangString Title_Readme ${LANG_SIMPCHINESE} "自述文件"
LangString Title_Readme ${LANG_TRADCHINESE} "自述文件"
LangString Title_Readme ${LANG_ENGLISH}     "Readme"
LangString Title_Readme ${LANG_JAPANESE}    "リードミー"

; README 頁副標題
LangString SubTitle_Readme ${LANG_SIMPCHINESE} "使用说明"
LangString SubTitle_Readme ${LANG_TRADCHINESE} "使用說明"
LangString SubTitle_Readme ${LANG_ENGLISH}     "Usage Instructions"
LangString SubTitle_Readme ${LANG_JAPANESE}    "使用説明"

; =========================
; 初始化函式
; =========================

Function .onInit
  ; 顯示語言選擇對話框，讓使用者在安裝一開始選擇語言
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

; =========================
; 自訂函式：開啟專案首頁
; =========================

Function OpenHomeSite
    ; 使用系統預設瀏覽器開啟 GitHub 專案頁面
    ExecShell "open" "https://github.com/kagurazakayashi/EvernightBoard"
FunctionEnd

; =========================
; 安裝檔基本屬性
; =========================

; 安裝程式顯示名稱
Name "${APP_NAME}"

; 輸出的安裝檔路徑與檔名
OutFile "bin/${APP_NAME}_Setup_v${VERSION}.exe"

; 預設安裝路徑
InstallDir "${INSTALL_DIR}"

; 要求以系統管理員權限執行安裝程式
; 因為會寫入 HKLM 與 Program Files
RequestExecutionLevel admin

; =========================
; 安裝區段
; =========================

Section "Install"
    ; 設定接下來檔案解壓的輸出目錄為安裝目錄
    SetOutPath "$INSTDIR"

    ; 遞迴加入 Flutter Windows Release 輸出內容
    ; 也就是實際應用程式的執行檔與相關 DLL / 資源
    File /r "build\windows\x64\runner\Release\*.*"

    ; 額外把多語系文件一起打包到安裝目錄
    File "PRIVACY.ja.md"
    File "PRIVACY.md"
    File "PRIVACY.zh-Hans.md"
    File "PRIVACY.zh-Hant.md"
    File "README.ja.md"
    File "README.md"
    File "README.zh-Hans.md"
    File "README.zh-Hant.md"
    File "LICENSE"
    File "LICENSE.zh-CN"

    ; 產生解除安裝程式
    WriteUninstaller "$INSTDIR\${APP_NAME}_Uninstall.exe"

    ; =========================
    ; 寫入 Windows 解除安裝資訊
    ; 讓應用程式出現在「應用程式與功能」或「程式和功能」中
    ; =========================

    ; 顯示名稱
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"

    ; 解除安裝命令
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\${APP_NAME}_Uninstall.exe"'

    ; 顯示圖示
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"

    ; 顯示版本
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"

    ; 發行者
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"

    ; 取得本安裝區段大小，寫入 EstimatedSize
    ; 這個值可供 Windows 顯示預估安裝大小
    SectionGetSize 0 $0
    WriteRegDWORD HKLM "${UNINST_KEY}" "EstimatedSize" $0

    ; =========================
    ; 建立開始功能表與桌面捷徑
    ; =========================

    ; 建立開始功能表資料夾
    ; CreateDirectory "$SMPROGRAMS\${APP_NAME}"

    ; 建立應用程式捷徑
    ; CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"

    ; 建立解除安裝捷徑
    ; CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\${APP_NAME}_Uninstall.exe"

    ; 建立桌面捷徑
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
SectionEnd

; =========================
; 解除安裝區段
; =========================

Section "Uninstall"
    ; 刪除解除安裝程式本身
    Delete "$INSTDIR\${APP_NAME}_Uninstall.exe"

    ; 遞迴刪除整個安裝目錄
    RMDir /r "$INSTDIR"

    ; 刪除 Windows 解除安裝登錄資訊
    DeleteRegKey HKLM "${UNINST_KEY}"

    ; 刪除開始功能表捷徑
    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk"

    ; 刪除開始功能表資料夾
    RMDir "$SMPROGRAMS\${APP_NAME}"

    ; 刪除桌面捷徑
    Delete "$DESKTOP\${APP_NAME}.lnk"
SectionEnd
