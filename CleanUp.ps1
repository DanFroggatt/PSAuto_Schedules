
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - CleanUp schedule started" >> $logpath
"" >> $logpath

[xml]$guestConfig = Get-Content "C:\GuestAutomation\ConfigFiles\GuestConfig.xml"



#-----------------------System Configuration Begins



#-----------remove auto logon

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\DisableAutoLogon.txt" -Raw)

#-----------reset execution policy

$policy = "restricted"
Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetExecutionPolicy.txt" -Raw)

#-----------open logfile

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\OpenLog.txt" -Raw)

#-----------prompt to purge install data

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\ConfirmCleanUp.txt" -Raw)



#-----------------------System Configuration Ends