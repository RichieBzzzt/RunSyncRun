
Function Set-SyncRolePermissions {
    param (
        $SsasDatabase,
        $syncrole
    )
    #check to see if role that exists has administer permission
    #if not then administer is added
    $sourceDBperm = $SsasDatabase.DatabasePermissions.FindByRole($syncrole)
    if ($sourceDBperm.Administer -eq $false) {
        $sourceDBperm.Administer = [Microsoft.AnalysisServices.ReadAccess]::Allowed
        $sourceDBperm.Update()
        Write-Verbose "$(Get-Date): admin permission added for $syncrole on $SsasDatabase" -Verbose
    }
}
