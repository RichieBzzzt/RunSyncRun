Import-Module ".\RunSyncRun" -Force
Clear-Host

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" #-restoreConnectionString

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -synchroniseSecuritySetting "SkipMembership" -applyCompressionSetting "true" #-restoreConnectionString

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "asseenonscreen\richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -DataSourceName "WideWorldImportersDW" -synchroniseSecuritySetting "CopyAll" -applyCompressionSetting "true" #-restoreConnectionString
