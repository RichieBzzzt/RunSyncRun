Function Test-FreeDiskSpace {
    param (
        $sourcesvr,
        $sourceDB,
        $targetsvr,
        $targetdb
    )

    if ($chkdsk) {
        # disk checks
        # get disk details for target server
        $targetDisk = $targetsvr.ServerProperties
        $targetDisk = $targetDisk | Select-Object name, value | Where-Object {$_.Name -eq 'DataDir'} | Select-Object -Expand value 
        $TargetDisk.ToString() | Out-Null
        $TargetDriveLetter = $targetDisk.Substring(0, 2)

        $targetdisksize = Get-WmiObject Win32_LogicalDisk -ComputerName $targetsvr -Filter "DeviceID='$TargetDriveLetter'" | Select-Object -Expand Size
        $targetfreespace = Get-WmiObject Win32_LogicalDisk -ComputerName $targetsvr -Filter "DeviceID='$TargetDriveLetter'" | Select-Object -Expand FreeSpace
        $targetdisksize = $targetdisksize / 1gb
        $targetfreespace = $targetfreespace / 1gb
        # get disk details for source server
        $sourceDisk = $sourcesvr.ServerProperties
        $sourceDisk = $sourceDisk | Select-Object name, value | Where-Object {$_.Name -eq 'DataDir'} | Select-Object -Expand value 
        $sourceDisk.ToString() | Out-Null
        $SourceDriveLetter = $SourceDisk.Substring(0, 2)
        $sourcedisksize = Get-WmiObject Win32_LogicalDisk -ComputerName $sourcesvr -Filter "DeviceID='$sourceDriveLetter'" | Select-Object -Expand Size
        $Sourcefreespace = Get-WmiObject Win32_LogicalDisk -ComputerName $Sourcesvr -Filter "DeviceID='$SourceDriveLetter'" | Select-Object -Expand FreeSpace
        $sourcedisksize = $sourcedisksize / 1gb
        $Sourcefreespace = $Sourcetfreespace / 1gb
        # first check; are the target and source disks the same size?
        if ($targetdisksize -ge $sourcedisksize) {

            Write-Verbose "$(Get-Date): both target and source disk sizes are the same or target is larger" -Verbose
        }
        # if disk are not the same size, then how much smaller is the target? 
        # we still might be able to sync with the smaller disk
        if ($targetdisksize -le $sourcedisksize) {
            $total = $sourcedisksize - $targetdisksize
            $total = $total / 1gb
            $t = -format "d MMM yy HH:mm:ss"
            Write-Verbose "$(Get-Date): target disk is smaller than the source disk by $total gb " -Verbose
        } 
        $sourceDBfolder = $sourceDB.name
        $sourceDBSize = 
        invoke-command -computername $sourcesvr -scriptblock {param ($sourceDBfolder, $SourceDisk) $path = Get-ChildItem $SourceDisk | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match $sourceDBfolder}
            $path = $SourceDisk + "\" + $path
            $fso = New-Object -comobject Scripting.FileSystemObject
            $folder = $fso.GetFolder($path)
            $size = $folder.size
            $size = $size / 1gb
            $size
        } -Args $sourceDBfolder, $sourceDisk

        if ($targetfreespace -le $sourceDBSize ) {
            $t = Get-Date -format "d MMM yy HH:mm:ss"
            Write-warning "${t}:       There may not be enough free space to synchronize the database $sourceDB. Consider dropping the target database $sourceDB on $targetsvr."

            if ($targetdb -eq $null) {
                write-error "${t}:      There is not target database $sourcedb to drop. The disk will have to be increased. Database will not be synced"
                $skip = 1
            }
        }
    }
}