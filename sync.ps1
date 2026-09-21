param(
    [string]$Message = "Auto update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

$gitCmd = "C:\Users\mukhe\AppData\Local\Programs\Git\cmd"
if ($env:Path -notlike "*$gitCmd*") {
    $env:Path = "$env:Path;$gitCmd"
}

Write-Host "[Git Sync] Checking repository status..." -ForegroundColor Cyan
git status --short

$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "[Git Sync] No local changes to push." -ForegroundColor Yellow
    exit 0
}

Write-Host "[Git Sync] Staging changes..." -ForegroundColor Cyan
git add -A

Write-Host "[Git Sync] Committing with message: '$Message'..." -ForegroundColor Cyan
git commit -m $Message

Write-Host "[Git Sync] Pushing to GitHub (origin/main)..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[Git Sync] Successfully synced to GitHub!" -ForegroundColor Green
} else {
    Write-Host "[Git Sync] Push failed. Please check your GitHub credentials." -ForegroundColor Red
}
