Function Restore-DatabasePermissions {
    param(
        $ssasServer,
        $ssasDatabase,
        $permissions
    )
    $exists = Test-DatabaseExists -ssasServer $ssasServer -ssasDatabase $ssasDatabase
    if ($null -ne $exists) {
        foreach ($permission in $permissions) {
            Write-Host $permission
            Write-Host $permission.Read
            Write-Host $permission.Administer
            Write-Host $permission.Process
            Write-Host $permission.Role.Name
            $restoredPermission = $null
            if ($permission.Read -eq "Allowed")
            {
                Write-Host "Adding read permissions to $($permission.Role.Name) on $ssasDatabase $ssasServer" -ForegroundColor Green
                $restoredPermission = $exists.DatabasePermissions.Add($permission.Role.Name)
                $restoredPermission
                $restoredPermission.Update()
                Write-Host "What is going on? "$restoredPermission.Role.Name
                $restoredPermission.Read = [Microsoft.AnalysisServices.ReadAccess]::Allowed
                $restoredPermission.Update()
            }
            $exists.Update()
        }
    }
}