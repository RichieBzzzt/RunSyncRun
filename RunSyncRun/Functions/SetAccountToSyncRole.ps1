Function Set-AccountToSyncRole {
    param (
        $SsasDatabase,
        $account,
        $syncRole
    )
    $r = $SsasDatabase.Roles.FindByName($syncrole)
    $foundMember = $null
    foreach ($member in $r.Members) {
        if ($member.Name -eq $Account) {
            $foundMember = $member
        }
    }
    If ($foundMember -eq $null) {
        Write-Verbose "$(Get-Date): Adding access to $Account"  -Verbose
        $newMem = New-Object Microsoft.AnalysisServices.RoleMember($Account)
        $r.Members.Add($newMem)
        $r.Update()
    }
    else {
        Write-Verbose "$(Get-Date): User $syncAccount already added to role $r" -Verbose
    }
}