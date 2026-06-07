# smartDots Windows Installer
# Installs AutoHotkey virtual desktop switcher for KDE Plasma-like navigation
# Run: powershell -ExecutionPolicy Bypass -File install.ps1

$smartDotsDir = "C:\smartDots"
$startupDir = [Environment]::GetFolderPath("Startup")

Write-Host "=== smartDots Windows Setup ===" -ForegroundColor Cyan

# 1. Check AutoHotkey
$ahk = Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue
if (-not $ahk) {
    Write-Host "AutoHotkey v2 not found." -ForegroundColor Yellow
    $installAhk = Read-Host "Install AutoHotkey v2 via winget? (y/n)"
    if ($installAhk -eq "y") {
        winget install "AutoHotkey.AutoHotkey" --silent
        Write-Host "AutoHotkey installed. You may need to restart." -ForegroundColor Green
    } else {
        Write-Host "Please install AutoHotkey v2 from https://www.autohotkey.com/" -ForegroundColor Red
    }
} else {
    Write-Host "AutoHotkey found: $($ahk.Source)" -ForegroundColor Green
}

# 2. Create C:\smartDots and copy files
if (-not (Test-Path $smartDotsDir)) {
    New-Item -ItemType Directory -Path $smartDotsDir | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item "$scriptDir\window_switcher.ahk" "$smartDotsDir\" -Force
Copy-Item "$scriptDir\VirtualDesktopAccessor.dll" "$smartDotsDir\" -Force

Write-Host "Files copied to $smartDotsDir" -ForegroundColor Green

# 3. Create startup shortcut
$shortcutPath = "$startupDir\smartDots.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$smartDotsDir\window_switcher.ahk"
$shortcut.WorkingDirectory = $smartDotsDir
$shortcut.Description = "smartDots - KDE Plasma-like Virtual Desktop Switcher"
$shortcut.Save()

Write-Host "Startup shortcut created: $shortcutPath" -ForegroundColor Green
Write-Host ""
Write-Host "✅ smartDots installed!" -ForegroundColor Green
Write-Host "Press Win+1..9 to switch virtual desktops." -ForegroundColor Cyan
Write-Host "Restart or run window_switcher.ahk manually to activate." -ForegroundColor Yellow
