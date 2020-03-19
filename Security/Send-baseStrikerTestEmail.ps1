<#
.SYNOPSIS
    Sends an email containing base tag links, to test for the baseStriker vulnerability.
.DESCRIPTION
    This script sends an email with two links in the body that link to Google Maps. 
    One link utilizes the base link and the other is a normal link, for comparison. 
    If the Base link works, your email provider is vulnerable to baseStriker.
.NOTES
    File Name      : Send-baseStrikerTestEmail.ps1
    Prerequisites  : PowerShell 3.0+
    Date           : 2018-07-11

    Be sure to send the email from an external source so that it will
    come in through your email threat protection.
    
    Change variable values to suit your environment.
#>

##########################
#       Variables
##########################

$SmtpServer = "smtpout.domain.com"
$FromAddress = "externaluser@domain.com"
$RcptAddress = "internaluser@domain.com"
$Subject = "baseStriker Test"
$Port = "465"

[String]$Body = @"
<html>
<head> 
    <base href="https://www.google.com/">
</head>
<body>
Click <a href="maps">Base Link</a> <br>
Click <a href="https://www.google.com/maps">Regular Link</a>
</body>
</html>

"@

##########################
#    Main Script Block
##########################

# Get Credentials for authenticating to SMTP server
$Cred = Get-Credential

# Send email
Send-MailMessage -SmtpServer $SmtpServer -From $FromAddress -To $RcptAddress -Subject $Subject -Body $Body -BodyAsHtml -Port $Port -Credential $Cred
 