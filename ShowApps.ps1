# Liste der Apps, die deinstalliert werden sollen
$appsToRemove = @(
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# Überprüfen, ob die Apps installiert sind und eine Liste der installierten Apps erstellen
$installedApps = @()
foreach ($app in $appsToRemove) {
    try {
        $installedApp = Get-AppxPackage -AllUsers -Name $app
        if ($installedApp) {
            $installedApps += $app
        }
    } catch {
        Write-Host "Fehler beim Überprüfen der App: $app"
    }
}

# Liste der installierten Apps anzeigen und Benutzer zur Auswahl auffordern
if ($installedApps.Count -gt 0) {
    Write-Host "Folgende Apps sind installiert:"
    $installedApps | ForEach-Object { 
        $index = [array]::IndexOf($installedApps, $_) + 1
        Write-Host "$index. $_"
    }
	}

