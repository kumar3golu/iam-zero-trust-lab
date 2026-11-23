# Microsoft Entra ID MFA Registration Audit
# Read-only report; requires Microsoft Graph PowerShell and AuditLog.Read.All
# A suitable Entra reporting role and consent may also be required.

$ErrorActionPreference = 'Stop'
Import-Module Microsoft.Graph.Reports -ErrorAction Stop
Connect-MgGraph -Scopes 'AuditLog.Read.All' -NoWelcome
try {
    $users = Get-MgReportAuthenticationMethodUserRegistrationDetail -All
    $report = $users | Select-Object UserPrincipalName, IsMfaRegistered, IsMfaCapable, DefaultMfaMethod
    $path = Join-Path (Get-Location) 'MFA_Audit_Report.csv'
    $report | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
    Write-Host "Exported $(@($report).Count) users to $path"
}
finally {
    Disconnect-MgGraph | Out-Null
}
