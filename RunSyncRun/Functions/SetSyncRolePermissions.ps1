
Function Set-SyncRolePermissions {
    param (
        $SsasDatabase,
        $syncrole
    )
    #check to see if role that exists has administer permission
    #if not then administer is added
    $sourceDBperm = $SsasDatabase.DatabasePermissions.FindByRole($syncrole.id)
    if ($sourceDBperm.Administer -eq $false) {
        $sourceDBperm.Administer = [Microsoft.AnalysisServices.ReadAccess]::Allowed
        $sourceDBperm.Update()
        Write-Verbose "$(Get-Date): admin permission added for $syncrole on $SsasDatabase" -Verbose
    }
    else{
        Write-Verbose "$(Get-Date): $($sourceDBperm.Administer) $syncrole has admin permissions on $SsasDatabase" -Verbose
    }
}
