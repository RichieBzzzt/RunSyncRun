Function Set-SyncRole {
    param (
        $SsasDatabase,
        $syncRole
    )
    $role = $null
    $role = $SsasDatabase.Roles.FindByName($syncRole)
    if ($role -eq $null) {
        $roleToCreate = new-Object([Microsoft.AnalysisServices.Role])($syncRole)
        $SsasDatabase.Roles.Add($roleToCreate)
        $roleToCreate.Update()
        Write-Verbose "$(Get-Date): role $syncRole created on $SsasDatabase" -Verbose  
    }  
    # check if service account that runs target instance is a member of the role
    # if it is not then we will add it to role
    # this is necessary to ensure that the databases can be synced
}