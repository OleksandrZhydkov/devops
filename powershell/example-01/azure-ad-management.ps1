using namespace System.Collections.Generic

function Connect-To-Azure-Ad([String]$tenantId, [String]$user, [SecureString] $securePassword) {
    try {	
        $credential = New-Object System.Management.Automation.PSCredential ($user, $securePassword)
        Connect-AzureAD -TenantId $tenantId -Credential $credential        
        Write-PSFMessage -Level Output -Message "Connectin to the Azure AD was successfully"
        return $true
    }
    catch {        
        Write-PSFMessage -Level Error -Message "<c='red'>Connectin to the Azure AD was unsuccessfully</c>"
        Write-PSFMessage -Level Error -Message $_.Exception
        return $false
    }
}

function Add-Azure-Ad-Users([int] $countOfUsersToAdd, [string] $domainName, [string] $userNameSuffix) {
    [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.User]]$users = @()
    for ($index = 0; $index -lt $countOfUsersToAdd; $index++) {     
        $userName = "$userNameSuffix $index"
        $userShortName = "$userNameSuffix$index".Replace(" ", "")
        $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile { Password = "$(New-Guid)" }
       
        $params = @{
            AccountEnabled    = $true
            DisplayName       = $userName
            PasswordProfile   = $passwordProfile
            UserPrincipalName = "$userShortName.$(New-Guid)@$domainName"
            MailNickName      = $userShortName
        }

        try {
            $user = New-AzureADUser @params
            $users.Add($user)
            Write-PSFMessage -Level Output -Message "User '$($user.DisplayName)' was createt with Id '$($user.ObjectId)'"
        }
        catch {
            Write-PSFMessage -Level Warning -Message "<c='red'>User '$userName' was not created</c>"
            Write-PSFMessage -Level Warning -Message $_.Exception
        }        
    }

    return $users;
}

function Add-Azure-Ad-Security-Group([string] $groupName) {
    try {
        $group = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        Write-PSFMessage -Level Output -Message "Security group '$($group.DisplayName)' was createt with Id '$($group.ObjectId)'"
        return $group
    }
    catch {
        Write-PSFMessage -Level Warning -Message "<c='red'>Security group '$groupName' was not created</c>"
        Write-PSFMessage -Level Warning -Message $_.Exception
    }
}

function Add-Azure-Ad-User-To-Security-Group([string] $groupId, [string] $userId) {
    try {
        Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $userId
        Write-PSFMessage -Level Output -Message "User with Id '$userId' was added to the group with Id '$groupId'"
        return $true;
    }
    catch {        
        Write-PSFMessage -Level Warning -Message "<c='red'>User with Id '$userId' was not added to the group with Id '$groupId'</c>"
        Write-PSFMessage -Level Warning -Message $_.Exception
        return $false;
    }
}
