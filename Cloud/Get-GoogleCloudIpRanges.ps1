<#
.SYNOPSIS
    Retrieves the current list of Google Cloud IP Ranges and saves them to a CSV file.
.DESCRIPTION
    This simple script downloads the current list of Google Cloud IP ranges from Google DNS and saves them to
    a CSV file. You can easily modify this to output to a Table ( | FT ) or GridView ( | Out-GridView ) as well.
    This list is provided by Google through DNS queries.
.NOTES
    File Name      : Get-GoogleCloudIpRanges.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2019-06-15
.LINK
    https://cloud.google.com/compute/docs/faq#find_ip_range
#>

# Clear the screen
Clear-Host

#  Generate date/time string building the output filename.
$DateStr = $(Get-Date).ToString('yyyyMMddHHmm')

# Define arrays
$NetBlocks = @()
$IpRanges = @()

# Query the main Google netblock DNS TXT record to discover all of the other netblock DNS records (e.g. _cloud-netblocks1.googleusercontent.com).
$RootNetblock = Resolve-DnsName _cloud-netblocks.googleusercontent.com -Type TXT | Select-Object Strings -ExpandProperty Strings

# Parse out all of the the netblock includes.
# Split the response by spaces and select only the include: records.
$Netblocks = $RootNetblock -split ' ' | Select-String -Pattern 'include:'
# Remove the "include:" string to give us only the record.
$Netblocks = $Netblocks -replace 'include:', ''

# The following foreach loop checks for any sub netblocks specified in the initial set of discovered netblocks.
# For example: _cloud-netblocks6.googleusercontent.com and _cloud-netblocks7.googleusercontent.com appear 
# under _cloud-netblocks1.googleusercontent.com, instead of # under the root _cloud-netblocks.googleusercontent.com record.

# Iterate through each netblock and look for any other includes.
foreach($Netblock in $Netblocks) {
    
    # Query netblock#
    $Answer = Resolve-DnsName $Netblock -Type TXT | Select-Object Strings -ExpandProperty Strings

    # Split the response by spaces and select only the include: records, if they exist.
    $Answer = $Answer.Strings -split ' ' | Select-String -Pattern 'include:'

    # Replace the "include" string and add any include records to the Netblocks list.
    $Netblocks += $Answer -replace 'include:', ''
}

# Now go through the final list of netblock records and grab the IP ranges.

# Iterate through each netblock domain and parse out the IP CIDR addresses.
foreach($Domain in $Netblocks) {

    # Query the netblock domain.
    $Answer = Resolve-DnsName $Domain -Type TXT | Select-Object Strings #-ExpandProperty Strings

    # Split the response by spaces and select only the ip4 records.
    $IpRange = $Answer.Strings -split ' ' | Select-String -Pattern 'ip4:'

    # Add the IP range to the list.
    $IpRanges += $IpRange -replace 'ip4:'
}

# Export the results to a CSV file.
$IpRanges | Sort | Out-File "GoogleCloudIPRanges_$DateStr.csv"

