Function Start-DatabaseSync {
    param (
        $sourcedb,
        $sourcesvr,
        $targetsvr,
        $synchroniseSecuritySetting,
        $applyCompressionSetting
    )
    $syncxmla = '
<Synchronize xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
<Source>
    <ConnectionString>Provider=MSOLAP.8;Data Source=@@Source@@;Integrated Security=SSPI</ConnectionString>
            <Object>
  <DatabaseID>@@DatabaseID@@</DatabaseID>
</Object>
</Source>
<SynchronizeSecurity>@@SynchronizeSecurity@@</SynchronizeSecurity>
<ApplyCompression>@@ApplyCompression@@</ApplyCompression>
</Synchronize>'       
    $syncxmla = $syncxmla.Replace("@@DatabaseID@@", $sourcedb)
    $syncxmla = $syncxmla.Replace("@@Source@@", $sourcesvr)
    $syncxmla = $syncxmla.Replace("@@SynchronizeSecurity@@", $synchroniseSecuritySetting)
    $syncxmla = $syncxmla.Replace("@@ApplyCompression@@", $applyCompressionSetting)
    Write-Verbose "$(Get-Date): Synchronising $sourcedb from $sourcesvr to $targetsvr" -Verbose
    try {
        $resultxml = $targetsvr.Execute($syncxmla)
        Write-Output $resultXml.InnerText
    }
    catch {
        throw $_.Exception
    }
    "$(Get-Date): Sync Complete for $sourceDB  from $sourcesvr to $targetsvr"

}