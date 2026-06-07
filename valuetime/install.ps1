<#
.SYNOPSIS
    YouTube Lockdown Installer for Windows
    Blocks YouTube outside 6:00 PM - 9:00 PM via hosts file
.NOTES
    Run as Administrator: right-click > Run with PowerShell
    YouTube Music (music.youtube.com) is intentionally excluded.
#>

#Requires -RunAsAdministrator

$InstallDir = "$env:ProgramData\YouTubeLockdown"
$HostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"

# Domains to block (music.youtube.com NOT included — stays open)
$Domains = @(
    'youtube.com'
    'www.youtube.com'
    'm.youtube.com'
    'youtu.be'
    'www.youtu.be'
    'youtubei.googleapis.com'
    'ytimg.com'
    'www.ytimg.com'
    'googlevideo.com'
)

# ---------- DIRECTORY SETUP ----------
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Set-Location $InstallDir

Write-Output "Creating scripts..."

# =========================================================
#  BLOCK SCRIPT
# =========================================================
$BlockContent = @"
#requires -RunAsAdministrator
`$HostsFile = "$HostsFile"
`$Domains = @('$(($Domains -join "','"))')
# Remove old youtube entries
`$content = Get-Content `$HostsFile -ErrorAction SilentlyContinue
`$filtered = `$content | Where-Object { `$_ -notmatch 'youtube|ytimg|googlevideo' }
`$filtered | Set-Content `$HostsFile -Encoding ASCII
# Add block entries
Add-Content `$HostsFile "`r`n"
foreach (`$d in `$Domains) {
    Add-Content `$HostsFile "127.0.0.1 `$d"
}
ipconfig /flushdns | Out-Null
"@
Set-Content -Path "$InstallDir\yt_block.ps1" -Encoding ASCII -Value $BlockContent

# =========================================================
#  UNBLOCK SCRIPT
# =========================================================
$UnblockContent = @"
#requires -RunAsAdministrator
`$HostsFile = "$HostsFile"
`$content = Get-Content `$HostsFile -ErrorAction SilentlyContinue
`$filtered = `$content | Where-Object { `$_ -notmatch 'youtube|ytimg|googlevideo' }
`$filtered | Set-Content `$HostsFile -Encoding ASCII
ipconfig /flushdns | Out-Null
"@
Set-Content -Path "$InstallDir\yt_unblock.ps1" -Encoding ASCII -Value $UnblockContent

# =========================================================
#  ENFORCE SCRIPT (Time-Aware)
# =========================================================
$EnforceContent = @"
#requires -RunAsAdministrator
`$Hour = (Get-Date).Hour
if (`$Hour -ge 18 -and `$Hour -lt 21) {
    & "$InstallDir\yt_unblock.ps1"
} else {
    & "$InstallDir\yt_block.ps1"
}
"@
Set-Content -Path "$InstallDir\yt_enforce.ps1" -Encoding ASCII -Value $EnforceContent

# =========================================================
#  UNINSTALL SCRIPT
# =========================================================
$UninstallContent = @"
#requires -RunAsAdministrator
Write-Host "Removing YouTube Lockdown..."
# Remove scheduled tasks
@('YT_Block_Task','YT_Unblock_Task','YT_Enforce_Startup','YT_Enforce_Watchdog') | ForEach-Object {
    Unregister-ScheduledTask -TaskName `$_ -Confirm:`$false -ErrorAction SilentlyContinue
}
# Unblock hosts
`$HostsFile = "$HostsFile"
`$content = Get-Content `$HostsFile -ErrorAction SilentlyContinue
`$filtered = `$content | Where-Object { `$_ -notmatch 'youtube|ytimg|googlevideo' }
`$filtered | Set-Content `$HostsFile -Encoding ASCII
ipconfig /flushdns | Out-Null
# Remove install directory
Remove-Item -Path "$InstallDir" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Uninstalled successfully."
"@
Set-Content -Path "$InstallDir\uninstall.ps1" -Encoding ASCII -Value $UninstallContent

Write-Output "All scripts created."

# =========================================================
#  CLEANUP OLD TASKS
# =========================================================
@('YT_Block_Task','YT_Unblock_Task','YT_Startup_Enforce','YT_Watchdog','YT_Enforce_Startup','YT_Enforce_Watchdog') | ForEach-Object {
    Unregister-ScheduledTask -TaskName $_ -Confirm:$false -ErrorAction SilentlyContinue
}

# =========================================================
#  CREATE SCHEDULED TASKS
# =========================================================
$Principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

$Tasks = @(
    @{Name='YT_Block_Task'; File='yt_block.ps1'; Trigger=New-ScheduledTaskTrigger -Daily -At '09:00PM'}
    @{Name='YT_Unblock_Task'; File='yt_unblock.ps1'; Trigger=New-ScheduledTaskTrigger -Daily -At '06:00PM'}
    @{Name='YT_Enforce_Startup'; File='yt_enforce.ps1'; Trigger=New-ScheduledTaskTrigger -AtStartup}
    @{Name='YT_Enforce_Watchdog'; File='yt_enforce.ps1'; Trigger=New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)}
)

foreach ($t in $Tasks) {
    $Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -File `"$InstallDir\$($t.File)`""
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName $t.Name -Action $Action -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Output "  Scheduled task: $($t.Name)"
}

# =========================================================
#  ENFORCE NOW
# =========================================================
& "$InstallDir\yt_enforce.ps1"

Write-Output ""
Write-Output "========================================================"
Write-Output "YOUTUBE LOCKDOWN INSTALLED SUCCESSFULLY"
Write-Output "========================================================"
Write-Output "  Allowed time : 6:00 PM - 9:00 PM"
Write-Output "  Directory     : $InstallDir"
Write-Output "  YouTube Music : NOT blocked (music.youtube.com)"
Write-Output ""
Write-Output "  Uninstall:"
Write-Output "    powershell -ExecutionPolicy Bypass -File `"$InstallDir\uninstall.ps1`""
Write-Output "========================================================"
