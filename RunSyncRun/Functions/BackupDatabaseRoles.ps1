Function Backup-DatabaseRoles {
    param (
        $ssasServer,
        $ssasDatabase
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        try {
            [Microsoft.AnalysisServices.Role[]] $roleArray = @()
            foreach ($role in $ssasDatabase.Roles) {
                Write-Verbose $role
                $roleArray += [Microsoft.AnalysisServices.Role[]] $role
            }
            return $roleArray
        }
        catch {
            throw $_.Exception
        }
    }
    else {
        return
    }
}