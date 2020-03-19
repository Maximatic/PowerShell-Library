<#
.SYNOPSIS
    Lists the links for all GPO's in the domain.
.DESCRIPTION
    This simple script lists all Active Directory (AD) Group Policy Objects (GPO) with their associated links.
.NOTES
    File Name      : Get-GPOLinks.ps1
    Prerequisites  : PowerShell 3.0+
                     Remote System Administration Tools (RSAT)
                     GroupPolicy PowerShell Module
    Date           : 2019-06-11
#>
Import-Module GroupPolicy

Clear-Host

$Links = @()

# Get list of all GPO's
$AllGPOs = Get-GPO -All | Select DisplayName -ExpandProperty DisplayName

# Create XML GPO report
[xml]$XmlGPOReport = Get-GPOReport -All -ReportType Xml

# Iterate through each GPO in the XML GPO report
foreach($GPO in $XmlGPOReport.GPOS.GPO) {
    
    #Grab the Name and Scope of Managmeent (SOM) Path from the LinksTo element within each GPO.
    $Links += $GPO | Select-Object Name, @{ Name="SOM Path";Expression={ $_.LinksTo | % { $_.SOMPath } } }

}

# Write results to the screen
Write-Output $Links | FT -Wrap
