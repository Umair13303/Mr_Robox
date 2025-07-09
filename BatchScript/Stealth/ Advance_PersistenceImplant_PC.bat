$controllerUrl = "https://raw.githubusercontent.com/Umair13303/Mr_Robox/refs/heads/main/StaticFile/Watcher_URL.json"
try {
    $JsonList = Invoke-RestMethod -Uri $controllerUrl -UseBasicParsing
} catch {
    return
}
foreach ($item in $JsonList) {

}