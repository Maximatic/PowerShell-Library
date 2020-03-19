<#
.SYNOPSIS
    Exports file hashes of a user-specified file to a text file.
.DESCRIPTION
    Uses Get-FileHash to compute the hash value(s) for a user-specified file using MD5, SHA1, and SHA256.
    The results are written to a file with the same name as the chosen file with ".hashes.txt" appended to the end.
.NOTES
    File Name      : Out-FileHash.ps1
    Prerequisite   : PowerShell v3.0+
    Date           : 2019-01-27
.REFERENCES
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash
.NOTES
    To add other supported hashing algorithms, simply add them to the $Algorithms array.
    Accepted values are MD5, SHA1, SHA256, SHA384, SHA512, MACTripleDES, RIPEMD160.
#>

# Function to bring up GUI open file dialog.
Function Get-FileName($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

# Array of algorithms
$Algorithms = @("MD5","SHA1","SHA256")

# Create array for hashes
$Hashes = @()

# Prompt user for the file to compute hashes for.
$File = Get-FileName -initialDirectory "$env:HOMEPATH\Downloads"

# Loop through algorithms array.
foreach($Algorithm in $Algorithms) {
    
    # Store in $Hashes array.
    $Hashes += Get-FileHash -Path $File -Algorithm "$Algorithm" 
}

# Save results to file.
$Hashes | Out-File "$File.hashes.txt"
