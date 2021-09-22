
$logpath = ("C:\Users\" + $env:USERNAME + "\Desktop\GuestSetUpLog.txt")
"$(Get-Date -Format "d-M-yyyy HH:mm:ss.ffff") - ConfigreDomainServices schedule started" >> $logpath
"" >> $logpath

[xml]$DCConfig = Get-Content "C:\GuestAutomation\ConfigFiles\DomainController.xml"



#-----------------------System Configuration Begins



#-----------authorize DHCP services

$domain = $DCConfig.DCConfig.DomainController.domain
Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AuthoriseDHCP.txt" -Raw)

#-----------configure DHCP services

$scopes = $DCConfig.SelectNodes("//DHCP/Scope")

ForEach ($scope in $scopes)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\ConfigureDHCPScope.txt" -Raw)
}

#-----------configure DNS primary zone

$zones = $DCConfig.SelectNodes("//DNS/Zone")

ForEach ($zone in $zones)
{
    switch ($zone.priority)
    {
        'primary' { Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\ConfigureDNSPrimaryZone.txt" -Raw) }
        'secondary' { Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\ConfigureDNSSecondaryZone.txt" -Raw) }
        default { "Priority parameter not recognised! - Unable to configure zone $network" >> $logpath }
    }
}

#-----------configure DNS entries A

$ARecords = $DCConfig.SelectNodes("//DNS/A")

ForEach ($ARecord in $ARecords)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-A.txt" -Raw)
}

#-----------configure DNS entries AAAA

$AAAARecords = $DCConfig.SelectNodes("//DNS/AAAA")

ForEach ($AAAARecord in $AAAARecords)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-AAAA.txt" -Raw)
}

#-----------configure DNS entries CName

$CNames = $DCConfig.SelectNodes("//DNS/CName")

ForEach ($CName in $CNames)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-CName.txt" -Raw)
}

#-----------configure DNS entries PTR

$ptrs = $DCConfig.SelectNodes("//DNS/PTR")

ForEach ($ptr in $ptrs)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-PTR.txt" -Raw)
}

#-----------configure DNS entries NS

$NameServers = $DCConfig.SelectNodes("//DNS/NS")

ForEach ($NameServer in $NameServers)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-NS.txt" -Raw)
}

#-----------configure DNS entries MX

$MXs = $DCConfig.SelectNodes("//DNS/MX")

ForEach ($MX in $MXs)
{
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddDNSEntry-MX.txt" -Raw)
}

#-----------configure OUs

$OUs = $DCConfig.SelectNodes("//OUs/OU")

ForEach ($OU in $OUs)
{
    $ou = $OU.name
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddOU.txt" -Raw)
}

#-----------configure security groups

$Groups = $DCConfig.SelectNodes("//Groups/Group")

ForEach ($Group in $Groups)
{
    $group = $Group.name
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\AddADGroup.txt" -Raw)
}

#-----------configure domain users

$Users = $DCConfig.SelectNodes("//Users/User")

ForEach ($User in $Users)
{
    $groups = ($User.'#text').Trim('"')
    Invoke-Expression (Get-Content "C:\GuestAutomation\Modules\InitialiseUser.txt" -Raw)
}

#-----------configure GPOs



#-----------run CleanUp script

& "C:\GuestAutomation\Schedules\CleanUp.ps1" -ExecutionPolicy Bypass



#-----------------------System Configuration Begins