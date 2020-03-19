Function Get-AwsIpRanges {
<#
.SYNOPSIS
    Gets the current list of AWS IP address ranges.
.DESCRIPTION
    This simple function downloads and displays the current list of IPv4 and IPv6 ranges. 
    
    The list is provided by Amazon in JSON format.
.NOTES
    File Name      : Get-AwsIpRanges.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2019-06-20
.PARAMETER IPv6
    Switch: Use to display the IPv6 IP address ranges.
.PARAMETER Region
    Specify a specific region. Wildcards can also be used. e.g. "us*" can be used to return all US regions.

    Current regions include:

        af-south-1    
        ap-east-1     
        ap-northeast-1
        ap-northeast-2
        ap-northeast-3
        ap-south-1    
        ap-southeast-1
        ap-southeast-2
        ca-central-1  
        cn-north-1    
        cn-northwest-1
        eu-central-1  
        eu-north-1    
        eu-west-1     
        eu-west-2     
        eu-west-3     
        GLOBAL        
        me-south-1    
        sa-east-1     
        us-east-1     
        us-east-2     
        us-gov-east-1 
        us-gov-west-1 
        us-west-1
        us-west-2
.PARAMETER Service
    Specify a specific service. Wildcards can also be used here.

    Current services include:

        AMAZON              
        AMAZON_CONNECT      
        CLOUD9              
        CLOUDFRONT          
        CODEBUILD           
        DYNAMODB            
        EC2                 
        GLOBALACCELERATOR   
        ROUTE53             
        ROUTE53_HEALTHCHECKS
        S3
.EXAMPLE
    Get-AwsIpRanges
    Display all IPv4 ranges, regions and services.
.EXAMPLE
    Get-AwsIpRanges -IPv6
    Display all IPv6 ranges, regions and services.
.EXAMPLE
    Get-AwsIpRanges -Region us-east-1
    Display all IPv4 ranges in region us-east-1
.EXAMPLE
    Get-AwsIpRanges -Region us*
    Display all IPv4 ranges in US regions, using a wildcard.
.EXAMPLE
    Get-AwsIpRanges -Service S3
    Display all IPv4 ranges for S3 services.
.EXAMPLE
    Get-AwsIpRanges -IPv6 -Region eu-central-1 -Service EC2
    Display all EC2 IPv6 ranges in the eu-central-1 region.
.EXAMPLE
    Get-AwsIpRanges | Out-GridView
    Display all IPv4 ranges in a gridview
.EXAMPLE
    Get-AwsIpRanges | Select-Object IpRange | Export-Csv "AmazonIPv4Ranges_$DateStr.csv" -NoTypeInformation
    Export all of the IPv4 address ranges to a CSV
.EXAMPLE
    Get-AwsIpRanges -IPv6 | Select-Object IpRange | Export-Csv "AmazonIPv6Ranges_$DateStr.csv" -NoTypeInformation
    Export all of the IPv6 address ranges to a CSV
#>
Param(
    [Parameter(ParameterSetName = "IPv6", Position = 1)]
    [Switch]$IPv6,
    [string]$Region = "*",
    [string]$Service = "*"
    )

    # Generate date/time string
    $DateStr = $(Get-Date).ToString('yyyyMMddHHmm')

    # Define the URL that contains the current list of IP ranges. 
    $Url = "https://ip-ranges.amazonaws.com/ip-ranges.json"

    # Force the webrequest below to use TLS 1.2. By default, PowerShell uses TLS 1.0, which may not work in some cases.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Download content (JSON)
    $Response = Invoke-WebRequest -Uri $Url -Headers $headers -ContentType "application/json" -Method Get -UseBasicParsing

    # Parse the JSON and put it into an array
    $Content = $Response.Content | Out-String | ConvertFrom-Json

    If ($PsCmdlet.ParameterSetName -ieq "IPv6") {
        $Content.ipv6_prefixes | 
            Select-Object `
                @{ Expression={$_.ipv6_prefix}; label='IpRange' },
                @{ Expression={$_.region}; label='Region' },
                @{ Expression={$_.service}; label='Service'; } |
            Where-Object { $_.Region -like $Region -and $_.Service -like $Service } | Sort IpRange
    } else {
        $Content.prefixes | 
            Select-Object `
                @{ Expression={$_.ip_prefix}; label='IpRange' },
                @{ Expression={$_.region}; label='Region' },
                @{ Expression={$_.service}; label='Service'; } | 
            Where-Object { $_.Region -like $Region -and $_.Service -like $Service } | Sort IpRange
    }

}
