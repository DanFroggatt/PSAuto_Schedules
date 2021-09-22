
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - ConfigreNetwork schedule started" >> $logpath
"" >> $logpath

[xml]$guestConfig = Get-Content "C:\GuestAutomation\ConfigFiles\GuestConfig.xml"



#-----------------------System Configuration Begins



#-----------Configure adapter settings

$adapters = $guestConfig.SelectNodes("//Adapter")

foreach ($adapter in $adapters)
{
    $interface = $adapter.name
    
    If ($adapter.dhcp -like "false")
    {
        $ipaddress = $adapter.IPAddress.address
        $prefix = $adapter.IPAddress.prefix
        $gateway = $adapter.IPAddress.gateway
        $dns = ($adapter.IPAddress.'#text').Trim('"')
        
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetAdapterIP-Static.txt" -Raw)
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetDNS-Static.txt" -Raw)
        
    }
    
    ElseIf ($adapter.dhcp -like "true")
    {
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetAdapterIP-Auto.txt" -Raw)
        Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetDNS-Auto.txt" -Raw)
    }
    
    Else
    {
        "$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - $adapter.name DHCP setting not recognised" >> $logpath
    }
    
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\DisableIPv6.txt" -Raw)
    
}

#-----------configure default route

$defaultGateway = $guestConfig.GuestConfig.Adapters.defaultGateway
Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetDefaultRoute.txt" -Raw)

#-----------configure firewall rules

$firewalls = $guestConfig.SelectNodes("//Firewalls/Firewall")

ForEach ($firewall in $firewalls)
{
    Invoke-Expression (Get-Content $firewall.path -Raw)
}

#-----------set domain confiration

$service = $guestConfig.GuestConfig.Guest.service

If ($service -ne "DomainController")
{
    
    #-----------set run once to ConfigureServices
    
    $script = "C:\GuestAutomation\Schedules\ConfigureServices.ps1"
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\SetRunOnce.txt" -Raw)
    
    #-----------join domain
    
    $domain = $guestConfig.GuestConfig.Guest.domain
    $ou = $guestConfig.GuestConfig.Guest.ou
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\JoinDomain.txt" -Raw)
    
    #-----------restart
    
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\RestartComputer.txt" -Raw)
}

Else
{
    & "C:\GuestAutomation\Schedules\ConfigureServices.ps1" –ExecutionPolicy Bypass
}

#-----------------------System Configuration Begins