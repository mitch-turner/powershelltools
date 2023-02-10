$credential = Get-Credential
 
$Session = New-PSSession -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -ConfigurationName Microsoft.Exchange -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $Session
 
$userRequiringAccess = "foo@bar.com"
$accessRight = "Reviewer"
 
$mailboxes = Get-mailbox
$userRequiringAccess = Get-mailbox $userRequiringAccess
foreach ($mailbox in $mailboxes) {
    $accessRights = $null
    $accessRights = Get-MailboxFolderPermission "$($mailbox.primarysmtpaddress):\calendar" -User $userRequiringAccess.PrimarySmtpAddress -erroraction SilentlyContinue
         
    if ($accessRights.accessRights -notmatch $accessRight -and $mailbox.primarysmtpaddress -notcontains $userRequiringAccess.primarysmtpaddress -and $mailbox.primarysmtpaddress -notmatch "DiscoverySearchMailbox") {
        Write-Host "Adding or updating permissions for $($mailbox.primarysmtpaddress) Calendar" -ForegroundColor Yellow
        try {
            Add-MailboxFolderPermission "$($mailbox.primarysmtpaddress):\calendar" -User $userRequiringAccess.PrimarySmtpAddress -AccessRights $accessRight -ErrorAction SilentlyContinue    
        }
        catch {
            Set-MailboxFolderPermission "$($mailbox.primarysmtpaddress):\calendar" -User $userRequiringAccess.PrimarySmtpAddress -AccessRights $accessRight -ErrorAction SilentlyContinue    
        }        
        $accessRights = Get-MailboxFolderPermission "$($mailbox.primarysmtpaddress):\calendar" -User $userRequiringAccess.PrimarySmtpAddress
        if ($accessRights.accessRights -match $accessRight) {
            Write-Host "Successfully added $accessRight permissions on $($mailbox.displayname)'s calendar for $($userrequiringaccess.displayname)" -ForegroundColor Green
        }
        else {
            Write-Host "Could not add $accessRight permissions on $($mailbox.displayname)'s calendar for $($userrequiringaccess.displayname)" -ForegroundColor Red
        }
    }else{
        Write-Host "Permission level already exists for $($userrequiringaccess.displayname) on $($mailbox.displayname)'s calendar" -foregroundColor Green
    }
}
Remove-PSSession $Session