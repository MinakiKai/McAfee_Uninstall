# McAfee_Uninstall

Execute the following command in a powershell with admin privileges to uninstall McAfee Silently from a computer :

powershell.exe -ExecutionPolicy Bypass -Command "& {New-Item -ItemType Directory -Path '.\HP2i' -Force | Out-Null; Invoke-WebRequest -Uri 'https://github.com/MinakiKai/McAfee_Uninstall/raw/refs/heads/main/McAfee_Uninstall.ps1' -OutFile '.\HP2i\McAfee_Uninstall.ps1'; Start-Process -WindowStyle Hidden -FilePath 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass -File .\HP2i\McAfee_Uninstall.ps1' -Wait}"
