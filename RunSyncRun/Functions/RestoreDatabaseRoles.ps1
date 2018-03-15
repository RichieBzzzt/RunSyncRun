Function Restore-DatabaseRoles {
    param(
        $ssasServer,
        $ssasDatabase,
        [Microsoft.AnalysisServices.Role[]]$roles
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        foreach ($role in $roles) {
            try {
                Write-Verbose "Restoring role $role to $($exists.Name)"
                $restoreRole = new-Object([Microsoft.AnalysisServices.Role])($role)
                $exists.Roles.Add($restoreRole) | Out-Null
                $restoreRole.Update()
                foreach ($member in $role.Members) {
                    Write-Verbose "$(Get-Date): Adding $($member.Name) into the role $restoreRole" -Verbose
                    $restoreRole.Members.Add($member.Name) | Out-Null
                    $restoreRole.Update() | Out-Null
                }
            }
            catch {
                throw $_.Exception
            }
        }
    }
}
