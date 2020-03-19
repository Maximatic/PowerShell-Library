<#
.SYNOPSIS
    Searches security groups for all nested group members.
.DESCRIPTION
    This script will recursively search all nested groups and return a list of all individual user accounts
    that are members. This is helpful for determining exactly who has access to resources when there are 
    complicated nested group memberships.
.NOTES
    File Name      : Get-ADNestedGroupMembership.ps1
    Prerequisites  : PowerShell 3.0+
                     Remote System Administration Tools (RSAT)
                     ActiveDirectory PowerShell Module
    Date           : 2018-01-09
#>
Import-Module ActiveDirectory

Clear-Host

# Prompt for Group Name
$Group = Read-Host "Enter Group Name"

# Get the Distinguished Name of the group for use by the DirectorySearcher
$DistinguishedName = Get-ADGroup $Group | Select DistinguishedName -ExpandProperty DistinguishedName

# Create DirectorySearcher Object
$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher

# Set Filter for User objects
$DirectorySearcher.Filter = "(&(objectCategory=User)(memberOf:1.2.840.113556.1.4.1941:=$DistinguishedName))"

# Search and stuff the results into the $Users variable
$Users = $DirectorySearcher.FindAll().Properties.name 

# Output the results to the screen
Write-Output $Users
