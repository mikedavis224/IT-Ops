# Function to start logging the session
function Start-Logging {
    $logPath = "C:\Logs\LeaverProcessingLog.txt"
    Start-Transcript -Path $logPath -Append
    Write-Host "Logging started at $logPath" -ForegroundColor Green
}

# Function to stop logging the session
function Stop-Logging {
    Stop-Transcript
    Write-Host "Logging stopped." -ForegroundColor Green
}

# Function to check if there is an active connection to Exchange Online
function Connect-ExchangeOnlineIfNeeded {
    Try {
        if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
            Connect-ExchangeOnline -UserPrincipalName michael-admin@energixrenewables.com -ShowProgress $true
            Write-Host "Connected to Exchange Online successfully." -ForegroundColor Green
        } else {
            Write-Host "Active connection to Exchange Online found." -ForegroundColor Green
        }
    } Catch {
        Write-Host "Error: Failed to connect to Exchange Online." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to convert a user's mailbox to a shared mailbox
function Convert-MailboxToShared {
    param (
        [string]$leaver
    )
    Try {
        Set-Mailbox $leaver -Type Shared
        Write-Host "Successfully converted $leaver's mailbox to a shared mailbox." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to convert $leaver's mailbox." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to send mail to the user's manager
function Send-MailToManager {
    param (
        [string]$leaver,
        [string]$Manager
    )
    Try {
        Set-Mailbox -Identity "$leaver" -DeliverToMailboxAndForward $true -ForwardingAddress $Manager
        Write-Host "Mail is now forwarded to $Manager for $leaver." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to forward mail for $leaver." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to set auto-reply for a user
function Set-AutoReplyForLeaver {
    param (
        [string]$leaver,
        [string]$Manager,
        [string]$LeaveDate
    )

    # Convert $LeaveDate to a DateTime object
    #$leaveDateObj = [datetime]::ParseExact($LeaveDate, "MM/dd/yyyy", $null)

    # Calculate the end date (30 days from the leave date)
    #$endDate = $leaveDateObj.AddDays(30)

    Try {
        Set-MailboxAutoReplyConfiguration -Identity $leaver -AutoReplyState Enabled -InternalMessage "Hello,

        Thank you for your message. I am no longer with Energix Renewables as of $LeaveDate. For immediate assistance, please reach out to $Manager.

        Thank you, " -ExternalMessage "Hello,

        Thank you for your message. I am no longer with Energix Renewables as of $LeaveDate. For immediate assistance, please reach out to $Manager.

        Thank you, ." 
        #-ExternalMessage All
        #-StartTime $leaveDateObj `
        #-EndTime $endDate
        
        Write-Host "Auto-reply set for $leaver with the leave date of $LeaveDate." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to set auto-reply for $leaver." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to remove user from distribution groups
function Remove-UserFromGroups {
    param (
        [string]$leaver
    )
    Try {
        $DistributionGroups = Get-Distributiongroup -resultsize unlimited | Where-Object {!$_.GroupType.contains("SecurityEnabled")}
        ForEach ($Group in $DistributionGroups) {
            If ((Get-DistributionGroupMember $Group.Name | Select-Object -Expand PrimarySmtpAddress) -contains $leaver) {
                Remove-DistributionGroupMember -Identity $Group.Name -Member $leaver -Confirm:$false
                Write-Host "Removed $leaver from group $($Group.Name)." -ForegroundColor Green
            }
        }
    } Catch {
        Write-Host "Error: Failed to remove $leaver from groups." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to remove calendar events organized by the user
function Remove-UserCalendarEvents {
    param (
        [string]$leaver
    )
    Try {
        Remove-CalendarEvents -Identity $leaver -CancelOrganizedMeetings -QueryStartDate (Get-Date) -QueryWindowInDays 365
        Write-Host "Removed calendar events for $leaver." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to remove calendar events for $leaver." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Function to disable an Azure AD user
function Disable-AzureADUser {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Leaver
    )
    
    # Check if AzureAD module is installed
    if (-not (Get-Module -ListAvailable -Name AzureAD)) {
        Install-Module -Name AzureAD -Force -AllowClobber
    }
    
    # Connect to Azure AD
    Try {
        if (-not (Get-AzureADSignedInUser)) {
            Connect-AzureAD
        }
    } Catch {
        Write-Host "Error: Failed to connect to Azure AD." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
    }

    # Disable the user account
    Try {
        Set-AzureADUser -ObjectId $Leaver -AccountEnabled $false
        Write-Host "User  $Leaver has been disabled in Azure AD." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Failed to disable user in Azure AD." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

    

# Main function to remove a leaver from the system
function Remove-Leaver {
    # Start logging
    Start-Logging
    
    Try {
        #Set departed user variables
        $user = Read-Host "User name (firstName.lastName)"
        $leaver = "$user@energixrenewables.com"
        $userMgr = Read-Host "User's manager (firstName.lastName)"
        $manager = "$userMgr@energixrenewables.com"
        $leaveDate = Get-Date -Format "MM/dd/yyyy"

        # Call functions
        Connect-ExchangeOnlineIfNeeded
        Convert-MailboxToShared -Leaver $leaver
        Send-MailToManager -Leaver $leaver -Manager $manager
        Set-AutoReplyForLeaver -Leaver $leaver -Manager $manager -LeaveDate $leaveDate
        Remove-UserFromGroups -Leaver $leaver
        Remove-UserCalendarEvents -Leaver $leaver
        Disable-AzureAdUser -Leaver $leaver

        Write-Host "Process for $leaver completed successfully." -ForegroundColor Green
    } Catch {
        Write-Host "Error: Process for $leaver failed." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    } finally {
        # Stop logging
        Stop-Logging
    }
}

# Call the function to remove the leaver
Remove-Leaver
