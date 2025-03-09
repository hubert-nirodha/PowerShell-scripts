# Retrieve the formatted drives and their size and free space
$drives = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
foreach ($drive in $drives) {
    $driveLetter = $drive.DeviceID
    $driveSize = [math]::round($drive.Size / 1GB, 2)
    $freeSpace = [math]::round($drive.FreeSpace / 1GB, 2)
    Write-Output "Drive: $driveLetter, Size: $driveSize GB, Free Space: $freeSpace GB"
}

# Retrieve the long name of the operating system
$osName = (Get-CimInstance Win32_OperatingSystem).Caption

# Retrieve the name of the laptop used
$laptopInfo = Get-CimInstance Win32_ComputerSystem
$laptopName = $laptopInfo.Model
$manufacturer = $laptopInfo.Manufacturer

# Retrieve the name of the processor
$processorName = (Get-CimInstance Win32_Processor).Name

# Retrieve the name and size of the SSD
$disks = Get-CimInstance Win32_DiskDrive | Where-Object {$_.MediaType -eq "Fixed hard disk media"}
foreach ($disk in $disks) {
    $diskName = $disk.Model
    $diskSize = [math]::round($disk.Size / 1GB, 2)
    Write-Output "SSD Name: $diskName, Size: $diskSize GB"
}

# Retrieve the physical RAM
$ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum
$ramSize = [math]::round($ram / 1GB, 2)

# Retrieve the long name of the WiFi card
$wifiCard = Get-CimInstance Win32_NetworkAdapter | Where-Object {($_.NetConnectionID -eq "Wi-Fi")}
$wifiCardName = $wifiCard.Name

# Retrieve the username
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Retrieve date of BIOS release (closest to the production date)
$bios = Get-CimInstance Win32_BIOS
$biosUpdateDate = $bios.ReleaseDate

# Output the results
Write-Output "Operating System: $osName"
Write-Output "Username: $username"
Write-Output "Laptop Manufacturer: $manufacturer"
Write-Output "Laptop Model: $laptopName"
Write-Output "Processor Name: $processorName"
Write-Output "Physical RAM: $ramSize GB"
Write-Output "WiFi Card: $wifiCardName"
Write-Output "Last BIOS Update: $biosUpdateDate"
