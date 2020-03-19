<#
.SYNOPSIS
    Random password generator.
.DESCRIPTION
    Generates a random password and then stores it into the Windows clipboard for easy pasting.
.NOTES
    File Name      : Generate-Password.ps1
    Prerequisite   : PowerShell 2.0+
    Date           : 2019-02-02
#>

# Character array of possible character from which to choose from. Add or remove any characters you see fit.
$Characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#()[],.<>/?-+_*".ToCharArray()

# Prompt user for the number of characters to generate.
[int]$CharNum = Read-Host "How many characters would you like? [Default=25]"

# Set the default to 25, if none entered.
if($CharNum -eq 0){ $CharNum = 25}

# Generate password
[char[]]$Passwd = Get-Random -Count $CharNum -InputObject $Characters

# Join the password array and store it in a string
$PasswdStr = -join $Passwd

# Send the generated password string to the clipboard
$PasswdStr | Clip
