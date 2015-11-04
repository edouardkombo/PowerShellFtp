POWERSHELL FTP
==============
Upload csv files on the hard drive to a ftp server, using PowerShell.

HOW DOES IT WORK?
=================
The script checks every second, for csv files in a directory on your hard drive or network share drive.
When a file is found, it is automatically sent to the remote ftp directory you specify.

Security options
================
If upload is complete, the file is saved in a "save" directory on your hard drive, then, deleted from the "source" directory.
If upload is not complete, files still in the "source" directory and the script tries again indefinitely.
For big size images, we wait 2 seconds after an image has been created in the "medias" folder, to send it through ftp.

Logging
=======
Script will create a log file to document data transfer. If the file is not found it is also documented.

Architecture
============
Put the script in a directory that you call, by example "c:\fff".
Create in this directory, two directories, "medias" and "save".

Automation
==========
To execute easier the file, put the automate batch on your desktop, run it.


NB: If you encounter any issues, feel free to contact me at edouard.kombo@gmail.com.
