# Next modules should be installed
# Install-Module AzureAD
# Install-Module PSFramework

$domainName = "" # for UserPrincipalName
$tenantId = "" # Tenant ID of Azure Active Directory
$loginUser = ""
$password = ""

$countOfUsersToAdd = 20
$userNameSuffix = "Test User"

$securityGroupName = "Varonis Assignment Group"

try {
    Set-Log
    #Connect-AzureAD -TenantId $tenantId # - uncomment for 1st login
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $isConnected = Connect-To-Azure-Ad -tenantId $tenantId -user $loginUser -securePassword $securePassword
    if (!$isConnected) {
        return
    }

    $users = Add-Azure-Ad-Users -countOfUsersToAdd $countOfUsersToAdd -domainName $domainName -userNameSuffix $userNameSuffix
    if ($users.Length -eq 0) {
        Write-PSFMessage -Level Output -Message "No any users was created"
        return
    }    

    $securityGroup = Add-Azure-Ad-Security-Group -groupName $securityGroupName
    if (!$securityGroup) {
        return
    }

    $report = @()
    foreach ($user in $users) {
        $isAdded = Add-Azure-Ad-User-To-Security-Group -groupId $securityGroup.ObjectId -userId $user.ObjectId
        $report += Add-Report-Object -userName $user.DisplayName -isAdded $isAdded       
    }

    Write-PSFMessage -Level Output -Message ("`nScript Results:" + ($report | Format-Table | Out-String))
}
catch {
    Write-PSFMessage -Level Critical -Message "<c='red'>Unhandled error occurred</c>"
    Write-PSFMessage -Level Critical -Message $_.Exception
}

function Set-Log {   
    $logFile = Join-Path -path "Logs" -ChildPath "log-$(Get-Date -f 'yyyyMMddHHmmss').txt";
    Set-PSFLoggingProvider -Name logfile -FilePath $logFile -Enabled $true;
}

function Add-Report-Object([string] $userName, [bool] $isAdded) {
    return [pscustomobject]@{UserName = $userName; Timestamp = Get-Date -f 'yyyyMMddHHmmss'; Result = if ($isAdded) { "<c='green'>success</c>" } else { "<c='red'>failure</c>" } }
}