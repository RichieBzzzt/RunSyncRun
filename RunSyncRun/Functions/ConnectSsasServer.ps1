Function Connect-SsasServer {
    <#
        .SYNOPSIS
            Connect to an instance of Analysis Services
        
        .DESCRIPTION
            Connect to SSAS Server and return object for other functions
        
        .PARAMETER SsasServer
            Name of SQL Server Analysis Services Instance

        .NOTES 
            Internal function.

        .EXAMPLE
            $targetsvr = Connect-SsasServer -ssasServer $targetInstance
    #>
    param
    (
        $SsasServer
    )
    $s = New-Object Microsoft.AnalysisServices.Server
    try {
        $s.Connect($ssasServer)
        Write-Verbose "Successfully connected to $ssasServer" -Verbose
        return $s
    }
    catch {
        throw $_.Exception
    }
}