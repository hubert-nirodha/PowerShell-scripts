# Prompt the user for the password and convert it to a secure string
$SecurePassword = Read-Host "Enter your Outlook password" -AsSecureString

# Convert the secure string to plain text (needed for MailKit)
$PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))

Install-Module -Name MailKit -Force

# Define the email parameters
$To = "hubertdsemmler@outlook.com" # Replace with the recipient's email address
$From = "hubertdsemmler@outlook.com" # Replace with your Outlook email address
$Subject = "Windows Update Script Output"
$SMTPServer = "smtp.office365.com"
$SMTPPort = 587

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

# Capture the output of the update process
$Output = Get-WindowsUpdate -Verbose -Install -AcceptAll -IgnoreReboot | Out-String

# Check if a computer restart is required
if (Test-PendingReboot) {
    # Append a message to the output if a restart is required
    $Output += "Please Restart the computer to update the System!`nRestart the computer with 'Restart-Computer -Force'"
} else {
    # Append a message to the output if no restart is required
    $Output += "No restart required. System is up to date."
}

# Define the email body
$Body = $Output

# Send the email using MailKit
try {
    # Load the MailKit assembly
    Add-Type -Path (Join-Path -Path (Split-Path (Get-Command Send-MailKitMessage).Path) -ChildPath "MailKit.dll")

    # Create a new MailKit message
    $Message = New-Object MimeKit.MimeMessage
    $Message.From.Add((New-Object MimeKit.MailboxAddress "From", $From))
    $Message.To.Add((New-Object MimeKit.MailboxAddress "To", $To))
    $Message.Subject = $Subject

    # Set the email body
    $Message.Body = [MimeKit.TextPart]::new("plain", $Body)

    # Create a new MailKit SMTP client
    $Client = New-Object MailKit.Net.Smtp.SmtpClient

    # Connect to the SMTP server
    $Client.Connect($SMTPServer, $SMTPPort, [MailKit.Security.SecureSocketOptions]::StartTls)

    # Authenticate to the SMTP server
    $Client.Authenticate($From, $PlainTextPassword)

    # Send the email
    $Client.Send($Message)
    $Client.Disconnect($true)

    Write-Output "Email sent successfully."
} catch {
    Write-Output "Failed to send email: $_"
}
