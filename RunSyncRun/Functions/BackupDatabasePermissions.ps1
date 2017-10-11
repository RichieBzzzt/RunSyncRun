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
                $permissionArray += $permission
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