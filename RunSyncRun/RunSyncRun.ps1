Import-Module ".\RunSyncRun" -Force
Clear-Host
Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" #-restore #-drop