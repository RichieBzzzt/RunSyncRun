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
                $roleArray += [Microsoft.AnalysisServices.Role[]] $role
            }
            $roleArray.Members.Count | Out-Null
            if ($roleArray.Count -gt 0) {
                $msg = "Roles saved - {0} " -f ($roleArray -join " `n")
                Write-Verbose $msg -Verbose
            }
            else {
                Write-Verbose "No roles to save." -Verbose
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