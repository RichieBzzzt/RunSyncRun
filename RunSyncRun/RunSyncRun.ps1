Import-Module ".\RunSyncRun" -Force
Clear-Host

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube"  -synchroniseSecuritySetting "IgnoreSecurity" -applyCompressionSetting "true" 

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube"  -synchroniseSecuritySetting "SkipMembership" -applyCompressionSetting "true" 

Invoke-DatabaseSync -sourceInstance ".\aiui" -targetInstance ".\otoh" -syncAccount "asseenonscreen\richardlee" -rolename "SyncMeBaby" -database "WideWorldImportersMultidimensionalCube" -synchroniseSecuritySetting "CopyAll" -applyCompressionSetting "true" 