# ========== CONFIG ==========
$JsonURL = "https://raw.githubusercontent.com/Umair13303/Mr_Robox/refs/heads/main/StaticFile/Watcher_URL.json"
$TempJson = "$env:TEMP\script_index.json"

# ========== DOWNLOAD JSON ==========
try {
    Invoke-WebRequest -Uri $JsonURL -OutFile $TempJson -UseBasicParsing
    Write-Host "[+] JSON downloaded successfully."
} catch {
    Write-Host "[!] Failed to download JSON." -ForegroundColor Red
    exit 1
}

# ========== PARSE JSON ==========
try {
    $ScriptList = Get-Content -Raw -Path $TempJson | ConvertFrom-Json
} catch {
    Write-Host "[!] Failed to parse JSON." -ForegroundColor Red
    exit 1
}

# ========== PROCESS EACH SCRIPT ==========
foreach ($item in $ScriptList) {
    if ($item.Status -ne "true") {
        Write-Host "[!] Skipping script (Status = false): $($item.Alias)"
        continue
    }

    $scriptUrl = $item.Script_URL
    $alias = $item.Alias
    $locations = $item.Location

    Write-Host "`n[+] Processing: $alias"
    try {
        $downloadedPath = "$env:TEMP\$alias.tmp"
        Invoke-WebRequest -Uri $scriptUrl -OutFile $downloadedPath -UseBasicParsing
        Write-Host "    [*] Script downloaded: $scriptUrl"

        foreach ($dest in $locations) {
            $resolvedPath = [Environment]::ExpandEnvironmentVariables($dest)
            Copy-Item -Path $downloadedPath -Destination $resolvedPath -Force
            Write-Host "    [+] Copied to: $resolvedPath"
        }

        Remove-Item $downloadedPath -Force
    } catch {
        Write-Host "    [!] Error processing $alias" -ForegroundColor Red
    }
}

# Optional Cleanup
Remove-Item $TempJson -Force
Write-Host "`n[✓] All scripts processed."
