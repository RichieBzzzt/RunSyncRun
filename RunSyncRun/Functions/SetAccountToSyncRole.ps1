Function Set-AccountToSyncRole {
    param (
        $SsasDatabase,
        $account,
        $syncRole
    )
    $foundMember = $null
    foreach ($member in $role.Members) {
        if ($member.Name -eq $Account) {
            $foundMember = $member
        }
    }
    $r = $SsasDatabase.Roles.FindByName($syncrole)
    If ($foundMember -eq $null) {
        "$(Get-Date): Adding access to " + $Account
        $newMem = New-Object Microsoft.AnalysisServices.RoleMember($Account)
        $r.Members.Add($newMem)
        $r.Update()
    }
    else {
        "$(Get-Date): User " + $syncAccount + " already added to role $r"
    }
}