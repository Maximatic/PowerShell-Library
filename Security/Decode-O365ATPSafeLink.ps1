<#
.SYNOPSIS
    Decodes Office 365 ATP Safe Links
.DESCRIPTION
    This script decodes Office 365 Advanced Threat Protection Safe Links. 
    The decoded URL gets displayed to the console, in a popup window, and is also copied into the clipboard for easy pasting.
.NOTES
    File Name      : Decode-O365ATPSafeLink.ps1
    Prerequisites  : PowerShell 4.0+
    Date           : 2019-02-04
.LINK
    
.NOTES
    Example SafeLink: https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.us-cert.gov%2Fncas%2Fbulletins%2FSB19-035&data=02%7C01%7C
    
    You can also find a free online decoder here: http://www.o365atp.com/
#>
Clear-Host

# Prompt user to paste in the SafeLink
$Safelink = Read-Host "Please paste in your O365 ATP SafeLink here"

# Load web assembly
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null

# Decode HTML in URL
$DecodedURL = [System.Web.HttpUtility]::UrlDecode($Safelink)

# Extract URL using RegEx pattern matching
$DecodedURL -match 'url=(\S+)(&data|;data)' | Out-Null
$URL = $Matches[1]

# Copy URL to the Clipboard
$URL | Clip

# Display decoded URL to console
Write-Host "URL:`t$URL" -ForegroundColor Green

# Display Popup Window
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("$URL",0,"Decoded URL",0x1) | Out-Null
