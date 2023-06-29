Write-Host "This will copy AD groups from a source user to destination user, run this on the DC"

#get users
$source = Read-Host -Prompt "Who do you want to copy from?"
$destination = Read-Host -Prompt "Who do you want to copy to?"

#get list of groups
$CopyFromUser = Get-ADUser $source -prop MemberOf
$CopyToUser = Get-ADUser $destination -prop MemberOf

#do the copy
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser