function Get-ADS {
<#
.SYNOPSIS
    Searches for NTFS Alternate Data Streams (ADS)
.DESCRIPTION
    This simple function does a recursive search through the user-specified path for any files containing Alternate Data Streams (ADS)
    and displays their contents.
    
    Since Alternate Data Streams are not immediatly visible to the user, it is difficult to see what is stored in them.
    
    ADS can sometimes contain privacy information or can be used by malware to hide malicious data.
.PARAMETER Path
.EXAMPLE
    Get-ADS -Path C:\Users\JDoe\Downloads
.NOTES
    File Name      : Get-ADS.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2019-06-01
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Path    
)

    # Do a recursive search for all files containing Alternate Data Streams (ADS) and put the results in the $Files variable.
    # This excludes the default ":$DATA" stream that contains the main content of the file.
    
    $Files = Get-ChildItem -Path $Path -Recurse | Get-Item -Stream * | Select FileName, Stream | Where { $_.Stream -ne ":`$DATA" }

    # Loop through files found to contain ADS
    foreach($File in $Files) {
        
        $FileName = $File.FileName
        $StreamName = $File.Stream
        
        # Get stream content
        $StreamData = Get-Content $FileName -Stream $StreamName

        # Display Filename, stream name and contents
        Write-Host "Filename: `t`t$FileName"
        Write-Host "Stream Name:`t$StreamName"
        Write-Host "Stream Content:`t" -NoNewline
        Write-Host "$StreamData`n" -ForegroundColor Black -BackgroundColor White;
    }

}
