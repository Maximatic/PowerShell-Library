## FOS-Config-to-CLI.ps1
This script parses a user-defined configuration backup file from a Brocade Fibre-Channel (FC) switch running Fabric OS (FOS) and generates the CLI commands that can be used to easily recreate the same config, aliases and zones on another switch. This is very useful for backups, migrations or Disaster Recover (DR) situations.

Here is an example config file that might be used as input:
<pre>
[Configuration upload Information]
Configuration Format = 3.0
Minimum Compatible Format = 3.0
Excluding Format = 0.0
date = Mon Nov 12 11:21:58 2012
FOS version = v7.0.1.0
Number of LS = 1
[Switch Configuration Begin : 0]
SwitchName = switch01
Fabric ID = 128

[Boot Parameters]

[Configuration]

[Bottleneck Configuration]

[FCOE_SW_CONF]

[Zoning]
cfg.Production:SRV1_SAN1;SRV2_SAN1;SRV3_SAN1;SRV4_SAN1;SRV5_SAN1
zone.SRV1_SAN1:SAN1_SPA_P0;SAN1_SPB_P0;SRV1_Slot1_P1
zone.SRV2_SAN1:SAN1_SPA_P0;SAN1_SPB_P0;SRV2_Slot1_P1
zone.SRV3_SAN1:SAN1_SPA_P0;SAN1_SPB_P0;SRV3_Slot1_P1
zone.SRV4_SAN1:SAN1_SPA_P0;SAN1_SPB_P0;SRV4_Slot1_P1
zone.SRV5_SAN1:SAN1_SPA_P0;SAN1_SPB_P0;SRV5_Slot1_P1
alias.SRV1_Slot1_P1:40:00:11:1b:24:12:df:62
alias.SRV2_Slot1_P1:40:00:11:1b:24:12:dc:62
alias.SRV3_Slot1_P1:40:00:11:1b:24:12:64:69
alias.SRV4_Slot1_P1:40:00:11:1b:24:12:bb:19
alias.SRV5_Slot1_P1:40:00:11:1b:24:12:51:01
alias.SAN1_SPA_P0:51:05:21:60:38:b0:3c:e6
alias.SAN1_SPB_P0:51:05:21:69:38:b0:3c:e6
defzone:noaccess
enable:Production

[Defined Security policies]

[Active Security policies]

[iSCSI]

[cryptoDev]

[FICU SAVED FILES]

[VS_SW_CONF]

[Banner]

[End]
[Switch Configuration End : 0]
</pre>

And here is an example of what the output would look like, generated from the config file above:
<pre>
cfgcreate "Production", "SRV1_SAN1;SRV2_SAN1;SRV3_SAN1;SRV4_SAN1;SRV5_SAN1"
cfgsave
alicreate "SRV1_Slot1_P1", "40:00:11:1b:24:12:df:62"
alicreate "SRV2_Slot1_P1", "40:00:11:1b:24:12:dc:62"
alicreate "SRV3_Slot1_P1", "40:00:11:1b:24:12:64:69"
alicreate "SRV4_Slot1_P1", "40:00:11:1b:24:12:bb:19"
alicreate "SRV5_Slot1_P1", "40:00:11:1b:24:12:51:01"
alicreate "SAN1_SPA_P0", "51:05:21:60:38:b0:3c:e6"
alicreate "SAN1_SPB_P0", "51:05:21:69:38:b0:3c:e6"
zonecreate "SRV1_SAN1", "SAN1_SPA_P0;SAN1_SPB_P0;SRV1_Slot1_P1"
zonecreate "SRV2_SAN1", "SAN1_SPA_P0;SAN1_SPB_P0;SRV2_Slot1_P1"
zonecreate "SRV3_SAN1", "SAN1_SPA_P0;SAN1_SPB_P0;SRV3_Slot1_P1"
zonecreate "SRV4_SAN1", "SAN1_SPA_P0;SAN1_SPB_P0;SRV4_Slot1_P1"
zonecreate "SRV5_SAN1", "SAN1_SPA_P0;SAN1_SPB_P0;SRV5_Slot1_P1"
cfgenable Production
</pre>

You could then copy and paste these commands into the a console session to configure it with these aliases, zones and config.
