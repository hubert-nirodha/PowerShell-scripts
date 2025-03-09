# Fetching detailed computer information
$computerInfo = Get-ComputerInfo

# Displaying Windows Version and Build details
$osVersion = $computerInfo.WindowsVersion
$osBuild = $computerInfo.WindowsBuildLabEx
$osBuildNumber = $computerInfo.WindowsBuildNumber

# Displaying Update Information
$osUpdate = Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber

# Output
Write-Output "Computer Name       : $($computerInfo.CsName)"
Write-Output "Windows Version     : $osVersion"
Write-Output "Windows Build Number: $osBuildNumber"
Write-Output "Windows Build Lab   : $osBuild"
Write-Output "OS Update Details   : $($osUpdate.Caption)"
Write-Output "OS Version          : $($osUpdate.Version)"
Write-Output "OS Build Number     : $($osUpdate.BuildNumber)"
