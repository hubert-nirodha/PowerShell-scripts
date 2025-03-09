# List of pre-installed apps to check
$appsToCheck = @(
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

# Check which apps are installed
$installedApps = @()
foreach ($app in $appsToCheck) {
    $package = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
    if ($package) {
        $installedApps += [PSCustomObject]@{
            Index = $installedApps.Count + 1
            Name  = Get-AppDisplayName $app
            PackageName = $app
        }
    }
}

# Display the list of installed apps
if ($installedApps.Count -eq 0) {
    Write-Output "No pre-installed apps from the list are installed on this device."
    exit
}

Write-Output "The following pre-installed apps are installed on this device:"
$installedApps | ForEach-Object { Write-Output "$($_.Index). $($_.Name)" }

# Ask the user to enter numbers separated by spaces to uninstall selected apps
$userInput = Read-Host "Enter the numbers of the apps you want to uninstall, separated by spaces"
$selectedIndexes = $userInput -split '\s+' | ForEach-Object { 
    try {
        [int]$_
    } catch {
        Write-Output "Invalid input: '$_' is not a number."
        exit
    }
}

# Uninstall the selected apps
foreach ($index in $selectedIndexes) {
    $appToRemove = $installedApps | Where-Object { $_.Index -eq $index }
    if ($appToRemove) {
        try {
            Get-AppxPackage -Name $appToRemove.PackageName | Remove-AppxPackage
            Write-Output "$($appToRemove.Name) has been successfully uninstalled."
        } catch {
            Write-Output "Failed to uninstall $($appToRemove.Name)."
        }
    } else {
        Write-Output "No app found with index $index."
    }
}