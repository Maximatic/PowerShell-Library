## Out-FileHash.ps1
Function to simplify the saving the file hashes of a user-specified file, to a text file.

## Search-UsbId.ps1
Function that searches a list of known USB Vender ID's (VID) and Product ID's (PID), given a user-specified USB device path, such as "USB\VID_138A&PID_003F\00B0CA82BB24".

Here is an example output of a matching VID and PID (Search-UsbId -DevicePath "USB\VID_138A&PID_003F\00B0CA82BB24"):
<pre>
VID  VendorName             PID  ProductName              
---  ----------             ---  -----------              
138a Validity Sensors, Inc. 003f VFS495 Fingerprint Reader
</pre>

And here is an example output of a matching VID, but no PID (Search-UsbId -DevicePath "USB\VID_138A&PID_0F3F\00B0CA82BB24"):
<pre>
VID  VendorName             PID  ProductName                                            
---  ----------             ---  -----------                                            
138a Validity Sensors, Inc. 0001 VFS101 Fingerprint Reader                              
138a Validity Sensors, Inc. 0005 VFS301 Fingerprint Reader                              
138a Validity Sensors, Inc. 0007 VFS451 Fingerprint Reader                              
...
</pre>

## Split-vCards.ps1
This script reads vCard files with multiple contacts and separates them into separate VCF files. Multiple contacts exported from devices such as Android smartphones are typically saved to a single VCF file. Programs like Microsoft Outlook can only import one vCard at at time so the individual vCards must be split up into separate files before importing.
