<#
.SYNOPSIS
    List all GPO's that are not linked to any OU's.
.DESCRIPTION
    This simple script lists all Active Directory (AD) Group Policy Objects (GPO) that are not linked to any Organizational Units (OU).
.NOTES
    File Name      : Get-UnlinkedGPOs.ps1
    Prerequisites  : PowerShell 3.0+
                     Remote System Administration Tools (RSAT)
                     GroupPolicy PowerShell Module
    Date           : 2019-06-11
#>
Import-Module GroupPolicy

Clear-Host

$List = @()

# Get an XML report on all GPO's. This report contains all of the links, among other things.
[xml]$XmlGPOReport = Get-GPOReport -All -ReportType Xml

# Iterate through each GPO
foreach($GPO in $XmlGPOReport.GPOS.GPO) {
    
    # Check to see if the "LinksTo" element exists. If not, then add to the list.
    if ($GPO.LinksTo -eq $null) { $List += $GPO.Name }
}

# Display final list of unlinked GPO's.
Write-Output $List | Sort
