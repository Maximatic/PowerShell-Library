Function Search-UsbId {
<#
.SYNOPSIS
    Searches a list of known USB Vender ID's (VID) and Product ID's (PID).

.DESCRIPTION
    This function downloads a list of known USB VID's and PID's, parses it and then searches the list
    based on a user-supplied USB device path.

    If an exact match is found, the individual details are displayed.
    If an exact match is not found, all PID's related to the VID will be displayed instead.

.NOTES
    File Name      : Search-UsbId.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2019-07-15

.PARAMETER DevicePath
    Specify a USB device path, such as USB\VID_138A&PID_003F\00B0CA82BB24.
    The critical part is the middle section containing the VID and PID.

.PARAMETER Refresh
    Switch: Use this switch to refresh the USB ID file. The script will use a cached CSV file for faster subsequent 
    searches, so a refresh may be desired in case there are any updates to the online file.

.EXAMPLE
    Search-UsbId -DevicePath "USB\VID_138A&PID_003F\00B0CA82BB24" -Refresh

    Display any known Vendor ID's or Product ID's from the device path.

.LINK
    http://www.linux-usb.org/usb.ids

#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$DevicePath = "",
    [Switch]$Refresh
    )
    
    
    # Variables and Constants

    $Url = "http://www.linux-usb.org/usb.ids"
    $UsbIdFile = "$env:TEMP\usb.ids"
    $CsvFile = "$env:TEMP\UsbIds.csv"
    $FourHexChars = "[0-9a-fA-F]{4}"
    $List = @()
    $Counter = 0

    # Check to see if the USB ID file has been downloaded and exported to CSV yet.
    # Parsing the text file takes some time so the CSV file will contain 
    # already-parsed data to be used for subsequent searches.
    
    If (!(Test-Path -Path $CsvFile) -or ($Refresh)) {

        # Force the webrequest below to use TLS 1.2. By default, PowerShell uses TLS 1.0, 
        # which may not work in environments with stricter protocol controls.
        
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # Download USB ID's to file
        
        Invoke-WebRequest -Uri $Url -OutFile $UsbIdFile

        # Load the downloaded ID file into an array
        
        $Content = Get-Content $UsbIdFile

        # Get the number of lines in text file
        
        $LineCount = $Content.Count

        # Parse the VID's and PID's information and put them into an array.
        
        foreach($Line in $Content) {
        
            # Display progress
            
            Write-Progress -Activity "Parsing text file..." -Status "Progress" -CurrentOperation "Line $Counter of $LineCount" -PercentComplete (($Counter / $LineCount) * 100)
        
            # Stop when you reach the end of the ID section
            
            if ($Line -eq "# List of known device classes, subclasses and protocols") { Break }
        
            # Skip blank lines
            
            if ($Line.Length -eq 0) { Continue }
        
            # Skip comments
            
            if ($Line.Substring(0,1) -eq "#") { Continue }
        
            # Identify VID and VendorName columns
            
            if ($Line.Substring(0,4) -match $FourHexChars) {

                # Split VID and VendorName on same line. These are seperated by two spaces.
                
                $VID,$VendorName = $Line -split("  ")

            }

            # Identify PID and ProductName columns. These lines begin with a tab.
            
            if ($Line.StartsWith("`t")) {

                # Remove the beginning tab and split the PID and ProductName on the same line. These are seperated by two spaces.
                
                $ProdID, $ProductName = $Line.Replace("`t", "") -split("  ")

            }

            # Create new object to hold the VID, VendorName, PID and ProductName.
            
            $Object = New-Object -TypeName PSObject
            
            # Create ordered dictionary
            
            $o = [ordered]@{VID="$VID";VendorName="$VendorName";PID="$ProdID";ProductName="$ProductName"}
            
            # Add properties to our custom object
            
            $Object | Add-Member -NotePropertyMembers $o -TypeName Asset
            
            # Add the data in the custom object to our final list.
            
            $List += $Object
        
            $Counter++
        }

        # Export parsed file to CSV to be used for faster subsequent searches.
        
        $List | Export-Csv -Path $CsvFile -NoTypeInformation

    } else {
        
        # Import data from cached CSV file.
        
        $List = Import-Csv -Path $CsvFile

    }

    Write-Output "Searching..."

    # Extract VID and PID from the user-specified device path.
    
    $uVID = Select-String -InputObject "$DevicePath" -Pattern "VID_$FourHexChars" | % {$_.Matches.Value.Replace("VID_","")}
    $uPID = Select-String -InputObject "$DevicePath" -Pattern "PID_$FourHexChars" | % {$_.Matches.Value.Replace("PID_","")}

    # Display matching PIDs
    
    $Results = $List | Where { $_.VID -eq $uVID -and $_.PID -eq $uPID }
    
    # Check if there was a single result. If not, display all PID's associated with the VID.
    
    If (($Results | Measure-Object).Count -gt 0) {
        
        Write-Host "Exact match found for Vendor ID $uVID and Product ID $uPID." -ForegroundColor Green
        
        $Results

    } else {
        
        Write-Host "VID/PID match not found. Displaying all available Product IDs for the $uVID Vendor ID." -ForegroundColor Red
        
        $List | Where { $_.VID -eq $uVID } | Sort PID

    }

}
