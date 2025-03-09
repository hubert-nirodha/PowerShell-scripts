# Enhanced Script: Updates all apps using Winget with better logging and error handling

# Define a log file for output
$logFile = "$env:USERPROFILE\Desktop\WingetUpdateLog.txt"

# Write an introductory message to the console and log file
$introMessage = "Starting the update process: Looking for updates for all apps with 'winget upgrade --all'"
Write-Output $introMessage
Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " - " + $introMessage

# Try to run the Winget command and log output
try {
    Write-Output "Running 'winget upgrade --all'..."
    Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " - Running 'winget upgrade --all'..."

    # Execute the command and capture the output
    $wingetOutput = winget upgrade --all 2>&1

    # Display and log the output of the command
    $wingetOutput | ForEach-Object {
        Write-Output $_
        Add-Content -Path $logFile -Value $_
    }

    # Final success message
    $successMessage = "Update process completed successfully."
    Write-Output $successMessage
    Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " - " + $successMessage
}
catch {
    # Handle any errors and log them
    $errorMessage = "An error occurred during the update process: $_"
    Write-Error $errorMessage
    Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " - " + $errorMessage
}
