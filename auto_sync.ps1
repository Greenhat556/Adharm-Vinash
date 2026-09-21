# ADHARM VINASH - Realtime Continuous GitHub Auto-Sync Engine
param(
    [int]$IntervalSeconds = 5
)

$gitCmd = "C:\Users\mukhe\AppData\Local\Programs\Git\cmd"
if ($env:Path -notlike "*$gitCmd*") {
    $env:Path = "$env:Path;$gitCmd"
}

$repoPath = $PSScriptRoot
Set-Location $repoPath

git config core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  ADHARM VINASH - Continuous GitHub Auto-Sync Active      " -ForegroundColor Green
Write-Host "  Repository: $repoPath" -ForegroundColor Gray
Write-Host "  Sync Interval: Every $IntervalSeconds seconds" -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

while ($true) {
    try {
        $status = git status --porcelain
        if (-not [string]::IsNullOrWhiteSpace($status)) {
            $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Write-Host "[$timestamp] Local changes detected:" -ForegroundColor Yellow
            $status | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkYellow }
            
            Write-Host "[$timestamp] Staging all files..." -ForegroundColor Cyan
            git add -A
            
            Write-Host "[$timestamp] Creating commit..." -ForegroundColor Cyan
            git commit -m "Auto-update: $timestamp"
            
            Write-Host "[$timestamp] Pushing changes to GitHub origin/main..." -ForegroundColor Cyan
            git push origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$timestamp] Upload succeeded!" -ForegroundColor Green
            } else {
                Write-Host "[$timestamp] Push encountered an issue. Will retry on next cycle." -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "[Error] $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds $IntervalSeconds
}
