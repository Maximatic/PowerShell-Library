## Get-Fibonacci.ps1
Generates Fibonacci numbers.

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
138a Validity Sensors, Inc. 0008 VFS300 Fingerprint Reader                              
138a Validity Sensors, Inc. 0010 VFS Fingerprint sensor                                 
138a Validity Sensors, Inc. 0011 VFS5011 Fingerprint Reader                             
138a Validity Sensors, Inc. 0015 VFS 5011 fingerprint sensor                            
138a Validity Sensors, Inc. 0017 VFS 5011 fingerprint sensor                            
138a Validity Sensors, Inc. 0018 Fingerprint scanner                                    
138a Validity Sensors, Inc. 003c VFS471 Fingerprint Reader                              
138a Validity Sensors, Inc. 003d VFS491                                                 
138a Validity Sensors, Inc. 003f VFS495 Fingerprint Reader                              
138a Validity Sensors, Inc. 0050 Swipe Fingerprint Sensor                               
138a Validity Sensors, Inc. 0090 VFS7500 Touch Fingerprint Sensor                       
138a Validity Sensors, Inc. 0091 VFS7552 Touch Fingerprint Sensor                       
138a Validity Sensors, Inc. 6e00 WPNT121 802.11g 240Mbps Wireless Adapter [Airgo AGN300]
</pre>
