<#
.SYNOPSIS
    Lists Distributed File System (DFS) links and their associated targets 
    for all domain-based DFS namespaces.
.DESCRIPTION
    This script automatically detects domain-based DFS namespaces and displays 
    all links and their respective targets, in a sorted GridView.
.NOTES
    File Name      : Get-DomainDFSLInks.ps1
    Prerequisites  : PowerShell 4.0+
                     Remote System Administration Tools (RSAT)
                     Dfsutil.exe
    Date           : 2018-07-11
#>

#declare empty array to hold results
$result = @()

#get temp directory
$TempDir = $env:TEMP

#check to make sure that this computer is joined to a domain and that the script is being run with a domain account
if ( ( ((Get-WmiObject Win32_ComputerSystem).partofdomain) -eq $False ) -or ( -not $Env:USERDNSDOMAIN ) ) {
    Write-Host 'Machine is not a domain member or the current user is not a member of the domain. Exiting.'
    exit
}

#get domain-based DFS root paths
$DFSRootPaths = Get-DfsnRoot | Select Path -ExpandProperty Path
 
#iterate through root paths
foreach($DFSRoot in $DFSRootPaths) {
    
    Write-Host "`nProcessing $DFSRoot"

    #create a temp file to hold Dfsutil.exe export data
    $tmpFile = $TempDir + "\" + "Get-DFSLinks.tmp"

    #run dfsutil.exe to export the namespace roots to temp file
    Dfsutil.exe Root Export $DFSRoot $tmpFile
    
    #read contents of namespace export file
    $XML = [xml](Get-Content $tmpFile)

        #get object properties from XML
        foreach($obj in $XML.Root.Link) {
            
            #create custom object for the results (Link Name, State and Link Target)
            $ObjectProperties = @{
                "Link Name" = "$DFSRoot\" + $obj.name
                State = $obj.target.State
                Target = $obj.target.'#text'
            }
            
            $ResultsObject = New-Object -TypeName PSObject -Property $ObjectProperties

        $result += $ResultsObject
         #if ($ResultsObject) {Return $ResultsObject}
    } 
    Remove-Item $tmpFile
}

#display results in a GridView
$result | 
    Select "Link Name", State, Target | 
    Sort "Link Name" | 
    Out-GridView

#clean-up
Clear-Variable result
Clear-Variable DFSRootPaths
Clear-Variable TempDir
Clear-Variable DFSRoot
Clear-Variable tmpFile
Clear-Variable XML
Clear-Variable obj
Clear-Variable ObjectProperties
Clear-Variable ResultsObject
