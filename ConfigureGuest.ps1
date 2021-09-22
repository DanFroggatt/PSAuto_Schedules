
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - ConfigureGuest schedule started" > $logpath
"" >> $logpath



#-----------------------Prerequisite Checks Begins

$run = $false

#-----------fetch GuestConfig configuration files
If (Test-Path "C:\GuestAutomation\ConfigFiles\GuestConfig.xml")
{
    "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - GuestConfig configuration file found" > $logpath
    
    [xml]$guestConfig = Get-Content "C:\GuestAutomation\ConfigFiles\GuestConfig.xml"
    $service = $guestConfig.GuestConfig.Guest.service
    
    If ($true)   ######################################################################################## - Re-write conditions to validate GuestConfig
    {
        "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - GuestConfig configuration file validated" > $logpath
        
        #check service config file exist
        If (Test-Path "C:\GuestAutomation\ConfigFiles\$service.xml")
        {
            "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - $service service configuration file found" > $logpath
            
            If ($true)   ############################################################################### - Re-write conditions to validate service config file
            {
                "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - $service service configuration file validated" > $logpath
                $run = $true
            }
            
            Else
            {
                "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - Could not validate $service service configuration file" > $logpath
                Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\OpenLog.txt" -Raw)
            }
        }
    }
    
    Else
    {
        "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - Could not validate GuestConfig configuration file" > $logpath
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\OpenLog.txt" -Raw)
    }
}

#-----------------------Prerequisite Checks Ends



#-----------------------System Configuration Begins



If ($run)
{
    #-----------set execution policy

    $policy = "unrestricted"
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetExecutionPolicy.txt" -Raw)

    #-----------stop backgroundtasks

    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\StopBackgroundJobs.txt" -Raw)

    #-----------disable schedueled tasks

    $tasks = $guestConfig.SelectNodes("//DisableTask")
    
    ForEach ($task in $tasks)
    {
        $task = $task.name
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\DisableScheduledTask.txt" -Raw)
    }

    #-----------config auto login

    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\EnableAutoLogon.txt" -Raw)

    #-----------set run once ConfigureNetwork

    $script = "C:\GuestAutomation\Schedules\ConfigureNetwork.ps1"
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetRunOnce.txt" -Raw)

    
    #-----------name computer
    
    $computerName = $guestConfig.GuestConfig.Guest.name
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\NameComputer.txt" -Raw)
    
    #-----------restart

    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\RestartComputer.txt" -Raw)

}

else
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\OpenLog.txt" -Raw)
}



#-----------------------System Configuration Ends