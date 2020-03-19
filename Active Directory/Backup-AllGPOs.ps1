function Backup-AllGPOs {
<#
.SYNOPSIS

    Backup all Active Directory (AD) Group Policy Objects (GPO) to a single folder or named subfolders.

.DESCRIPTION

    This function allows you to backup all AD GPO's. By default, all GPO's will be backed up into a single folder with the subfolders named after a unique GUID's (e.g. 870ea56d-b243-4f23-b07b-11b8fe28e73d). 
    
    These can be difficult to navigate so you can use the -NamedSubFolders switch to save each GPO into a subfolder named after the GPO name.

.PARAMETER Path

    Specify the root path that the GPO's will be backed up into. A subfolder with the current date/time will be automatically created. e.g. "D:\GPO_Backups\201906141611\"

.PARAMETER NamedSubFolders

    Switch: Use to backup GPO's into SubFolders named after the GPO. e.g. "D:\GPO_Backups\201906141611\Sales Computer Lockdown Policy\"

.EXAMPLE

    Backup all GPO's into the D:\GPO_Backups\ folder.
    Backup-AllGPOs -Path D:\GPO_Backups

.EXAMPLE

    Backup all GPO's into subfolders named after the GPOs, in the D:\GPO_Backups\ root folder.
    Backup-AllGPOs -Path D:\GPO_Backups -NamedSubFolders

.NOTES
    File Name      : Backup-AllGPOs.ps1
    Prerequisites  : PowerShell 4.0+
                        Remote System Administration Tools (RSAT)
                        GroupPolicy PowerShell Module
    Date           : 2019-06-14

#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(ParameterSetName = "NamedSubFolders", Position = 1)]
    [Switch]
    $NamedSubFolders
    )

    # Get Data/Time for foldername
    $DateStr = $(Get-Date).ToString('yyyyMMddHHmm')

    # Define invalid Windows file/foldername characters
    $RegExPattern = '[#/?<>\\:*|\"]'

    # Get a list of all GPOs
    $AllGPOs = Get-GPO -All | Select DisplayName -ExpandProperty DisplayName | Sort DisplayName

    # Check for NamedSubFolders switch
    if ($PsCmdlet.ParameterSetName -ieq "NamedSubFolders") {
        # Iterate through each GPO
        foreach($GPO in $AllGPOs) {
            try {
                Write-Output $GPO
        
                # Replace all invalid Windows file/folder name characters (# / ? < > \ : * | ") with a dash ("-").
                $LegalFolderName = $GPO -replace $RegExPattern, "-"

                # Check to see if the path exists yet or not. If not, create the folder.
                if(!(Test-Path -Path "$Path\$DateStr\$LegalFolderName" )){
                    New-Item -Path "$Path\$DateStr" -Name $LegalFolderName -ItemType Directory
                }

                # Backup GPO to Named SubFolders
                Backup-GPO $GPO -Path "$Path\$DateStr\$LegalFolderName"
            }
            catch {
                Write-Output "$GPO Failed to Backup." -ForegroundColor Red
            }
        }
	} else {
        # Check to see if the path exists yet or not. If not, create the folder.
        if(!(Test-Path -Path "$Path\$DateStr" )){
            New-Item -Path "$Path\$DateStr" -ItemType Directory
        }

        # Backup all GPOs
        Backup-GPO -Path "$Path\$DateStr" -All
    }

    Write-Output "All GPOs backed up to $Path\$DateStr"
    
}

