# Description: A PowerShell script to downlad and install Windows updates using the PSWindowsUpdate module.
# Author: hubertdsemmler@outlook.com

# Function to check if the PSWindowsUpdate module is installed
function Check-PSWindowsUpdateModule {
    try {
        # Try to get the PSWindowsUpdate module
        Get-Module -Name PSWindowsUpdate -ListAvailable -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to import the PSWindowsUpdate module
function Import-PSWindowsUpdateModule {
    try {
        # Try to import the PSWindowsUpdate module
        Import-Module PSWindowsUpdate -ErrorAction Stop
        Write-Output "PSWindowsUpdate module imported successfully."
    } catch {
        # If import fails, output an error message and exit
        Write-Output "Failed to import PSWindowsUpdate module."
        exit
    }
}

# Check if the PSWindowsUpdate module is installed
if (Check-PSWindowsUpdateModule) {
    Write-Output "PSWindowsUpdate module is already installed."
    Import-PSWindowsUpdateModule
} else {
    Write-Output "PSWindowsUpdate module is not installed. Installing now..."
    try {
        # Install the PSWindowsUpdate module if it's not already installed
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction Stop
        Write-Output "PSWindowsUpdate module installed successfully."
        Import-PSWindowsUpdateModule
    } catch {
        # If installation fails, output an error message and exit
        Write-Output "Failed to install PSWindowsUpdate module. Ensure you have an active internet connection and try again."
        exit
    }
}

# Download and install Windows updates using the PSWindowsUpdate module
Get-WindowsUpdate -Verbose -MicrosoftUpdate -AcceptAll -Install -IgnoreReboot

# Function to check if the Test-PendingReboot module is installed
function  Test-PendingReboot {
    try {
        # Try to get the PSWindowsUpdate module
        Get-Module -Name Test-PendingReboot -ListAvailable -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check if a computer restart is required
if (Test-PendingReboot) {
    # Append a message to the output if a restart is required
    $Output += "Please Restart the computer to update the System!`nRestart the computer with 'Restart-Computer -Force'"
} else {
    # Append a message to the output if no restart is required
    $Output += "No restart required. System is up to date."
}
