Function Backup-DatabasePermissions {
    param(
        $ssasServer,
        $ssasDatabase
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        try {
            $permissionArray = @()
            foreach ($permission in $ssasDatabase.DatabasePermissions) {
                Write-Host $permission
                Write-Host $permission.Read
                Write-Host $permission.Administer
                Write-Host $permission.Process
                Write-Host $permission.Role.Name
                $permissionArray += $permission
            }
            if ($permissionArray.Count -gt 0) {
                $msg = "Permissions saved."
                Write-Verbose $msg -Verbose
                return $permissionArray
            }
            else {
                Write-Verbose "No permissions to save." -Verbose
            }
            return $permissionArray
        }
        catch {
            throw $_.Exception
        }
    }
    else {
        return
    }
}