@echo off
setlocal
set "PATH=%PATH%;C:\Users\mukhe\AppData\Local\Programs\Git\cmd"

if "%~1"=="" (
    set "MSG=Update: %DATE% %TIME%"
) else (
    set "MSG=%*"
)

echo [ADHARM VINASH] Syncing project to GitHub...
cd /d "%~dp0"

git status --short
git add -A
git commit -m "%MSG%"
git push origin main

if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Changes uploaded to GitHub!
) else (
    echo [ERROR] Push failed. Check credentials or network.
)
pause
