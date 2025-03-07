# Set up the HP2i working directory in the current location
$currentFolder = Get-Location
$hp2iFolder = "$currentFolder\HP2i"

# Ensure HP2i directory exists
if (-not (Test-Path -Path $hp2iFolder)) {
    New-Item -ItemType Directory -Path $hp2iFolder | Out-Null
}

# Define file paths
$mcprPath = "$hp2iFolder\MCPR.exe"
$sevenZipPath = "$hp2iFolder\7-Zip\7z.exe"
$sevenZipZipPath = "$hp2iFolder\7zip.zip"
$mcprExtractedFolder = "$hp2iFolder\MCPR_Extraction"

# Google Drive direct download links (Replace with your own FILE_IDs)
$mcprUrl = "https://drive.google.com/file/d/1Oe3d_quFoPuGJp6eYUMMujPvBethg0gn/view?usp=sharing"
$sevenZipUrl = "https://drive.google.com/drive/folders/1OkI-TI_yNQEdLoyrgXNQmYqLyHXyAry0?usp=sharing"

# Function to download files
Function Download-File {
    param([string]$url, [string]$output)
    Invoke-WebRequest -Uri $url -OutFile $output
}

# Download necessary files
Write-Host "Downloading MCPR.exe..."
Download-File -url $mcprUrl -output $mcprPath

Write-Host "Downloading 7-Zip..."
Download-File -url $sevenZipUrl -output $sevenZipZipPath
Expand-Archive -Path $sevenZipZipPath -DestinationPath "$hp2iFolder\7-Zip" -Force

# Extract MCPR.exe using 7-Zip
Write-Host "Extracting MCPR.exe..."
Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$mcprPath`" -o`"$mcprExtractedFolder`" -y" -NoNewWindow -Wait

# Locate mccleanup.exe
$mccleanupPath = Get-ChildItem -Path $mcprExtractedFolder -Recurse -Filter "mccleanup.exe" | Select-Object -First 1

if ($mccleanupPath) {
    Write-Host "mccleanup.exe found at: $($mccleanupPath.FullName)"

    # Stop McAfee services
    Get-Service | Where-Object { $_.Name -like "*McAfee*" } | Stop-Service -Force

    # Define uninstall arguments
    $arguments = "-p StopServices,MFSY,PEF,MXD,CSP,Sustainability,MOCP,MFP,APPSTATS,Auth,EMproxy,FWdiver,HW,MAS,MAT,MBK,MCPR,McProxy,McSvcHost,VUL,MHN,MNA,MOBK,MPFP,MPFPCU,MPS,SHRED,MPSCU,MQC,MQCCU,MSAD,MSHR,MSK,MSKCU,MWL,NMC,RedirSvc,VS,REMEDIATION,MSC,YAP,TRUEKEY,LAM,PCB,Symlink,SafeConnect,MGS,WMIRemover,RESIDUE,WPS -v -s"

    # Run mccleanup.exe silently
    Start-Process -FilePath $mccleanupPath.FullName -ArgumentList $arguments -NoNewWindow -Wait
} else {
    Write-Host "mccleanup.exe not found."
}

# Cleanup all files after uninstallation
Write-Host "Cleaning up..."
Remove-Item -Path $hp2iFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "McAfee uninstallation complete."
