<#
.SYNOPSIS
    Finds detached database files locally on Microsoft SQL Servers.
.DESCRIPTION
    Searches all local drives for detached SQL Server database files. 
    This can help mitigate the security risk of having forgotten unattached databases
    or to simply identify inactive database files to free up space.
.NOTES
    File Name      : Get-DetachedDBs.ps1
    Prerequisite   : PowerShell v2.0
    Date           : 2015-06-16
#>

# ***************************** Functions Script Block *****************************

function Get-HardDrives { 
  @(Get-WmiObject win32_logicaldisk -filter 'DriveType=3' | 
  ForEach-Object { $_.DeviceID }) 
}

# ******************************** Main Script Block ********************************

Clear-Host

# Get List of hard drives on the server
$Drives = Get-HardDrives

# Get list of attached databases from SQL Server
$AttachedFiles = Invoke-Sqlcmd -query "SELECT physical_name FROM sys.master_files" 

# Suppress error messages for following file search
$ErrorActionPreference = 'SilentlyContinue'
        
# Search all hard drives for any database files
foreach($Drive in $Drives) {
    $AllDBFiles = gci $Drive -Include *.mdf,*.ndf,*.ldf -Recurse -Force | select FullName -ExpandProperty FullName
}

# Make error messages visible again after file search
$ErrorActionPreference = 'Continue'

# Compare list of database files found with those attached
$DetachedDBFiles = Compare-Object $AllDBFiles $AttachedFiles.'physical_name' | Select InputObject -ExpandProperty InputObject

# Display findings
If ($DetachedDBFiles) {
    Write-Host "The following detached database files were found:" -ForegroundColor Red
    $DetachedDBFiles
} Else {
    Write-Host "No detached database files were found." -ForegroundColor Green
}