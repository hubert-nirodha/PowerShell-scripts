param (
    [string]$Drive = "C:",
    [string]$LogPath = "C:\Users\huber\Desktop\PS-scripts\GitHub\RestorePointScript.log"
)

# Function to log messages to a file
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $LogPath -Value $logMessage
}

# Ensure the script is run as an administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator. Please restart the script with elevated privileges."
    Write-Log "This script must be run as an administrator."
    exit
}

# Function to check if the script is running on Windows
function Test-OperatingSystem {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "This script requires PowerShell 5.0 or higher. Please upgrade your PowerShell version."
        Write-Log "PowerShell version is less than 5.0."
        exit
    }

    if ($IsWindows -eq $false) {
        Write-Host "This script is designed to run on Windows operating systems only."
        Write-Log "Operating system is not Windows."
        exit
    }
}

# Check if the script is running on Windows
Test-OperatingSystem

# Function to check if System Protection is enabled on a specific drive
function Test-SystemProtection {
    param (
        [string]$Drive
    )

    try {
        $vssOutput = vssadmin list shadowstorage 2>&1
        Write-Host "Debug: vssadmin output:"
        $vssOutput -split "`n" | ForEach-Object { Write-Host $_ }
        Write-Log "vssadmin output: $vssOutput"

        if ($vssOutput -like "*For volume: ($Drive)*") {
            Write-Host "System Protection is on for $Drive."
            Write-Log "System Protection is on for $Drive."
            return $true
        } else {
            Write-Host "System Protection is off for $Drive. Creating restore points is not possible without it!"
            Write-Log "System Protection is off for $Drive."
            return $false
        }
    } catch {
        Write-Host "An error occurred while checking System Protection status: $_"
        Write-Log "Error checking System Protection status: $_"
        return $false
    }
}

# Prompt the user with a Yes/No question to start the process
$confirmation = Read-Host "Do you want to create and name a restore point? (Y/YES/N/NO)"

# Check the user's input for "Yes" or "No"
if ($confirmation -match "^(y|yes)$") {
    Write-Host "You chose to create a restore point..."
    Write-Log "User chose to create a restore point."

    Write-Host "Checking if System Protection is enabled on $Drive..."
    Write-Log "Checking if System Protection is enabled on $Drive."
    if (Test-SystemProtection -Drive $Drive) {
        Write-Host "System Protection is already enabled on $Drive. Proceeding with restore point creation..."
        Write-Log "System Protection is already enabled on $Drive."
    } else {
        Write-Host "System Protection is not enabled on $Drive."
        Write-Log "System Protection is not enabled on $Drive."

        $enableProtection = Read-Host "Do you want to enable System Protection on $Drive? (Y/YES/N/NO)"
        if ($enableProtection -match "^(y|yes)$") {
            Write-Host "Enabling System Protection on $Drive..."
            Write-Log "User chose to enable System Protection on $Drive."

            try {
                Enable-ComputerRestore -Drive $Drive
                Write-Host "System Protection has been enabled. Proceeding with restore point creation..."
                Write-Log "System Protection has been enabled on $Drive."
            } catch {
                Write-Host "Error enabling System Protection: $_"
                Write-Log "Error enabling System Protection: $_"
                exit
            }
        } else {
            Write-Host "System Protection is required to create restore points. Exiting the script."
            Write-Log "User chose not to enable System Protection. Exiting script."
            exit
        }
    }

    try {
        $restorePointName = Read-Host -Prompt "Enter a name for the restore point"
        Write-Log "User entered restore point name: $restorePointName"

        $restorePointTypes = @("APPLICATION_INSTALL", "APPLICATION_UNINSTALL", "DEVICE_DRIVER_INSTALL", "MODIFY_SETTINGS")
        $restorePointType = $restorePointTypes | Out-GridView -Title "Select the Restore Point Type" -OutputMode Single
        Write-Log "User selected restore point type: $restorePointType"

        if ($null -eq $restorePointType) {
            Write-Host "No restore point type selected. Exiting script."
            Write-Log "No restore point type selected. Exiting script."
            exit
        }

        $restorePoint = Checkpoint-Computer -Description $restorePointName -RestorePointType $restorePointType
        if ($restorePoint) {
            Write-Host "Restore point '$restorePointName' created successfully with type '$restorePointType'."
            Write-Log "Restore point '$restorePointName' created successfully with type '$restorePointType'."
        }

    } catch {
        Write-Host "Error creating restore point: $_"
        Write-Log "Error creating restore point: $_"
    }

    Write-Host "Listing all existing restore points:"
    Write-Log "Listing all existing restore points."
    Get-ComputerRestorePoint | ForEach-Object { Write-Host $_.Description; Write-Log $_.Description }

} elseif ($confirmation -match "^(n|no)$") {
    Write-Host "You chose not to proceed. Exiting the script."
    Write-Log "User chose not to proceed. Exiting script."
    exit
} else {
    Write-Host "Invalid input. Please enter 'Y', 'YES', 'N', or 'NO'. Exiting the script."
    Write-Log "Invalid input. Exiting script."
    exit
}
