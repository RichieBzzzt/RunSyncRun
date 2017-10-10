Import-Module "C:\RunSyncRun" -Force
cls
Get-Date
Invoke-DatabaseSync -sourceInstance ".\hh" -targetInstance "." -syncAccount "SQLTraining" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -targetDatabase "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -Drop -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" -restore 