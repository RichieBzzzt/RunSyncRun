Function Restore-DatabaseRoles {
    param(
        $ssasServer,
        $ssasDatabase,
        $roles
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        foreach ($role in $roles) {
            try {
                $restoreRole = new-Object([Microsoft.AnalysisServices.Role])($role)
                $exists.Roles.Add($restoreRole)
                $restoreRole.Update() | Out-Null
                foreach ($member in $role.members) {
                    "$(Get-Date):      Adding " + $($member.Name) + " into the role " + $restoreRole
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
