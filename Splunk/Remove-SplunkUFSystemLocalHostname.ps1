<#
.SYNOPSIS
    Comments out the Splunk Universal Forwarder (UF) system local hostname settings to allow app-based local 
    settings to configure the UF hostname.
.DESCRIPTION
    If the Windows hostname is changed after the Splunk UF was first installed, Splunk will keep using the 
    original hostname until the it is changed manually in the Splunk conf files. 
    In order to make the UF hostname dynamic, the hostname and serverName settings in the Splunk UF system local
    inputs.conf and server.conf files need to be removed because system local settings takes precidence over app local.
    This script will comment out the necessary hostname fields so that the hostname settings can be managed through 
    app-based settings managed by the Splunk deployment server.
.NOTES
    File Name      : Remove-SplunkUFSystemLocalHostname.ps1
    Author         : Maximatic
    Prerequisites  : PowerShell 3.0+
    Version        : 1.0
    Date           : 2020-10-21
#>

### Declare Variables ###
    $ChangeCount = 0
    If (Test-Path -Path HKLM:\SYSTEM\CurrentControlSet\Services\SplunkForwarder) {
        $SPLUNK_HOME = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\SplunkForwarder).ImagePath | Select-String -Pattern '\"(.*?)bin' | % { $_.Matches.Groups[1].Value }
        $InputsPath = "$SPLUNK_HOME\etc\system\local\inputs.conf"
        $ServerPath = "$SPLUNK_HOME\etc\system\local\server.conf"
    } else { Exit }

# Comment out hostname in inputs.conf
    If (Test-Path -Path $InputsPath) {
        $InputsCurrentHostField = Select-String -Path $InputsPath -Pattern 'host\s=\s.*?$' | % { $_.Matches[0].Value }
        $InputsCurrentHostLine = Select-String -Path $InputsPath -Pattern '.*?host\s=\s.*?$' | % { $_.Matches[0].Value }
        $InputsDesiredHostLine = "# $InputsCurrentHostField"
        If ($InputsCurrentHostLine -ne $InputsDesiredHostLine) {
            (Get-Content -Path $InputsPath -Raw) -replace $InputsCurrentHostLine, $InputsDesiredHostLine | Set-Content -Path $InputsPath -NoNewline
            $ChangeCount++
        }
    }

 # Comment out serverName in server.conf
    If (Test-Path -Path $ServerPath) {
        $ServerCurrentNameField = Select-String -Path $ServerPath -Pattern 'serverName\s=\s.*?$' | % { $_.Matches[0].Value }
        $ServerCurrentNameLine = Select-String -Path $ServerPath -Pattern '.*?serverName\s=\s.*?$' | % { $_.Matches[0].Value }
        $ServerDesiredNameLine = "# $ServerCurrentNameField"
        If ($ServerCurrentNameLine -ne $ServerDesiredNameLine) {
            (Get-Content -Path $ServerPath -Raw) -replace $ServerCurrentNameLine, $ServerDesiredNameLine | Set-Content -Path $ServerPath -NoNewline
            $ChangeCount++
        }
    }

# Restart SplunkForwarder service
If ($ChangeCount -gt 0) {
    If (Get-Service -Name SplunkForwarder) {
        Restart-Service -Name SplunkForwarder -Force
    }
}
