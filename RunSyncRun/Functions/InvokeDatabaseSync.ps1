
Function Invoke-DatabaseSync {
    <#
        .SYNOPSIS
            Synchronise one or more or all Analysis Services Databases from one instance to another.

        .DESCRIPTION
            Analysis Services in cludes a synchronisation feature that makes two Analysis Services database equivalent by copying the data and metadata on a source 
            server to a database on a target server.
        
        .PARAMETER sourceInstance
            The name of the source instance that hosts the database we want to migrate.

        .PARAMETER targetInstance
            The name of the target instance that will host hte database we are going to copy over.

        .PARAMETER syncAccount
            Optional parameter. The name of the windows user account that is executing the Function "Invoke-DatabaseSync"
            If the user is not an admin on the instance then they will need to be in a role that has full administer access on the database we are syncing over.
            If user is already in a role with admin access then ignore.
            Include the domain of user

        .PARAMETER rolename
            Optional parameter. The name of the role that will be created to add the user specified in "syncAccount"
            If user is already in a role that has full admin access, then ignore.

        .PARAMETER synchroniseSecuritySetting
            Specify whether user permission information should be included. There are three accepted values - 
                CopyAll
                    Select to include security definitions and membership information during synchronization.
                SkipMembership
                    Select to include security definitions, but exclude membership information, during synchronization.
                IgnoreSecurity
                    Select to ignore the security definition and membership information currently in the source database. If a destination database is created during synchronization, no security definitions or membership information will be copied. If the destination database already exists and has roles and memberships, that security information will be preserved.
            If one of these three options are not apssed through then the Function will throw an error prior to doing anything else!

        .PARAMETER applyCompressionSetting
            Specifies whether compression should be used. If "true", the wizard compresses all data and metadata prior to copying the files to the destination server. 
            This option results in a faster file transmission. Files are uncompressed once they reach the destination server.
            If either "true" or "false" are not specified hte function will fail!

        .EXAMPLE
            Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "contoso\richielee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube"  -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" 
        
        .EXAMPLE
            Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "contoso\richielee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube"  -synchroniseSecuritySetting "SkipMembership" -applyCompressionSetting "true" 

        .EXAMPLE
            Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "contoso\richielee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -synchroniseSecuritySetting "CopyAll" -applyCompressionSetting "false" 

        .NOTES
            use the Synchronize feature to accomplish any of the following tasks - 
                Deploy a database from a staging server onto a production server.
                Update a database on a production server with the changes made to the data and metadata in a database on a staging server.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, mandatory = $true)]
        [string] $sourceInstance,
        [Parameter(Position = 1, mandatory = $false)]
        [string[]] $database,
        [Parameter(Position = 2, mandatory = $true)]
        [string] $targetInstance,
        [Parameter(Position = 3, mandatory = $false)]
        [string] $syncAccount,
        [Parameter(Position = 4, mandatory = $false)]
        [string] $rolename,
        [Parameter(Position = 5, mandatory = $true)]
        [String] $synchroniseSecuritySetting,
        [Parameter(Position = 6, mandatory = $true)]
        [String] $applyCompressionSetting
    )
    $validSynchroniseSecuritySetting = @("CopyAll", "SkipMembership", "IgnoreSecurity")
    if ($synchroniseSecuritySetting -notin $validSynchroniseSecuritySetting) {
        Write-Error ("`$synchroniseSecuritySetting -does not match any of the following - {0}" -f ($validSynchroniseSecuritySetting -join ", "))
        Throw
    }
    if ($ApplyCompressionSetting -notin ("true", "false")) {
        Write-Error ("`$ApplyCompressionSetting must be either 'true' or 'false'.")
        Throw
    }
    Write-Verbose "$(Get-Date): Starting up..." -Verbose
    Add-Type -Path "C:\Users\richardlee\Downloads\microsoft.analysisservices.unofficial.13.0.4001.1\lib\Microsoft.AnalysisServices.dll"
    $sourcesvr = Connect-SsasServer -ssasServer $sourceInstance
    Write-Verbose "Connecting to $sourcesvr as source. This is where we will be syncing FROM."
    $targetsvr = Connect-SsasServer -ssasServer $targetInstance
    Write-Verbose "Connecting to $targetsvr as target. This is where we will be syncing TO."

    if ($database) {
        $db = Get-ssasDatabase -ssasServer $sourcesvr -SsasDatabase $database
    }
    else {
        $db = Get-ssasDatabase -ssasServer $sourcesvr 
    }
    foreach ($sourceDB in $db) {
        Write-Verbose "Checking if role $rolename exists on $sourceDB. If not will create." -Verbose
        $syncRole = Set-SyncRole -SsasDatabase $sourceDB -syncRole $rolename
        Write-Verbose "Checking if role $($syncRole.Name) has correct permisisons on $sourceDB. If not will add." -Verbose
        Set-SyncRolePermissions -SsasDatabase $sourceDB -syncRole $syncRole
        Write-Verbose "Checking if $syncAccount is member of role $($syncRole.Name) on $sourceDB. If not will add." -Verbose
        Set-AccountToSyncRole -SsasDatabase $sourceDB -account $syncAccount -syncRole $rolename
        Start-DatabaseSync -sourcedb $sourceDB -sourcesvr $sourcesvr -targetsvr $targetsvr -synchroniseSecuritySetting $synchroniseSecuritySetting -applyCompressionSetting $applyCompressionSetting
        $targetsvr.Refresh()            
        Write-Verbose "$(Get-Date):      Sync Script Completed for $sourceDB" -Verbose
    }
}