<#
.SYNOPSIS
    AD Computer Account DN to CN Converter
.DESCRIPTION
    Converts Active Directory computer account Distiguished Names to Canonical names.
.NOTES
    File Name      : ConvertDN2CN.ps1
    Prerequisite   : PowerShell V2.
    Date           : 2015-10-08
    Last Modified  : 2015-10-08
    Requirements   : Import-Module ActiveDirectory
.EXAMPLE
    Load Function  : . ".\ConvertDN2CN.ps1"
    Command        : ConvertDN2CN($Server = "Server01")
    DN             : CN=Server01,OU=SQL,OU=Servers,DC=intranet,DC=domain,DC=com
    CN             : intranet.domain.com/Servers/SQL/Server01
#>

Function ConvertDN2CN($Server) {
    $DN = $(Get-ADComputer $Server).distinguishedName

    $Parts = $DN.Split(",")

    # Get DC Parts (intranet.domain.com)
    $DCParts = ($Parts -match 'DC')

    # Get OU Parts
    $OUParts = ($Parts -match 'OU')

        # Reverse array contents to reverse the path for OU
        [array]::Reverse($OUParts)

    # Get CN
    $CNParts = ($Parts -match 'CN')

        foreach($DCPart in $DCParts) {
            $Attribute  = $DCPart.Split("=")
            $CN += "." + $Attribute[1]
        }
        foreach($OUPart in $OUParts) {
            $Attribute  = $OUPart.Split("=")
            $CN += "/" + $Attribute[1]
        }
        foreach($CNPart in $CNParts) {
            $Attribute  = $CNPart.Split("=")
            $CN += "/" + $Attribute[1]
            $CN = $CN.substring(1,($CN.length)-1) # Get rid of leading dot
        }

    Return $CN
}
