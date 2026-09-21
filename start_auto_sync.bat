@echo off
title ADHARM VINASH - Auto Sync to GitHub
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0auto_sync.ps1"
pause
