#
# Edouard Kombo <edouard.kombo@gmail.com>
# 2014/02/19
# Powershell script
# Upload pictures through ftp
#
# Errol Straker <errol.strakerjr@gmail.com>
# 2015/11/03
# Powershell script
# CHANGELOG
# 
# Changes logged in code
# 20151027_Added in file rename function


#Get the date and time of file transfer
$eventdate = Get-Date -format U

#Directory where to find files to upload
$Dir= 'c:\ftp_test\'

#Directory where to save uploaded files
$saveDir = 'c:\ftp_test\backup\'

#ftp server params
$ftp = 'ftp://speedtest.tele2.net/upload/'
$user = ''
$pass = ''

#Connect to ftp webclient
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)

#Create log file for process or append if present
function LogWrite
{
    Param ([string]$logstring)

    $Logchk = Test-Path C:\ftp_test\logs\$(gc env:computername).log
        if ($Logchk -eq $false)
            {Add-content C:\ftp_test\logs\$(gc env:computername).log -Value $logstring}
        else {$Logfile = "c:\ftp_test\logs\$(gc env:computername).log"
              Add-Content $Logfile -Value $logstring}
}

#Initialize var for infinite loop
$i=0

#Infinite loop
while($i -eq 0){ 

    #Pause 1 second before continue
    Start-Sleep -sec 1

    #Search for files in directory after verifing existance
    $Listchk = Test-Path C:\ftp_test\*.csv
        if ($Listchk -eq $true)
            {

    foreach($item in (dir $Dir "*.csv"))
    {
        #Set default network status to 1
        $onNetwork = "1"

        #Get file creation dateTime...
        $fileDateTime = (Get-ChildItem $item.fullName).CreationTime

        #Convert dateTime to timeStamp
        $fileTimeStamp = (Get-Date $fileDateTime).ToFileTime()

        #Get actual timeStamp
        $timeStamp = (Get-Date).ToFileTime() 

        #Get file lifeTime
        $fileLifeTime = $timeStamp - $fileTimeStamp

        #We only treat files that are fully written on the disk
        #So, we put a 2 second delay to ensure even big files have been fully wirtten in the disk
        if($fileLifeTime -gt "2") {    

            #If upload fails, we set network status at 0
            try{
                
                $uri = New-Object System.Uri($ftp+$item.Name)

                $webclient.UploadFile($uri, $item.FullName)
                
            } catch [Exception] {

                $onNetwork = "0"
                write-host $_.Exception.Message;
            }

            
            #If upload succeeded, we do further actions
            #Copy has been expanded to append a datestamp to the filename
            #Then copy that renamed file to the file backup directory
            #Then the script writes the changes to the log file
            if($onNetwork -eq "1"){
                "Copying $item..."
                $filename = get-item $item.fullname
                #Properly pull in item for name change
                $fileObj = get-item $item.fullname
                #Get the date
                $DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"
                $extOnly = $fileObj.extension
                if ($extOnly.length -eq 0){
                    $nameOnly = $fileObj.fullname
                    Rename-Item "$fileObj" "$nameOnly-$DateStamp"
                    }
                else {
                    $nameOnly = $fileObj.Name.Replace( $fileObj.Extension,'')
                    Rename-Item "$filename" "$nameOnly-$DateStamp$extOnly"
                    }
                
                #After renaming file, script loses file path
                #Band-Aid: Read in contents of $DIR again
                #Then perform closing actions
                foreach ($nfile in (dir $Dir "*.csv"))
                {
                    "Successfully uploaded and now performing housecleaning for file $item..."
                    Move-Item -Path $nfile.fullName -Destination $saveDir$nfile

                    LogWrite "On $eventdate, $item was successfully uploaded on $fileDateTime to $ftp"
                    LogWrite "$item has been renamed to $nfile with a backup saved in $saveDir"
                    Exit
                }

            }
        }  
    }
 }
 # Added in log write if file not found
 else
  {LogWrite "File Not Found for $eventdate"}
  Exit
}