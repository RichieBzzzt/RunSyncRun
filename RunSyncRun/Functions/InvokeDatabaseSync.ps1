
Function Invoke-DatabaseSync {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, mandatory = $true)]
        [string] $sourceInstance,
        [Parameter(Position = 1, mandatory = $true)]
        [string] $targetInstance,
        [Parameter(Position = 2, mandatory = $true)]
        [string] $syncAccount,
        [Parameter(Position = 3, mandatory = $true)]
        [string] $DataSourceName,
        [Parameter(Position = 4, mandatory = $true)]
        [string] $rolename,
        [Parameter(Position = 5, mandatory = $true)]
        [String] $synchroniseSecuritySetting,
        [Parameter(Position = 6, mandatory = $true)]
        [String] $applyCompressionSetting,
        [Parameter(Position = 7)]
        [string[]] $database,
        [Parameter(Position = 8)]
        [switch] $Drop,
        [Parameter(Position = 9)]
        [switch] $restore#,        
        # [Parameter(Position = 10)]
        # [switch] $chkdsk
    
        
    )
    Write-Verbose "$(Get-Date): Starting up..." -Verbose
    [void][System.reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
    Write-Verbose "Connecting to $sourcesvr as source. This is where we will be syncing FROM."
    $sourcesvr = Connect-SsasServer -ssasServer $sourceInstance
    Write-Verbose "Connecting to $sourcesvr as target. This is where we will be syncing TO."
    $targetsvr = Connect-SsasServer -ssasServer $targetInstance
    $db = Get-ssasDatabase -ssasServer $sourcesvr -SsasDatabase $database
    foreach ($sourceDB in $db) {
        $targetSsasDatabase = $null
        $targetConnectionString = $null
        Write-Verbose "Getting SSAS Database as 'target'" -Verbose
        $targetSsasDatabase = Get-ssasDatabase -ssasServer $targetsvr -ssasDatabase $database
        if ($restore) {
            Write-Verbose "Restore switch was used. Backing up connection string." -Verbose
            $targetConnectionString = Backup-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName
        }
        Write-Verbose "Checking if role $rolename exists on $sourceDB. If not will create." -Verbose
        Set-SyncRole -SsasDatabase $sourceDB -syncRole $rolename
        Write-Verbose "Checking if role $rolename has correct permisisons on $sourceDB. If not will add." -Verbose
        Set-SyncRolePermissions -SsasDatabase $sourceDB -syncRole $rolename
        Write-Verbose "Cehcking if $syncAccount is member of role $rolename on $sourceDB. If not will add." -Verbose
        Set-AccountToSyncRole -SsasDatabase $sourceDB -account $syncAccount -syncRole $rolename
        #TODO - Test-FreeDiskSpace is not working
        # if ($chkdsk) {
        #     Test-FreeDiskSpace -sourcesvr $sourcesvr -sourceDB $sourceDB -targetsvr $targetsvr -targetdb $targetDB
        # }
        if ($restore) {
            Write-Verbose "Restore switch was used. Backing up database roles." -Verbose
            $targetRoles = Backup-DatabaseRoles -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
            $targetPermissions = Backup-DatabasePermissions -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
        }
        if ($drop) {
            Write-Verbose "Drop switch was used. $targetSsasDatabase on $targetsvr will be dropped." -Verbose
            Remove-SsasDatabase -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
        }
        Start-DatabaseSync -sourcedb $sourceDB -sourcesvr $sourcesvr -targetsvr $targetsvr -synchroniseSecuritySetting $synchroniseSecuritySetting -applyCompressionSetting $applyCompressionSetting
        Write-Verbose "If restore switch was used then will run extra tasks" -Verbose
        $targetsvr.Refresh()
        if ($restore) {
            if ($targetConnectionString -ne $null) {
                Restore-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName -ConnectionString $targetConnectionString
            }
            Write-Verbose "Restore switch was used." -Verbose
            if ($targetRoles.Count -gt 0) {
                Write-Verbose "Restoring database roles" -Verbose
                Restore-DatabaseRoles -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -roles $targetRoles
            }
            if ($targetPermissions.Count -gt 0){
                Write-Verbose "Restoring database permissions" -Verbose
                Restore-DatabasePermissions -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -permissions $targetPermissions
            }
           
            # foreach ($newTargetDBpermission in $targetMembers) {
            #     $newTargetDBperm = $null
            #     if ($newTargetDBpermission.Read -ne $null) {
            #         "$(Get-Date): Adding read permissions to " + $newTargetDBpermission.Role.Name + " on $newTargetSvr $newtargetDB"
            #         if ($newTargetDBperm -eq $null) {
            #             $newTargetDBperm = $NewTargetDB.DatabasePermissions.Add($newTargetDBpermission.Role.Name)
            #         }
            #         $NewTargetDBPerm.Read = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            #     }
            #     if ($newTargetDBpermission.Administer -eq $true ) {
            #         "$(Get-Date): Adding admin permissions to " + $newTargetDBpermission.Role.Name + " on $newTargetSvr $newtargetDB"
            #         if ($newTargetDBperm -eq $null) {
            #             $newTargetDBperm = $NewTargetDB.DatabasePermissions.Add($newTargetDBpermission.Role.Name)
            #         }
            #         $NewTargetDBPerm.Administer = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            #     }
                                     
            #     if ($newTargetDBpermission.Process -eq $true) {
            #         "$(Get-Date):      Adding process permissions to " + $newTargetDBpermission.Role.Name + " on $newTargetSvr $newtargetDB"
            #         if ($newTargetDBperm -eq $null) {
            #             $newTargetDBperm = $NewTargetDB.DatabasePermissions.Add($newTargetDBpermission.Role.Name)
            #         }
            #         $NewTargetDBPerm.Process = [Microsoft.AnalysisServices.ReadAccess]::Allowed
            #     }
            #     if ($newTargetDBperm -ne $null) {
            #         $NewTargetDBPerm.Update()
            #     }                           
            # }
        }              
        Write-Verbose "$(Get-Date):      Sync Script Completed for $sourceDB" -Verbose
    }
}