# This script opens specified locations in the Windows Settings App to make changes. Once you close a window, it opens another one.

Start-Process "ms-settings:privacy-general"
Pause  # Waits for you to press any key before proceeding
Start-Process "ms-settings:privacy-speech"
Pause
Start-Process "ms-settings:notifications"
Pause
Start-Process "ms-settings:power"
Pause
Start-Process "ms-settings:storagesense"
Pause
Start-Process "ms-settings:sharedexperiences"
Pause








