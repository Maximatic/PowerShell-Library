<#
.SYNOPSIS
    Lists hidden drives in Microsoft Windows
.DESCRIPTION
    This script grabs the NoDrives value from the Windows registry and translates the bitwise value into all of the the separate drive letters marked as hidden.
.NOTES
    File Name      : Get-HiddenDrives.ps1
    Prerequisite   : PowerShell v2+
    Date           : 2017-11-14
.REFERENCES
    https://technet.microsoft.com/en-us/library/cc938267.aspx
#>

# Hash table of drive letter values
$Drives = @{ 1 = "A:"; 2 = "B:"; 4 = "C:"; 8 = "D:"; 16 = "E:"; 32 = "F:"; 64 = "G:"; 128 = "H:"; 256 = "I:"; 512 = "J:"; 1024 = "K:"; 2048 = "L:"; 4096 = "M:"; 8192 = "N:"; 16384 = "O:"; 32768 = "P:"; 65536 = "Q:"; 131072 = "R:"; 262144 = "S:"; 524288 = "T:"; 1048576 = "U:"; 2097152 = "V:"; 4194304 = "W:"; 8388608 = "X:"; 16777216 = "Y:"; 33554432 = "Z:"; }

# Get the decimal value of NoDrives key from the registry
$NoDrivesVal = Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\" -Name NoDrives | Select NoDrives -ExpandProperty NoDrives

Write-Host "Hidden Drives:"
$Drives.Keys | Where { $_ -band $NoDrivesVal } | Sort | foreach { $Drives.Get_Item($_) }
