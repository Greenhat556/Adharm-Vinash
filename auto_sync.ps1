# ADHARM VINASH - Realtime Continuous GitHub Auto-Sync Engine
param(
    [int]$IntervalSeconds = 4
)

# Ensure single instance
$mutexName = "Global\AdharmVinash_AutoSync_Mutex"
$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, $mutexName, [ref]$createdNew)
if (-not $createdNew) {
    exit 0
}

$gitCmd = "C:\Users\mukhe\AppData\Local\Programs\Git\cmd"
if ($env:Path -notlike "*$gitCmd*") {
    $env:Path = "$env:Path;$gitCmd"
}

$repoPath = $PSScriptRoot
Set-Location $repoPath

$logFile = Join-Path $repoPath ".git\auto_sync.log"

function Log-Sync([string]$msg) {
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
    Add-Content -Path $logFile -Value $entry -ErrorAction SilentlyContinue
}

git config core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
Log-Sync "Continuous GitHub Auto-Sync daemon started (watching $repoPath)."

try {
    while ($true) {
        try {
            $status = git status --porcelain
            if (-not [string]::IsNullOrWhiteSpace($status)) {
                $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Log-Sync "Changes detected. Staging and committing..."
                
                git add -A
                git commit -m "Auto-update: $timestamp"
                
                Log-Sync "Pushing to GitHub origin/main..."
                git push origin main 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Log-Sync "Upload to GitHub succeeded ($timestamp)."
                } else {
                    Log-Sync "Push failed with exit code $LASTEXITCODE. Retrying next cycle."
                }
            }
        } catch {
            Log-Sync "Error during sync cycle: $($_.Exception.Message)"
        }
        
        Start-Sleep -Seconds $IntervalSeconds
    }
} finally {
    if ($mutex) {
        $mutex.ReleaseMutex()
        $mutex.Dispose()
    }
}
