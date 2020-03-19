# Security-related scripts

## Decode-O365ATPSafeLink.ps1
PowerShell script to pull out the actual URL from from an encoded Office 365 Advanced Threat Protection Safe Link. You can also decode SafeLinks at http://www.o365atp.com/.

## Generate-Password.ps1
Generates a random password and then stores it into the Windows clipboard for easy pasting.

## Get-ADS.ps1
Performs a recursive search through the user-specified path for any files containing Alternate Data Streams (ADS) and displays their contents.

## Get-HiddenDrives.ps1
Lists hidden drive letters in Windows.

## Remove-ADS.ps1
This is the same as Get-ADS.ps1, but it prompts the user to remove any Alternate Data Streams found.

## Send-baseStrikerTestEmail.ps1
This is a simple PowerShell script that sends an email containing a base tag link, to test for the baseStriker vulnerability. It sends an email containing two links in the body that link to Google Maps. One link utilizes the base link and the other is a normal link. 

HTML Code Sent:
```
<html>
<head> 
    <base href="https://www.google.com/">
</head>
<body>
Click <a href="maps">Base Link</a> <br>
Click <a href="https://www.google.com/maps">Regular Link</a>
</body>
</html>
```

If the Base link is not obfuscated, like in the image below, your email provider is vulnerable to baseStriker.

![Vulnerable Link](https://raw.githubusercontent.com/Maximatic/PowerShell-Library/master/.images/Vulnerable-Safelink.jpg "Vulnerable Link")

It should look like something this:

![Safe Link](https://raw.githubusercontent.com/Maximatic/PowerShell-Library/master/.images/Safelink.jpg "Safe Link")

When using this script, be sure to email from an external source so that it will come in through your email threat protection. If the base link works, you are vulnerable to baseStriker. If it is easier to send from your local mail relay, you can also send it outbound and then reply back.

Be sure to change the variable values to suit your environment. Just remove the credential switch if your mail relay does not require authentication.

More information on the vulnerability can be found here: [baseStriker: Office 365 Security Fails To Secure 100 Million Email Users](https://www.avanan.com/resources/basestriker-vulnerability-office-365)
