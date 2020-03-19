# Active Directory related scripts

## Backup-AllGPOs.ps1
This function allows you to backup all Active Directory (AD) Group Policy Objects (GPO's). By default, all GPO's will be backed up into a single folder with the subfolders named after a unique GUID's (e.g. 870ea56d-b243-4f23-b07b-11b8fe28e73d). These can be difficult to navigate so you can use the -NamedSubFolders switch to save each GPO into a subfolder named after the GPO name.

## Get-DomainDFSLinks.ps1
This script lists Distributed File System (DFS) links and their associated targets for all domain-based DFS namespaces. This script automatically detects domain-based DFS namespaces and displays all links and their respective targets, in a sorted GridView.
