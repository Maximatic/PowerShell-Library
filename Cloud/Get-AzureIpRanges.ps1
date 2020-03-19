<#
.SYNOPSIS
    Retrieves the current list of Microsoft Azure Datacenter IP Ranges and saves them to a CSV file.
.DESCRIPTION
    This simple script downloads the current list of Microsoft Azure IP ranges from Microsoft and saves them to
    a CSV file. You can easily modify this to output to a Table ( | FT ) or GridView ( | Out-GridView ) as well.
    This list is provided by Microsoft in XML format.
.NOTES
    File Name      : Get-AzureIpRanges.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2019-06-15

    ##### XML Structure #####
    <AzurePublicIpAddresses xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <Region Name="uswest2">
            <IpRange Subnet="13.66.128.0/17"/>
            <IpRange Subnet="13.77.128.0/18"/>
            <IpRange Subnet="13.104.145.0/26"/>
            ...
        </Region>
#>
# Clear Screen
Clear-Host

#  Generate date/time string building the output CSV filename.
$DateStr = $(Get-Date).ToString('yyyyMMddHHmm')

# This is the Microsoft confirmatiln download URL that contains the link for the Azure IP ranges XML file.
$DownloadUrl = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653"

# Grab the content of the download page so we can search for the link.
$Response = Invoke-WebRequest -Uri $DownloadUrl -Method Get -UseBasicParsing

# Grab the link that contains a file like "PublicIPs_*.xml". The filename has the latest date in it (e.g. PublicIPs_20190612.xml).
$Href = $Response.Links | Where-Object { $_.href -like '*PublicIPs_*.xml' } | Select-Object href -ExpandProperty href -Unique

# Grab the filename from the full HREF.
$FileName = Split-Path $Href -leaf

# Download the XML File. This is only for reference and is not required for the rest of the script to work.
# $WebClient = New-Object System.Net.WebClient
# $WebClient.DownloadFile($Href,$FileName)

# Download the contents of the XML file and stuff it into a variable.
[xml]$Xml = (New-Object System.Net.WebClient).DownloadString("$Href")

# Define array for processing the XML.
$Array = @()

# Iterate through each IpRange element.
foreach($Element in $Xml.AzurePublicIpAddresses.Region) {
    
    # Add the Region name and IpRange to the array.
    $Array += New-Object -TypeName psobject -Property @{Region=$Element.Name; IpRange=$Element.IpRange}

}

# Select the Region and IpRange properties and sort them. 
# Extracting the IpRange property seperates the Subnets into seperate rows.
$Results = $Array | Select Region, IpRange -ExpandProperty IpRange | Sort Region, Subnet

# Select the Region and Subnet properties and export the results to a CSV file.
$Results | Select Region, Subnet | Export-Csv "AzureIPRanges_$DateStr.csv" -NoTypeInformation
