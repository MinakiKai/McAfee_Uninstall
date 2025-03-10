# McAfee_Uninstall

Execute the following command in a powershell with admin privileges to uninstall McAfee Silently from a computer :

powershell.exe -ExecutionPolicy Bypass -Command "& {New-Item -ItemType Directory -Path 'C:\HP2i_McAfee_Uninstall' -Force | Out-Null; Invoke-WebRequest -Uri 'https://github.com/MinakiKai/McAfee_Uninstall/raw/refs/heads/main/McAfee_Uninstall.ps1' -OutFile 'C:\HP2i_McAfee_Uninstall\McAfee_Uninstall.ps1'; & 'C:\HP2i_McAfee_Uninstall\McAfee_Uninstall.ps1'}"
