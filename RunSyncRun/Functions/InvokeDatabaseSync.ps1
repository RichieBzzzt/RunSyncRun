
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
        [switch] $restoreConnectionString
    )
    $validSynchroniseSecuritySetting = @("CopyAll", "SkipMembership", "IgnoreSecurity")
    if ($synchroniseSecuritySetting -notin $validSynchroniseSecuritySetting) {
        Write-Error ("$synchroniseSecuritySetting -does not match any of the following - {0}" -f ($validSynchroniseSecuritySetting -join ", "))
        Throw
    }
    if ($ApplyCompressionSetting -notin ("true", "false")) {
        Write-Error ("$ApplyCompressionSetting must be either 'true' or 'false'.")
        Throw
    }
    Write-Verbose "$(Get-Date): Starting up..." -Verbose
    Add-Type -Path "C:\Users\richardlee\Downloads\microsoft.analysisservices.unofficial.13.0.4001.1\lib\Microsoft.AnalysisServices.dll"
    $sourcesvr = Connect-SsasServer -ssasServer $sourceInstance
    Write-Verbose "Connecting to $sourcesvr as source. This is where we will be syncing FROM."
    $targetsvr = Connect-SsasServer -ssasServer $targetInstance
    Write-Verbose "Connecting to $targetsvr as target. This is where we will be syncing TO."

    $db = Get-ssasDatabase -ssasServer $sourcesvr -SsasDatabase $database
    foreach ($sourceDB in $db) {
        $targetSsasDatabase = $null
        $targetConnectionString = $null
        if ($restoreConnectionString) {
            Write-Verbose "restoreConnectionString switch was used. Backing up connection string." -Verbose
            $targetSsasDatabase = Get-ssasDatabase -ssasServer $targetsvr -ssasDatabase $database -ActionOnError "Continue"
            $targetConnectionString = Backup-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName
        }
        Write-Verbose "Checking if role $rolename exists on $sourceDB. If not will create." -Verbose
        $syncRole = Set-SyncRole -SsasDatabase $sourceDB -syncRole $rolename
        Write-Verbose "Checking if role $($syncRole.Name) has correct permisisons on $sourceDB. If not will add." -Verbose
        Set-SyncRolePermissions -SsasDatabase $sourceDB -syncRole $syncRole
        Write-Verbose "Checking if $syncAccount is member of role $($syncRole.Name) on $sourceDB. If not will add." -Verbose
        Set-AccountToSyncRole -SsasDatabase $sourceDB -account $syncAccount -syncRole $rolename
        Start-DatabaseSync -sourcedb $sourceDB -sourcesvr $sourcesvr -targetsvr $targetsvr -synchroniseSecuritySetting $synchroniseSecuritySetting -applyCompressionSetting $applyCompressionSetting
        $targetsvr.Refresh()
        if ($restoreConnectionString) {
            if ($targetConnectionString -ne $null) {
                restoreConnectionString-ConnectionString -ssasServer $targetsvr -ssasDatabase $targetSsasDatabase -dataSourceName $DataSourceName -ConnectionString $targetConnectionString
            }
        }              
        Write-Verbose "$(Get-Date):      Sync Script Completed for $sourceDB" -Verbose
    }
}