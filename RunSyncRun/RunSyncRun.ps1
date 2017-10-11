Import-Module "C:\Users\SQLTraining\source\repos\RunSyncRun\RunSyncRun" -Force
Clear-Host
Get-Date
Invoke-DatabaseSync -sourceInstance ".\hh" -targetInstance "." -syncAccount "SQLTraining" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -Drop -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" -restore 