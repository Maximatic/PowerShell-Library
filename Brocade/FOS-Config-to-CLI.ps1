<#
.SYNOPSIS
    
    This script parses a user-defined configuration backup file from a Brocade 
    Fibre-Channel (FC) switch running Fabric OS (FOS) and generates the CLI commands that 
    can be used to easily recreate the config, aliases and zones on another switch. 

    This is useful for backups, migrations or Disaster Recover (DR) situations.   

.DESCRIPTION

    The script will first prompt for the location of the switch configuration backup 
    with an Open File Dialog box. Then the script will generate a new text 
    file containing the CLI commands for creating the same configuration, aliases 
    and zones. 
    
    The script saves the file containing the CLI commands in the same folder as the script. 
    You can then simply copy and paste the CLI commands into the destination switch's console.

.NOTES

    File Name      : FOS-Config-to-CLI.ps1
    Prerequisite   : PowerShell 3.0+
    Date           : 2012-07-16

.NOTES
    
    Limitations: 
    
    This script will not work on config backups that contain more than one configuration.
    This script also only works with soft zoning.

    Disclaimer: 
    
    This is for information purposes only. I am not resplonsible for any problems 
    resulting from the use of this script. This script has been tested and used with 
    Brocade/EMC DS-5100B and DCX FC switches running FOS 7.0-7.1.x.
    
    ALWAYS validate the integrity of the CLI commands and test them before running them 
    in a production environment.

#>

# OpenFileDialog function
Function Get-FileName($initialDirectory) {   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filename = "" # e.g. Switch01_v6.3.0c_2012-07-09.txt
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select TXT Filename"
    $OpenFileDialog.filter = "Text File (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    Return $OpenFileDialog.filename
}

Clear-Host

# Define Arrays
$cfgArray = @()
$aliasArray = @()
$zonesArray = @()

# Prompt for the FOS Configuration Backup File
$configFile = Get-FileName -initialDirectory $PSScriptRoot

# Check to see if a file was indeed selected
If ($configFile -ne "") {

    foreach ($line in Get-Content $configFile)  {

	    # Trim off any extra spaces on the line
        $line = $line.Trim()

        # Get the name of switch in the config file to use in the output filename
        if ($line.StartsWith("SwitchName")) {

            $switchName = $line.Replace("SwitchName = ", "")

        }
    
        # Get the version of the FOS in the config file to use in the output filename
        if ($line.StartsWith("FOS version = ")) {

            $fosVersion = $line.Replace("FOS version = ", "")

        }
    
        # Process Configuration
        if ($line.StartsWith("cfg.")) {

            $cfgName = $line.Replace("cfg.", "")

            # Find position of first semicolon
            $pos = $cfgName.IndexOf(":") + 1;

            # Get all text after first semicolon
            $WWN = $cfgName.Substring($pos, $cfgName.length - $pos)

            # Split strings between semicolons into an array
            $cfgName = $cfgName.split(":")

            # Grab Config members from array
            $cfgName = $cfgName[1]

            # Generate FOS command to create the Configuration
            $cmd = "cfgcreate `"Production`", `"$cfgName`""

            # Add command to Array
            $cfgArray = $cfgArray + $cmd

            # Add cfgsave command to Array
            $cfgArray = $cfgArray + "cfgsave"
        }
    
        # Process Aliases
        if ($line.StartsWith("alias.")) {

            $alias = $line.Replace("alias.", "")

            # Find position of first semicolon
            $pos = $alias.IndexOf(":") + 1;

            # Get all text after first semicolon
            $WWN = $alias.Substring($pos, $alias.length - $pos)

            # Split strings between semicolons into an array
            $alias = $alias.split(":")

            # Grab Alias Name from array
            $aliasName = $alias[0]

            # Generate FOS command to create the Alias
            $cmd = "alicreate `"$aliasName`", `"$WWN`""

            # Add command to Array
            $aliasArray = $aliasArray + $cmd

        }
    
        #Process Zones
        if ($line.StartsWith("zone.")) {

            $zone = $line.Replace("zone.", "")

            # Split strings between semicolons into an array
            $zone = $zone.split(":")

            # Grab Zone Name from first string
            $zoneName = $zone[0]

            # Grab Zone Members from Second string
            $zoneMembers = $zone[1]

            # Generate FOS command to create the Zone
            $cmd = "zonecreate `"$zoneName`", `"$zoneMembers`""

		    # Add command to Array
            $zonesArray = $zonesArray + $cmd

        }
    }

    # Generate timestamp for creating a unique filename
    $timestamp = $(get-date).Tostring('yyyy-MM-dd-hh-mm-ss') 

    # Generate Output Filename
    $outputFile = "$switchName $fosVersion CLI Config $timestamp.txt"

    # Create Output File
    $cfgArray + $aliasArray + $zonesArray + "cfgenable Production" > $outputFile

} else {  
    
    # Bail out if user cancels out of the OpenDialog 
    Write-Host "Cancelled.`n" 
    
    Exit 

} 

