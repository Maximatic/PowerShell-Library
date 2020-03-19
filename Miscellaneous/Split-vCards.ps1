<#
.SYNOPSIS
    Reads vCard files with multiple contacts and separates them into separate VCF files.
.DESCRIPTION
    Multiple contacts exported from devices such as Android smartphones are typically saved to a single VCF file.
    Programs like Microsoft Outlook can only import one vCard at at time so the individual vCards must be split up into separate files before importing.
    This PowerShell script prompts for the source VCF file and will then split all of the individual vCards into separate VCF files, in a subfolder called .\SplitvCards.
.NOTES
    File Name      : Split-vCards.ps1
    Prerequisite   : PowerShell 3+
    Date           : 2017-12-03
#>

# Function to bring up an OpenFileDialog to select the VCF file for splitting
Function Get-FileName($initialDirectory) {   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filename = ""
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select VCARD Filename"
    $OpenFileDialog.filter = "VCARD File (*.vcf)| *.vcf"
    $OpenFileDialog.ShowDialog() | Out-Null
    Return $OpenFileDialog.filename
}

# ************* Main Script Block *************

Clear-Host

# Define Variables
$DestinationFolder = "$PSScriptRoot\SplitvCards"

# Prompt for the source VCF file to split
$vCardFilename = Get-FileName -initialDirectory $PSScriptRoot 

# Check to see if a source file was indeed selected
If ($vCardFilename -ne "") {
    
    # Get the contests of the selected VCF file and store it in a variable
    $vCardFile = Get-Content $vCardFilename

    # Create a subfolder to hold the separated vCard files
    if(!(Test-Path -Path $DestinationFolder)){
       New-Item -ItemType Directory -Path $DestinationFolder
    }
    
    # Iterate through each line of the selected VCF file and process them
    foreach($Line in $vCardFile) {
        
        # Split the property and value
        $Property = $Line.Split(':')
        
        # Check for the Beginning, End, Full Name and Organization properties
        switch ($Property[0]) { 
            # Check if the current line is the beginning of a vCard
            BEGIN {                
                # Reset vCard array and property variables
                $vCard = @()
                if ($Name) { Clear-Variable Name -Force }
                if ($FN) { Clear-Variable FN -Force }
                if ($ORG) { Clear-Variable ORG -Force }
            } 
            # Check if the current line contains the Full Name
            FN {
                $FN = $Property[1]
            }
            # Check if the current line contains the Organization
            ORG {
                $ORG = $Property[1]
            }
            # Check if the current line is the end of a vCard
            END {
                # Generate timestamp for creating unique filenames for duplicate names
                $Date = $(get-date).Tostring('hhmmssfff')
                # Add last line to vCard array
                $vCard = $vCard + $Line
                # If FullName property exists, use that for the filename, else use the Organization name
                if ($FN -ne $null) { $Name = $FN } else { $Name = $ORG }
                # If the contact doesn't have a FullName or Organization property, call it NoName
                if ($Name -eq $null) { $Name = "NoName" }
                # Deal with duplicate names
                if((Test-Path -Path "$DestinationFolder\$Name.vcf")) {
                       $Filename = "$Name $Date.vcf"
                    } else { $Filename = "$Name.vcf" }
                # Save vCard to file
                $vCard | Out-File "$DestinationFolder\$Filename" -Encoding ascii -NoClobber -Verbose
            }
        }
        # Add current line to vCard array
        $vCard = $vCard + "$Line"
    } 
} else { 
    # Bail out if user cancelled out of OpenDialog
    Write-Host "Cancelled.`n"
    Exit
}

# Clean-up Variables
if ($vCard) { Clear-Variable vCard -Force }
if ($vCardFile) { Clear-Variable vCardFile -Force }
if ($vCardFilename) { Clear-Variable vCardFilename -Force }
if ($Name) { Clear-Variable Name -Force }
if ($FN) { Clear-Variable FN -Force }
if ($ORG) { Clear-Variable ORG -Force }
if ($Line) { Clear-Variable Line -Force }
if ($Date) { Clear-Variable Date -Force }
if ($Filename) { Clear-Variable Filename -Force }
