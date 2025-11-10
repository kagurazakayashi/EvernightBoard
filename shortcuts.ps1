<#
.SYNOPSIS
    長夜錦書 (EvernightBoard) Windows 快捷方式管理工具。

.DESCRIPTION
    此腳本用於管理「長夜錦書」在 Windows 系統中的開始選單與桌面捷徑 (.lnk)。
    支援動作包含新增 (add) 與移除 (remove)，並可區分使用者級別或系統級別（全域）。
    本腳本具備文件名自適應功能，並符合 PowerShell 標準開發規範。

.PARAMETER Action
    執行的動作：add (a) 用於建立，remove (r) 用於移除。

.PARAMETER Target
    執行的目標：menu (m) 為開始選單，desktop (d) 為桌面快捷方式。

.PARAMETER Mode
    執行模式：--user (-u) 為目前使用者（預設），--system (-s) 為全系統（需管理員權限）。

.EXAMPLE
    .\win_menu.ps1 add
    建立目前使用者的開始選單項。

.EXAMPLE
    .\win_menu.ps1 add menu desktop --system
    以系統管理員權限為所有使用者建立開始選單與桌面捷徑。

.NOTES
    作者：雅詩 (Yashi)
    日期：2026-04-23
#>

# ------------------------------------------------------------------------------
# 1. 項目基本定義 (Metadata)
# ------------------------------------------------------------------------------
# 獲取腳本自身的名稱 (自適應文件名)
$ScriptName  = $MyInvocation.MyCommand.Name

$AppFileName = "evernight_board.exe"  # 程式執行檔
$IconName     = "icon.ico"            # 捷徑圖示
$LnkFileName  = "EvernightBoard.lnk"  # 捷徑檔案名稱

# 定義 UI 分割線
$SepEqual = "=" * 50
$SepDash  = "-" * 50

# ------------------------------------------------------------------------------
# 2. 多語言文本池 (Multi-language Strings)
# ------------------------------------------------------------------------------
$AppNames = @{
    "EN"    = "EvernightBoard"
    "ZH_CN" = "长夜锦书"
    "ZH_TW" = "長夜錦書"
    "JA"    = "長夜錦書"
}

$AppComments = @{
    "EN"    = "EvernightBoard is a display-assistive tool that prolongs your communication through preset images and text."
    "ZH_CN" = "长夜锦书(EvernightBoard) 是一款通过预设图文，在触屏和语言交流都受限时为您延续沟通的展示辅助工具。"
    "ZH_TW" = "長夜錦書(EvernightBoard) 是一款透過預設圖文，在觸控螢幕和語言交流都受限時為您延續溝通的展示輔助工具。"
}

# 終端機訊息文本
$Strings = @{
    "UsageHead"      = "Usage"
    "UsageAction"    = "Action"
    "UsageTarget"    = "Target"
    "UsageMode"      = "Mode"
    "UsageEx"        = "Examples"
    "BannerManage"   = "This script helps you create or remove system menu entries and desktop shortcuts. Please ensure this script, the executable, and the icon file are placed in your desired installation directory before running it."
    "ErrAdmin"       = "Error: System-level operations require Administrator privileges."
    "ErrExec"        = "Error: Executable file not found in"
    "SuccessMenu"    = "Success! Start Menu entry created at:"
    "SuccessShortcut"= "Success! Desktop shortcut created at:"
    "RemoveMenu"     = "Success: Start Menu entry removed."
    "RemoveShortcut" = "Success: Desktop shortcut removed."
    "NoticeNone"     = "Notice: No entries found to remove."
    "InstallDone"    = "Installation complete."
}

# ------------------------------------------------------------------------------
# 3. 語言偵測與切換邏輯 (Locale Detection)
# ------------------------------------------------------------------------------
$DetectedLang = "EN"
$Culture = (Get-Culture).Name

if ($Culture -like "zh-CN*") {
    $DetectedLang = "ZH_CN"
    $Strings["UsageHead"] = "用法"; $Strings["UsageAction"] = "操作"; $Strings["UsageTarget"] = "目标"; $Strings["UsageMode"] = "模式"; $Strings["UsageEx"] = "示例"
    $Strings["BannerManage"] = "该脚本可以帮助您创建或删除系统菜单项和桌面快捷方式。请在运行前，确保将本脚本、程序文件及图标文件放置于目标安装目录中，并运行该目录下的本脚本。"
    $Strings["ErrAdmin"] = "错误：系统級操作需要 管理员 权限。"
    $Strings["ErrExec"] = "错误：在此目录下找不到可执行文件："
    $Strings["SuccessMenu"] = "成功！已创建菜单入口："
    $Strings["SuccessShortcut"] = "成功！已创建桌面快捷方式："
    $Strings["RemoveMenu"] = "成功：已移除菜单入口。"
    $Strings["RemoveShortcut"] = "成功：已移除桌面快捷方式。"
    $Strings["NoticeNone"] = "通知：未发现可移除的项。"
    $Strings["InstallDone"] = "安装完成。"
} elseif ($Culture -like "zh-TW*" -or $Culture -like "zh-HK*" -or $Culture -like "zh-MO*") {
    $DetectedLang = "ZH_TW"
    $Strings["UsageHead"] = "用法"; $Strings["UsageAction"] = "動作"; $Strings["UsageTarget"] = "目標"; $Strings["UsageMode"] = "模式"; $Strings["UsageEx"] = "範例"
    $Strings["BannerManage"] = "此腳本可以幫助您建立或刪除系統功能表項目和桌面捷徑。請在執行前，確保將本腳本、執行檔及圖示檔案放置於目標安裝目錄中，並執行該目錄下的本腳本。"
    $Strings["ErrAdmin"] = "錯誤：系統級操作需要 管理員 權限。"
    $Strings["ErrExec"] = "錯誤：在此目錄下找不到執行檔："
    $Strings["SuccessMenu"] = "成功！已建立選單入口："
    $Strings["SuccessShortcut"] = "成功！已建立桌面捷徑："
    $Strings["RemoveMenu"] = "成功：已移除選單入口。"
    $Strings["RemoveShortcut"] = "成功：已移除桌面捷徑。"
    $Strings["NoticeNone"] = "通知：未發現可移除的項目。"
    $Strings["InstallDone"] = "安裝完成。"
}

# ------------------------------------------------------------------------------
# 4. 參數解析與狀態初始化 (Argument Parsing)
# ------------------------------------------------------------------------------
$Action = $null
$TargetMenu = $false
$TargetDesktop = $false
$Mode = "user"

foreach ($arg in $args) {
    switch ($arg) {
        { $_ -in "add", "a" } { $Action = "add" }
        { $_ -in "remove", "r" } { $Action = "remove" }
        { $_ -in "menu", "m" } { $TargetMenu = $true }
        { $_ -in "desktop", "d" } { $TargetDesktop = $true }
        { $_ -in "--user", "-u" } { $Mode = "user" }
        { $_ -in "--system", "-s" } { $Mode = "system" }
    }
}

# 預設行為處理：若指定了 add/remove 但未指定目標，預設為選單項
if ($null -ne $Action -and -not $TargetMenu -and -not $TargetDesktop) {
    $TargetMenu = $true
}

# ------------------------------------------------------------------------------
# 5. 核心功能函式 (Core Functions)
# ------------------------------------------------------------------------------

<#
.SYNOPSIS
    初始化路徑配置並檢查管理員權限。
#>
function Get-AppPathConfig {
    $script:InstallDir = $PSScriptRoot
    $script:ExePath    = Join-Path $InstallDir $AppFileName
    $script:IconPath   = Join-Path $InstallDir $IconName

    if ($Mode -eq "system") {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            if ($null -ne $Action) { Write-Host $Strings["ErrAdmin"]; Write-Host $SepDash; exit 1 }
        }
        $script:MenuDir    = [Environment]::GetFolderPath("CommonPrograms")
        $script:DesktopDir = [Environment]::GetFolderPath("CommonDesktopDirectory")
    } else {
        $script:MenuDir    = [Environment]::GetFolderPath("Programs")
        $script:DesktopDir = [Environment]::GetFolderPath("Desktop")
    }

    $script:MenuPath    = Join-Path $MenuDir $LnkFileName
    $script:ShortcutPath = Join-Path $DesktopDir $LnkFileName
}

<#
.SYNOPSIS
    在終端機輸出程式橫幅說明。
#>
function Show-Banner {
    Write-Host $SepEqual
    Write-Host $AppNames[$DetectedLang]
    Write-Host $AppComments[$DetectedLang]
    Write-Host ""
    Write-Host $Strings["BannerManage"]
    Write-Host $SepEqual
}

<#
.SYNOPSIS
    顯示腳本的使用說明與範例。
#>
function Show-Usage {
    Write-Host "$($Strings['UsageHead']): .\$ScriptName [$($Strings['UsageAction'])] [$($Strings['UsageTarget'])] [$($Strings['UsageMode'])]"
    Write-Host ""
    Write-Host "$($Strings['UsageAction']):  add (a), remove (r)"
    Write-Host "$($Strings['UsageTarget']):  menu (m), desktop (d)"
    Write-Host "$($Strings['UsageMode']):    --user (-u), --system (-s)"
    Write-Host ""
    Write-Host "$($Strings['UsageEx']):"
    Write-Host "  # .\$ScriptName add"
    Write-Host "  # .\$ScriptName add menu desktop --system"
    Write-Host "  # .\$ScriptName remove menu desktop --system"
    Write-Host $SepDash
    exit 1
}

<#
.SYNOPSIS
    建立捷徑檔案 (.lnk)。
.PARAMETER Path
    捷徑存檔的完整路徑。
#>
function New-AppShortcut ($Path) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $ExePath
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = $AppComments[$DetectedLang]
    if (Test-Path $IconPath) {
        $Shortcut.IconLocation = $IconPath
    }
    $Shortcut.Save()
}

<#
.SYNOPSIS
    執行新增快捷方式的邏輯。
#>
function Invoke-AppInstall {
    if (-not (Test-Path $ExePath)) {
        Write-Host "$($Strings['ErrExec']) $InstallDir"
        Write-Host $SepDash
        exit 1
    }

    if ($TargetMenu) {
        New-AppShortcut $MenuPath
        Write-Host "$($Strings['SuccessMenu']) $MenuPath"
    }
    if ($TargetDesktop) {
        New-AppShortcut $ShortcutPath
        Write-Host "$($Strings['SuccessShortcut']) $ShortcutPath"
    }
    Write-Host $Strings["InstallDone"]
    Write-Host $SepDash
}

<#
.SYNOPSIS
    執行移除快捷方式的邏輯。
#>
function Invoke-AppUninstall {
    $removed = $false
    if ($TargetMenu -and (Test-Path $MenuPath)) {
        Remove-Item $MenuPath; Write-Host $Strings["RemoveMenu"]; $removed = $true
    }
    if ($TargetDesktop -and (Test-Path $ShortcutPath)) {
        Remove-Item $ShortcutPath; Write-Host $Strings["RemoveShortcut"]; $removed = $true
    }
    if (-not $removed) { Write-Host $Strings["NoticeNone"] }
    Write-Host $SepDash
}

# ------------------------------------------------------------------------------
# 6. 腳本主執行流程 (Main Execution Flow)
# ------------------------------------------------------------------------------

# 1. 取得路徑配置
Get-AppPathConfig

# 2. 無論如何先印出 Banner
Show-Banner

# 3. 檢查動作參數，若為 $null 則顯示 Usage 並退出
if ($null -eq $Action) {
    Show-Usage
}

# 4. 根據 Action 分流執行安裝或移除
if ($Action -eq "add") {
    Invoke-AppInstall
} else {
    Invoke-AppUninstall
}