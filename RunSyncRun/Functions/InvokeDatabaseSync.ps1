# database is an optional parameter
# if not included then script will run for all databases on source instance
# run for specific databases by including a comma separated list of names 
# example syncCubes.ps1 -sourceInstance "olap01" -targetInstance "olap02" -syncAccount "ad1\sql_analysis" -Database "ADWORKS,ADWORKSDW" -Drop
# you can include just one database name
# drop is also optional parameter; if disk space not sufficient for 2 copies of db then it will drop the target database
# full explanation of how drop works in comments below
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
 
    [void][System.reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
    
    $sourcesvr = Connect-SsasServer -ssasServer $sourceInstance
    $targetsvr = Connect-SsasServer -ssasServer $targetInstance
    $db = Get-ssasDatabase -ssasServer $sourcesvr -SsasDatabase $database
    $skip = 0
 
    foreach ($sourceDB in $db) {
        Write-Verbose "$(Get-Date): *** Running Sync Script for $sourceDB ***" -Verbose
        $targetSsasDatabase = $null
        $targetConnectionString = $null
        $targetSsasDatabase = Get-ssasDatabase -ssasServer $targetsvr -ssasDatabase $database
        if ($restore) {
            $targetConnectionString = Backup-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName
        }
        Set-SyncRole -SsasDatabase $sourceDB -syncRole $rolename
        Set-SyncRolePermissions -SsasDatabase $sourceDB -syncRole $rolename
        Set-AccountToSyncRole -SsasDatabase $sourceDB -account $syncAccount -syncRole $rolename
        #TODO - Test-FreeDiskSpace is not working
        # if ($chkdsk) {
        #     Test-FreeDiskSpace -sourcesvr $sourcesvr -sourceDB $sourceDB -targetsvr $targetsvr -targetdb $targetDB
        # }
        if ($restore) {
            $targetRoles = Backup-DatabaseRoles -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
            Write-host  $targetRoles -ForegroundColor Green
            Write-Host $targetRoles.Members.Name -BackgroundColor DarkCyan
            $targetPermissions = Backup-DatabasePermissions -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
            Write-Host $targetPermissions -ForegroundColor Green
        }
        if ($drop) {
            Remove-SsasDatabase -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase
        }
        Start-DatabaseSync -sourcedb $sourceDB -sourcesvr $sourcesvr -targetsvr $targetsvr -synchroniseSecuritySetting $synchroniseSecuritySetting -applyCompressionSetting $applyCompressionSetting
        $targetsvr.Refresh()
        if ($restore) {
            if ($targetConnectionString -ne $null) {
                Restore-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName -ConnectionString $targetConnectionString
            }
        }
        # if databases were not dropped then all roles/members and permissions are as they were
        if ($restore) {
            Restore-DatabaseRoles -ssasServer $targetsvr -ssasDatabase $database -roles $targetRoles
           
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