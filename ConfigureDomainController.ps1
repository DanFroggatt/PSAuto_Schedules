
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - ConfigreDomainController schedule started" >> $logpath
"" >> $logpath

[xml]$DCConfig = Get-Content "C:\GuestAutomation\ConfigFiles\DomainController.xml"

#-----------------------System Configuration Begins



#-----------add AD service (DNS implicit)

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InstallAD.txt" -Raw)

#-----------add dhcp service

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InstallDHCP.txt" -Raw)

#-----------install domain controller newforest/child domain/additionalDC

$domain = $DCConfig.DCConfig.DomainController.domain
switch ($DCConfig.DCConfig.DomainController.'type')
    {
        'Forest' { Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InstallNewForest.txt" -Raw) }
        'Domain' { Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InstallChildDomain.txt" -Raw) }
        'DomainController' { Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InstallSecondaryDC.txt" -Raw) }
        default { }
    }

#-----------set run once ConfigureDomainServices

$script = "C:\GuestAutomation\Schedules\ConfigureDomainServices.ps1"
Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetRunOnce.txt" -Raw)

#-----------restart

Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\RestartComputer.txt" -Raw)



#-----------------------System Configuration Begins