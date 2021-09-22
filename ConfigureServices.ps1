
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - ConfigreServices schedule started" >> $logpath
"" >> $logpath

[xml]$guestConfig = Get-Content "C:\GuestAutomation\ConfigFiles\GuestConfig.xml"



#-----------------------System Configuration Begins



#-----------create directories

$directories = $guestConfig.SelectNodes("//Directories/Directory")

ForEach ($directory in $directories)
{
    $dir = $directory.path
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CreateDirectory.txt" -Raw)
}

#-----------map trec shared drive using automation service creds

$drive = "Q:"
$path = "192.168.150.1\usb"
$name = "admin"
$password = "P@55w0rd" | ConvertTo-SecureString -AsPlainText -Force
Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\MapDrive.txt" -Raw)

#-----------remove trec mapped drive

If ($guestConfig.GuestConfig.NetworkDrives.trecShare -like "false")
{
    $drive = "Z:"
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\RemoveMappedDrive.txt" -Raw)
}

#-----------map network drives

$networkDrives = $guestConfig.SelectNodes("//NetworkDrives/NetworkDrive")
ForEach ($networkDrive in $networkDrives)
{
    $drive = $networkDrive.drive
    $path = $networkDrive.path
    $name = $networkDrive.user
    $password = $networkDrive.Trim('"')
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\MapDrive.txt" -Raw)
}

#-----------fetch folders from trec share

$folders = $guestConfig.SelectNodes("//Software/Folder")

ForEach ($folder in $folders)
{
    $src = $folder.source
    $dst = $folder.destination
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CopyDirectory.txt" -Raw)
}

#-----------fetch files from trec share

$files = $guestConfig.SelectNodes("//Software/File")

ForEach ($file in $files)
{
    $src = $file.source
    $dst = $file.destination
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CopyFile.txt" -Raw)
}

#-----------extract files from iso

$isos = $guestConfig.SelectNodes("//Software/ExtractIso")

ForEach ($iso in $isos)
{
    
    $imagePath = $iso.iso
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\MountIso.txt" -Raw)
    
    $folders = $iso.Folder

    ForEach ($folder in $folders)
    {
        $src = $folder.source
        $dst = $folder.destination
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CopyDirectory.txt" -Raw)
    }

    $files = $iso.File

    ForEach ($file in $files)
    {
        $src = $file.source
        $dst = $file.destination
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CopyFile.txt" -Raw)
    }
    
    $imagePath = $iso.iso
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\DismountIso.txt" -Raw)
}

#-----------configure DTC

If ($guestConfig.GuestConfig.DTC.enabled -like "true")
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\CofigureDTC.txt" -Raw)
}

#-----------install software

$apps = $guestConfig.SelectNodes("//Software/Install")

ForEach ($app in $apps)
{
    Start-Job -InputObject $app.path -ScriptBlock { $path = $Input
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\RunInstall.txt" -Raw)}
}

#-----------enable schedueled tasks

$tasks = $guestConfig.SelectNodes("//EnableTask")

ForEach ($task in $tasks)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\EnableScheduledTask.txt" -Raw)
}
#-----------select and run next schedule

switch ($guestConfig.GuestConfig.Guest.service)
    {
        DomainController { & "C:\GuestAutomation\Schedules\ConfigureDomainController.ps1" –ExecutionPolicy Bypass }
        SQL { & "C:\GuestAutomation\Schedules\ConfigureSQL.ps1" –ExecutionPolicy Bypass }
        Sitaware { & "C:\GuestAutomation\Schedules\ConfigureSitaware.ps1" –ExecutionPolicy Bypass }
        default {"########### Error! - Service parameter not recognised!" >> $logpath
                "" >> $logpath
                & "C:\GuestAutomation\Schedules\CleanUp.ps1" –ExecutionPolicy Bypass }
    }



#-----------------------System Configuration Ends