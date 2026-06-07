@echo off
setlocal EnableDelayedExpansion
:: ═══════════════════════════════════════════════════════════════════
::  YouTube Lockdown Installer (Hosts-Only) for Windows
::  Allowed time: 6:00 PM -> 9:00 PM
::  ═══════════════════════════════════════════════════════════════════

:: ---------- ADMIN CHECK ----------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Run this installer as Administrator.
    pause
    exit /b
)

:: ---------- DIRECTORY SETUP ----------
set INSTALL_DIR=C:\ProgramData\YouTubeLockdown
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"

set ENFORCE_SCRIPT=%INSTALL_DIR%\yt_enforce.bat
set BLOCK_SCRIPT=%INSTALL_DIR%\yt_block.bat
set UNBLOCK_SCRIPT=%INSTALL_DIR%\yt_unblock.bat
set UNINSTALL_SCRIPT=%INSTALL_DIR%\uninstall.bat

:: ═══════════════════════════════════════════════════════════════════
::  1. ENFORCE SCRIPT (Time-Aware)
::  ═══════════════════════════════════════════════════════════════════

> "%ENFORCE_SCRIPT%" echo @echo off
>>"%ENFORCE_SCRIPT%" echo for /f %%%%H in ('powershell -command "(Get-Date).Hour"') do set HOUR=%%%%H
>>"%ENFORCE_SCRIPT%" echo if %%HOUR%% GEQ 18 if %%HOUR%% LSS 21 ^(
>>"%ENFORCE_SCRIPT%" echo     call "%%~dp0yt_unblock.bat"
>>"%ENFORCE_SCRIPT%" echo ^) else ^(
>>"%ENFORCE_SCRIPT%" echo     call "%%~dp0yt_block.bat"
>>"%ENFORCE_SCRIPT%" echo ^)

:: ═══════════════════════════════════════════════════════════════════
::  2. BLOCK SCRIPT
::  ═══════════════════════════════════════════════════════════════════

> "%BLOCK_SCRIPT%" echo @echo off
>>"%BLOCK_SCRIPT%" echo attrib -R %%SystemRoot%%\System32\drivers\etc\hosts
>>"%BLOCK_SCRIPT%" echo powershell -ExecutionPolicy Bypass -Command "$domains = @('youtube.com','www.youtube.com','m.youtube.com','youtu.be','www.youtu.be','youtubei.googleapis.com','ytimg.com','www.ytimg.com','googlevideo.com'); $hosts = $env:SystemRoot + '\System32\drivers\etc\hosts'; $content = Get-Content $hosts -ErrorAction SilentlyContinue; $filtered = $content | Where-Object {$_ -notmatch 'youtube|ytimg|googlevideo'}; $filtered | Set-Content $hosts -Encoding ASCII; Add-Content $hosts ''; foreach ($d in $domains) { Add-Content $hosts ('127.0.0.1 ' + $d) }"
>>"%BLOCK_SCRIPT%" echo attrib +R %%SystemRoot%%\System32\drivers\etc\hosts
>>"%BLOCK_SCRIPT%" echo ipconfig /flushdns ^>nul

:: ═══════════════════════════════════════════════════════════════════
::  3. UNBLOCK SCRIPT
::  ═══════════════════════════════════════════════════════════════════

> "%UNBLOCK_SCRIPT%" echo @echo off
>>"%UNBLOCK_SCRIPT%" echo attrib -R %%SystemRoot%%\System32\drivers\etc\hosts
>>"%UNBLOCK_SCRIPT%" echo powershell -ExecutionPolicy Bypass -Command "$hosts = $env:SystemRoot + '\System32\drivers\etc\hosts'; $content = Get-Content $hosts -ErrorAction SilentlyContinue; $filtered = $content | Where-Object {$_ -notmatch 'youtube|ytimg|googlevideo'}; $filtered | Set-Content $hosts -Encoding ASCII"
>>"%UNBLOCK_SCRIPT%" echo ipconfig /flushdns ^>nul

:: ═══════════════════════════════════════════════════════════════════
::  4. UNINSTALL SCRIPT
::  ═══════════════════════════════════════════════════════════════════

> "%UNINSTALL_SCRIPT%" echo @echo off
>>"%UNINSTALL_SCRIPT%" echo schtasks /delete /tn "YT_Enforce_Startup" /f ^>nul 2^>^&1
>>"%UNINSTALL_SCRIPT%" echo schtasks /delete /tn "YT_Enforce_Watchdog" /f ^>nul 2^>^&1
>>"%UNINSTALL_SCRIPT%" echo schtasks /delete /tn "YT_Block_Task" /f ^>nul 2^>^&1
>>"%UNINSTALL_SCRIPT%" echo schtasks /delete /tn "YT_Unblock_Task" /f ^>nul 2^>^&1
>>"%UNINSTALL_SCRIPT%" echo attrib -R %%SystemRoot%%\System32\drivers\etc\hosts
>>"%UNINSTALL_SCRIPT%" echo powershell -ExecutionPolicy Bypass -Command "$hosts = $env:SystemRoot + '\System32\drivers\etc\hosts'; $content = Get-Content $hosts -ErrorAction SilentlyContinue; $filtered = $content | Where-Object {$_ -notmatch 'youtube|ytimg|googlevideo'}; $filtered | Set-Content $hosts -Encoding ASCII"
>>"%UNINSTALL_SCRIPT%" echo ipconfig /flushdns ^>nul
>>"%UNINSTALL_SCRIPT%" echo echo.
>>"%UNINSTALL_SCRIPT%" echo echo Uninstalled successfully. You can safely delete %INSTALL_DIR%.
>>"%UNINSTALL_SCRIPT%" echo pause

:: ═══════════════════════════════════════════════════════════════════
::  CLEANUP OLD TASKS
::  ═══════════════════════════════════════════════════════════════════

schtasks /delete /tn "YT_Block_Task" /f >nul 2>&1
schtasks /delete /tn "YT_Unblock_Task" /f >nul 2>&1
schtasks /delete /tn "YT_Startup_Enforce" /f >nul 2>&1
schtasks /delete /tn "YT_Watchdog" /f >nul 2>&1
schtasks /delete /tn "YT_Enforce_Startup" /f >nul 2>&1
schtasks /delete /tn "YT_Enforce_Watchdog" /f >nul 2>&1

:: ═══════════════════════════════════════════════════════════════════
::  CREATE NEW TASKS
::  ═══════════════════════════════════════════════════════════════════

schtasks /create /tn "YT_Block_Task" /tr "\"%BLOCK_SCRIPT%\"" /sc daily /st 21:00 /ru SYSTEM /rl highest /f >nul
schtasks /create /tn "YT_Unblock_Task" /tr "\"%UNBLOCK_SCRIPT%\"" /sc daily /st 18:00 /ru SYSTEM /rl highest /f >nul
schtasks /create /tn "YT_Enforce_Startup" /tr "\"%ENFORCE_SCRIPT%\"" /sc onstart /ru SYSTEM /rl highest /f >nul
schtasks /create /tn "YT_Enforce_Watchdog" /tr "\"%ENFORCE_SCRIPT%\"" /sc minute /mo 5 /ru SYSTEM /rl highest /f >nul

:: ═══════════════════════════════════════════════════════════════════
::  INITIALIZE CURRENT STATE
::  ═══════════════════════════════════════════════════════════════════

call "%ENFORCE_SCRIPT%"

echo.
echo =========================================================
echo HOSTS-ONLY LOCKDOWN INSTALLED SUCCESSFULLY
echo =========================================================
echo Allowed Time : 6:00 PM - 9:00 PM
echo Directory    : %INSTALL_DIR%
echo.
pause
