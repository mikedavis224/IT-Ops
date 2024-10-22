function Export-ErrorLogs {
    param (
        [string]$OutputPath = "C:\logs\errors.csv",
        [int]$MaxEvents = 100,
        [int]$DaysBack1Day = 1,
        [int]$DaysBack1Week = 7
    )

    # Set date range variables
    $LastDay = (Get-Date).AddDays(-$DaysBack1Day)
    $LastWk = (Get-Date).AddDays(-$DaysBack1Week)

    # Get error events from last 1 day
    $sysday = Get-WinEvent -FilterHashtable @{LogName='system'; Level='2'; StartTime=$LastDay} -MaxEvents $MaxEvents
    $appday = Get-WinEvent -FilterHashtable @{LogName='application'; Level='2'; StartTime=$LastDay} -MaxEvents $MaxEvents

    # Get error events from last 7 days
    $syswk = Get-WinEvent -FilterHashtable @{LogName='system'; Level='2'; StartTime=$LastWk} -MaxEvents $MaxEvents
    $appwk = Get-WinEvent -FilterHashtable @{LogName='application'; Level='2'; StartTime=$LastWk} -MaxEvents $MaxEvents

    # Ensure the output directory exists
    $outputDir = [System.IO.Path]::GetDirectoryName($OutputPath)
    if (!(Test-Path $outputDir -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $outputDir
    }

    # Export logs to CSV file
    $sysday | Select-Object -Property RecordId, TimeCreated, Id, LogName, LevelDisplayName, Message | Export-Csv -Path $OutputPath -Force -NoTypeInformation
    $appday | Select-Object -Property RecordId, TimeCreated, Id, LogName, LevelDisplayName, Message | Export-Csv -Append -Path $OutputPath -Force -NoTypeInformation
    $syswk | Select-Object -Property RecordId, TimeCreated, Id, LogName, LevelDisplayName, Message | Export-Csv -Append -Path $OutputPath -Force -NoTypeInformation
    $appwk | Select-Object -Property RecordId, TimeCreated, Id, LogName, LevelDisplayName, Message | Export-Csv -Append -Path $OutputPath -Force -NoTypeInformation

    # Open the error logs CSV file
    Invoke-Item $OutputPath
}
