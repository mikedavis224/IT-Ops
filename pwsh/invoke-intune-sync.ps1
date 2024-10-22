# Define the log file path globally
$global:logFilePath = "C:\Logs\IntuneSyncLog.txt"

# Function to ensure the log directory exists, if not, create it
function Ensure-LogDirectoryExists {
    $logDirectory = [System.IO.Path]::GetDirectoryName($global:logFilePath)

    if (-not (Test-Path $logDirectory)) {
        try {
            # Create the directory if it does not exist
            New-Item -Path $logDirectory -ItemType Directory | Out-Null
            Write-Host "Log directory created: $logDirectory" -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to create log directory $logDirectory" -ForegroundColor Red
            throw $_
        }
    }
}

# Function to log messages to the log file
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    Ensure-LogDirectoryExists
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $global:logFilePath -Value $logMessage

    # Also output to console
    Write-Host $logMessage
}

# Function to retrieve the GUID associated with Intune/MDM enrollment
function Find-IntuneEnrollmentGuid {
    try {
        # Dynamically search for tasks with 'EnterpriseMgmt' in the path
        $tasks = Get-ScheduledTask | Where-Object { $_.TaskPath -like "*EnterpriseMgmt*" }
        
        if ($tasks) {
            # Extract the GUID from the TaskPath
            $guid = ($tasks[0].TaskPath -split '\\')[-2]
            Write-Log "Intune Enrollment GUID found: $guid" -Level "INFO"
            return $guid
        } else {
            Write-Log "No Intune Enrollment tasks found." -Level "ERROR"
            return $null
        }
    } catch {
        Write-Log "Error while retrieving Intune Enrollment GUID: $_" -Level "ERROR"
        return $null
    }
}

# Function to start an Intune sync by triggering the scheduled task
function Start-IntuneSync {
    param (
        [string]$GUID
    )

    if (-not $GUID) {
        Write-Log "No valid GUID provided, cannot sync with Intune." -Level "ERROR"
        return
    }

    try {
        # Construct the scheduled task name
        $taskName = "Microsoft\Windows\EnterpriseMgmt\$GUID\Schedule #3 created by enrollment client"
        
        # Start the scheduled task to sync with Intune
        Start-ScheduledTask -TaskName $taskName
        Write-Log "Successfully triggered Intune sync for GUID: $GUID" -Level "INFO"
    } catch {
        Write-Log "Error while starting Intune sync task: $_" -Level "ERROR"
    }
}

# Main function to initiate the Intune sync process
function Invoke-IntuneSync {
    Write-Log "Starting Intune sync process..." -Level "INFO"

    # Step 1: Retrieve the Intune Enrollment GUID
    $intuneGUID = Find-IntuneEnrollmentGuid

    # Step 2: Start Intune sync if a valid GUID is found
    if ($intuneGUID) {
        Start-IntuneSync -GUID $intuneGUID
    } else {
        Write-Log "Failed to sync with Intune: No Intune Enrollment GUID found." -Level "ERROR"
    }

    Write-Log "Intune sync process completed." -Level "INFO"
}

# Entry point: Start Intune sync across all laptops
Invoke-IntuneSync
