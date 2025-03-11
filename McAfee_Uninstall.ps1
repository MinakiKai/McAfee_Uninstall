# Set up the HP2i working directory
$hp2iFolder = "C:\HP2i_McAfee_Uninstall"

# Ensure HP2i directory exists
if (-not (Test-Path -Path $hp2iFolder)) {
    New-Item -ItemType Directory -Path $hp2iFolder | Out-Null
}

# Define file paths
$mcprPath = "$hp2iFolder\MCPR.exe"
$sevenZipPath = "$hp2iFolder\7-Zip\7z.exe"
$sevenZipZipPath = "$hp2iFolder\7-zip.zip"
$sevenZipExtractPath = "$hp2iFolder\7-Zip"
$mcprExtractedFolder = "$hp2iFolder\MCPR_Extraction"

# GitHub direct download links (Replace with your own FILE_IDs)
$mcprUrl = "https://github.com/MinakiKai/McAfee_Uninstall/raw/refs/heads/main/MCPR.exe"
$sevenZipUrl = "https://github.com/MinakiKai/McAfee_Uninstall/raw/refs/heads/main/7-Zip.zip"

Function Download-File {
    param([string]$url, [string]$output)
    
    try {
        Write-Host "Downloading from $url..."
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "Failed to download $url. Error: $_"
    }
}

Write-Host "Downloading the requirements in C:\HP2i_McAfee_Uninstall..."

Write-Host "Downloading 7-Zip..."
Download-File -url $sevenZipUrl -output $sevenZipZipPath

# Extract 7-Zip correctly (Ensure it does not create 7-Zip\7-Zip)
Write-Host "Extracting 7-Zip..."
Expand-Archive -Path $sevenZipZipPath -DestinationPath "$hp2iFolder" -Force

# Check if it created a nested "7-Zip\7-Zip" folder, and fix it
if (Test-Path "$sevenZipExtractPath\7-Zip") {
    Move-Item -Path "$sevenZipExtractPath\7-Zip\*" -Destination $sevenZipExtractPath -Force
    Remove-Item -Path "$sevenZipExtractPath\7-Zip" -Recurse -Force
}

# Download necessary files
Write-Host "Downloading MCPR.exe..."
Download-File -url $mcprUrl -output $mcprPath

# Extract MCPR.exe using 7-Zip
Write-Host "Extracting MCPR.exe..."
Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$mcprPath`" -o`"$mcprExtractedFolder`" -y" -NoNewWindow -Wait

# Cleanup MCPR app as it has vulnerabilities (https://www.mcafee.com/support/s/article/000002122?language=fr)
Write-Host "Cleaning up MCPR..."
Remove-Item -Path $mcprPath -Recurse -Force -ErrorAction SilentlyContinue

# Locate mccleanup.exe
$mccleanupPath = Get-ChildItem -Path $mcprExtractedFolder -Recurse -Filter "mccleanup.exe" | Select-Object -First 1

if ($mccleanupPath) {
    Write-Host "McAfee cleaning tool found at: $($mccleanupPath.FullName)"

    # Stop McAfee services
    Get-Service | Where-Object { $_.Name -like "*McAfee*" } | Stop-Service -Force

    # Define uninstall arguments
    $arguments = "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,WPS,RESIDUE -v -s"

    # Run mccleanup.exe silently
    Write-Host "Cleaning up McAfee. This may take several minutes..."
    try {
    # Attempt to run mccleanup with cmd
    cmd /c "echo. | `"$($mccleanupPath.FullName)`" $arguments"
    } catch {
        # If the above fails, use the powershell method as a fallback
        Start-Process -FilePath $mccleanupPath.FullName -ArgumentList $arguments -NoNewWindow -Wait
    }

# Cleanup all files after uninstallation
Write-Host "Cleaning up the requirements..."
Remove-Item -Path $hp2iFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "McAfee uninstallation complete."
