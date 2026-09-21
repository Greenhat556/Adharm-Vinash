# ADHARM VINASH - Realtime File Watcher & GitHub Auto-Sync Script
param(
    [int]$DebounceSeconds = 8
)

$gitCmd = "C:\Users\mukhe\AppData\Local\Programs\Git\cmd"
if ($env:Path -notlike "*$gitCmd*") {
    $env:Path = "$env:Path;$gitCmd"
}

$repoPath = $PSScriptRoot
Set-Location $repoPath

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  ADHARM VINASH - Continuous GitHub Auto-Sync Active    " -ForegroundColor Green
Write-Host "  Watching: $repoPath" -ForegroundColor Gray
Write-Host "  Debounce interval: $DebounceSeconds seconds" -ForegroundColor Gray
Write-Host "========================================================" -ForegroundColor Cyan

function Sync-ToGitHub {
    $status = git status --porcelain
    if (-not [string]::IsNullOrWhiteSpace($status)) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        Write-Host "[$timestamp] Changes detected! Uploading to GitHub..." -ForegroundColor Yellow
        git add -A
        git commit -m "Auto-update: $timestamp"
        git push origin main
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$timestamp] Push succeeded!" -ForegroundColor Green
        } else {
            Write-Host "[$timestamp] Push encountered an issue. Will retry on next update." -ForegroundColor Red
        }
    }
}

# Initial check on startup
Sync-ToGitHub

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$script:lastChange = [DateTime]::MinValue
$script:pendingSync = $false

$action = {
    param($source, $eventArgs)
    $path = $eventArgs.FullPath
    # Ignore internal git and log files
    if ($path -match "\\\.git" -or $path -match "\\\.system_generated" -or $path -match "sync\.log") {
        return
    }
    $script:lastChange = [DateTime]::UtcNow
    $script:pendingSync = $true
}

Register-ObjectEvent $watcher 'Changed' -Action $action | Out-Null
Register-ObjectEvent $watcher 'Created' -Action $action | Out-Null
Register-ObjectEvent $watcher 'Deleted' -Action $action | Out-Null
Register-ObjectEvent $watcher 'Renamed' -Action $action | Out-Null

try {
    while ($true) {
        Start-Sleep -Seconds 1
        if ($script:pendingSync) {
            $elapsed = ([DateTime]::UtcNow - $script:lastChange).TotalSeconds
            if ($elapsed -ge $DebounceSeconds) {
                $script:pendingSync = $false
                Sync-ToGitHub
            }
        }
    }
} finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
}
