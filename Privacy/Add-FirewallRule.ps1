<#
.SYNOPSIS
    Creates new outbound Windows firewall rules to recursively block all programs within a specified folder.
.DESCRIPTION
    This is a simple script that creates new firewall rules to block all executables within a specified folder.
    This can be used for blocking spyware or phone-home functionality within otherwise legitimate applications.
.NOTES
    File Name      : Add-FirewallRule.ps1
    Prerequisite   : PowerShell 2.0+
    Date           : 2018-07-14
    
    netsh.exe command-line example:
    netsh advfirewall firewall add rule Name="C:\Program Files (x86)\Microsoft SkyDrive\SkyDriveSetup.exe" Direction=Out Program="C:\Program Files (x86)\Microsoft SkyDrive\SkyDriveSetup.exe" Action=Block Enable=yes Profile=Any LocalIP=Any RemoteIP=Any protocol=Any
#>

Clear-Host

# Set folder and file mask here:
$AppFolderFileMask = "C:\Program Files\CCleaner\*.exe"

# Get recursive list of files based on the folder and file mask
$Files = Get-ChildItem $AppFolderFileMask -Recurse | % { $_.FullName }

# Iterate through all files
foreach($File in $Files) {
    # Create outbound program block rule
    netsh advfirewall firewall add rule Name="$File" Direction=Out Program="$File" Action=Block Enable=yes Profile=Any LocalIP=Any RemoteIP=Any protocol=Any
}
