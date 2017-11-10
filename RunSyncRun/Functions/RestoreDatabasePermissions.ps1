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
            if ($permission.Read -eq "Allowed") {
                Write-Host "Adding read permissions to $($permission.Role.Name) on $ssasDatabase $ssasServer" -ForegroundColor Green
                $restoredPermission = $exists.DatabasePermissions.Add($permission.Role.Name)
                Write-Host  $restoredPermission.Read
                Write-Host  $restoredPermission.Role.Name
                $restoredPermission.Read = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            }
            if ($permission.Process -eq "Allowed") {
                Write-Host "Adding Process permissions to $($permission.Role.Name) on $ssasDatabase $ssasServer" -ForegroundColor Green
                $restoredPermission = $exists.DatabasePermissions.Add($permission.Role.Name)
                Write-Host  $restoredPermission.Process
                Write-Host  $restoredPermission.Role.Name
                $restoredPermission.Process = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            }
            if ($permission.Administer -eq "Allowed") {
                Write-Host "Adding Administer permissions to $($permission.Role.Name) on $ssasDatabase $ssasServer" -ForegroundColor Green
                $restoredPermission = $exists.DatabasePermissions.Add($permission.Role.Name)
                Write-Host  $restoredPermission.Administer
                Write-Host  $restoredPermission.Role.Name
                $restoredPermission.Administer = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            }
            $restoredPermission.Update()
            Write-Host  $restoredPermission.Read
            Write-Host  $restoredPermission.Role.Name
            $exists.Update()
            Write-Host  $restoredPermission.Read
            Write-Host  $restoredPermission.Role.Name
            $ssasServer.Update()
            Write-Host  $restoredPermission.Read
            Write-Host  $restoredPermission.Role.Name
        }
    }
}