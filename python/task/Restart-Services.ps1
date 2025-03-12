# Restart-Services.ps1
# Purpose: Restart specified Windows services and log the results
# Usage: PowerShell -ExecutionPolicy Bypass -File Restart-Services.ps1

# Configuration
$servicesToRestart = @(
    "Jenkins",     # Example: SQL Server
    #"W3SVC",         # Example: IIS Web Service
    #"MSSQLSERVER"    # Example: MS SQL Server
)
$logFile = "C:\vs\python\task\service_restart_log.txt"
#$emailNotification = $true
#$emailParams = @{
    #From = "server@company.com"
    #To = "admin@company.com"
    #Subject = "Service Restart Report"
    #SMTPServer = "mail.company.com"
#}

# Create log directory if it doesn't exist
$logDir = Split-Path -Path $logFile -Parent
if (!(Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Start logging
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "===== Service Restart Operation: $timestamp ====="

# Initialize report content
$reportContent = "Service Restart Report - $timestamp`n`n"
$restartFailed = $false

# Function to restart a service
function Restart-ServiceSafely {
    param (
        [string]$ServiceName
    )
    
    try {
        # Check if service exists
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        
        # Log current status
        $status = "Before restart: $($service.Status)"
        Write-Output "Service: $ServiceName - $status"
        Add-Content -Path $logFile -Value "Service: $ServiceName - $status"
        
        # Attempt to restart the service
        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        
        # Wait to confirm restart and get new status
        Start-Sleep -Seconds 5
        $service = Get-Service -Name $ServiceName
        $newStatus = "After restart: $($service.Status)"
        
        # Log results
        Write-Output "Service: $ServiceName - $newStatus"
        Add-Content -Path $logFile -Value "Service: $ServiceName - $newStatus - SUCCESS"
        
        return @{
            Success = $true
            Name = $ServiceName
            Status = $service.Status
            Message = "Successfully restarted"
        }
    }
    catch {
        # Log error
        $errorMessage = $_.Exception.Message
        Write-Error "Failed to restart service $ServiceName. Error: $errorMessage"
        Add-Content -Path $logFile -Value "Service: $ServiceName - FAILED - Error: $errorMessage"
        
        return @{
            Success = $false
            Name = $ServiceName
            Status = "Unknown"
            Message = $errorMessage
        }
    }
}

# Restart each service and collect results
$results = @()
foreach ($service in $servicesToRestart) {
    $result = Restart-ServiceSafely -ServiceName $service
    $results += $result
    
    if (-not $result.Success) {
        $restartFailed = $true
    }
}

# Generate report
$reportContent += "Results:`n"
foreach ($result in $results) {
    $status = if ($result.Success) { "SUCCESS" } else { "FAILED" }
    $reportContent += "- $($result.Name): $status - $($result.Message) (Current status: $($result.Status))`n"
}

# Add summary to the log
Add-Content -Path $logFile -Value "Restart operation completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -Path $logFile -Value "----------------------------------------"

# Send email notification if configured
if ($emailNotification) {
    try {
        $emailParams.Body = $reportContent
        Send-MailMessage @emailParams
        Add-Content -Path $logFile -Value "Email notification sent successfully."
    }
    catch {
        Add-Content -Path $logFile -Value "Failed to send email notification: $($_.Exception.Message)"
    }
}

# Output the final report to console
Write-Output "`n$reportContent"

# Return error code for task scheduler
if ($restartFailed) {
    exit 1
} else {
    exit 0
}