# A script to create and manage system restore points with user interaction.
# This script checks System Protection status using 'vssadmin list shadowstorage' and includes improved error handling.

# Ensure the script is run as an administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator. Please restart the script with elevated privileges."
    exit
}

# Function to check if the script is running on Windows
function Test-OperatingSystem {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "This script requires PowerShell 5.0 or higher. Please upgrade your PowerShell version."
        exit
    }

    if ($IsWindows -eq $false) {
        Write-Host "This script is designed to run on Windows operating systems only."
        exit
    }
}

# Check if the script is running on Windows
Test-OperatingSystem

# Function to check if System Protection is enabled on a specific drive
function Test-SystemProtection {
    param (
        [string]$Drive = "C:"
    )

    try {
        # Run the vssadmin command and capture the output
        $vssOutput = vssadmin list shadowstorage 2>&1

       # Debugging: Print the vssadmin output in a more human-readable form
        Write-Host "Debug: vssadmin output:"
        $vssOutput -split "`n" | ForEach-Object { Write-Host $_ }

        # Simplify the check for the drive in the output
        if ($vssOutput -like "*For volume: ($Drive)*") {
            Write-Host "System Protection is on for $Drive."
            return $true # System Protection is enabled
        } else {
            Write-Host "System Protection is off for $Drive. Creating restore points is not possible without it!"
            return $false # System Protection is not enabled
        }
    } catch {
        # Handle any unexpected errors during the execution of the vssadmin command
        Write-Host "An error occurred while checking System Protection status: $_"
        return $false
    }
}

# Prompt the user with a Yes/No question to start the process
$confirmation = Read-Host "Do you want to create and name a restore point? (Y/YES/N/NO)"

# Check the user's input for "Yes" or "No"
if ($confirmation -match "^(y|yes)$") {
    Write-Host "You chose to create a restore point..."

    # Check if System Protection is enabled using the function
    Write-Host "Checking if System Protection is enabled on C:\..."
    if (Test-SystemProtection -Drive "C:") {
        Write-Host "System Protection is already enabled on C:\. Proceeding with restore point creation..."
    } else {
        Write-Host "System Protection is not enabled on C:\."

        # Ask the user if they want to enable System Protection
        $enableProtection = Read-Host "Do you want to enable System Protection on C:\? (Y/YES/N/NO)"
        if ($enableProtection -match "^(y|yes)$") {
            Write-Host "Enabling System Protection on C:\..."
            # Enable System Protection on the C:\ drive
            Enable-ComputerRestore -Drive "C:\"
            Write-Host "System Protection has been enabled. Proceeding with restore point creation..."
        } else {
            Write-Host "System Protection is required to create restore points. Exiting the script."
            exit
        }
    }

    # Prompt the user to enter details for the restore point
    try {
        # Prompt the user to enter a name for the restore point
        $restorePointName = Read-Host -Prompt "Enter a name for the restore point"

        # Provide a list of restore point types for the user to select
        $restorePointTypes = @("APPLICATION_INSTALL", "APPLICATION_UNINSTALL", "DEVICE_DRIVER_INSTALL", "MODIFY_SETTINGS")
        $restorePointType = $restorePointTypes | Out-GridView -Title "Select the Restore Point Type" -OutputMode Single

        # Check if the user made a selection
        if ($null -eq $restorePointType) {
            Write-Host "No restore point type selected. Exiting script."
            exit
        }

        # Create the restore point with the specified name and type
        $restorePoint = Checkpoint-Computer -Description $restorePointName -RestorePointType $restorePointType
        if ($restorePoint) {
            Write-Host "Restore point '$restorePointName' created successfully with type '$restorePointType'."
        }

    } catch {
        # Catch and display any errors that occur during the process
        Write-Host "Error creating restore point: $_"
    }

    # List all existing restore points
    Write-Host "Listing all existing restore points:"
    Get-ComputerRestorePoint

} elseif ($confirmation -match "^(n|no)$") {
    # User chose not to proceed
    Write-Host "You chose not to proceed. Exiting the script."
    exit
} else {
    # Invalid input
    Write-Host "Invalid input. Please enter 'Y', 'YES', 'N', or 'NO'. Exiting the script."
    exit
}