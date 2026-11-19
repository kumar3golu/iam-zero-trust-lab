#Requires -Version 5.1
<#
.SYNOPSIS
Read-only Entra directory role audit with optional CSV export.
.EXAMPLE
.\day-001-entra-role-audit.ps1 -Demo
.EXAMPLE
.\day-001-entra-role-audit.ps1 -TenantId 'YOUR-TENANT-GUID' -CsvPath './roles.csv'
.NOTES
Live prerequisites: Install-Module Microsoft.Graph.Identity.Governance -Scope CurrentUser
Use an authorized account with RoleManagement.Read.Directory and a supported directory role.
Optional -IncludeNames requests Directory.Read.All (broader permission; admin approval may be required).
Optional -IncludeEligible lists PIM eligibility schedule instances; appropriate licensing/access required.
Demo mode requires no modules or cloud account. No paid resources provisioned.
Reports contain sensitive tenant data; keep locally in an approved location.
Group assignments are not expanded. No policy or role changes are made.
Educational tool; live execution has not been validated.
#>
[CmdletBinding()]
param(
    [switch]$Demo,
    [guid]$TenantId,
    [switch]$IncludeNames,
    [switch]$IncludeEligible,
    [string]$CsvPath
)
$ErrorActionPreference = 'Stop'
if ($Demo) {
    $report = @(
        [pscustomobject]@{Role='Global Administrator';DisplayName='Demo Admin';UPN='admin@example.invalid';PrincipalId='DEMO-001';Scope='/';Assignment='Active'}
        [pscustomobject]@{Role='Security Reader';DisplayName='Demo Reader';UPN='reader@example.invalid';PrincipalId='DEMO-002';Scope='/';Assignment='Eligible'}
    )
} else {
    if (-not $PSBoundParameters.ContainsKey('TenantId')) {
        throw 'Specify -TenantId with your authorized tenant GUID, or use -Demo.'
    }
    if (-not (Get-Module -ListAvailable Microsoft.Graph.Identity.Governance)) {
        throw 'Install-Module Microsoft.Graph.Identity.Governance -Scope CurrentUser, then retry.'
    }
    Import-Module Microsoft.Graph.Identity.Governance
    if ($IncludeEligible -and -not (Get-Command Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -ErrorAction SilentlyContinue)) {
        throw 'Update the Microsoft.Graph.Identity.Governance module to enable eligibility reporting.'
    }
    $scopes = @('RoleManagement.Read.Directory')
    if ($IncludeNames) { $scopes += 'Directory.Read.All' }
    if ($IncludeEligible) { $scopes += 'RoleEligibilitySchedule.Read.Directory' }
    Connect-MgGraph -TenantId $TenantId.ToString() -Scopes $scopes -ContextScope Process -NoWelcome
    try {
        if ((Get-MgContext).TenantId -ne $TenantId.ToString()) { throw 'Unexpected tenant context.' }
        $roles = @{}
        Get-MgRoleManagementDirectoryRoleDefinition -All | ForEach-Object {
            $roles[$_.Id] = $_.DisplayName
        }
        $cache = @{}
        $assignments = @(Get-MgRoleManagementDirectoryRoleAssignment -All | ForEach-Object {
            [pscustomobject]@{Item=$_;Kind='Active'}
        })
        if ($IncludeEligible) {
            $assignments += @(Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance -All | ForEach-Object {
                [pscustomobject]@{Item=$_;Kind='Eligible'}
            })
        }
        $report = @(foreach ($entry in $assignments) {
            $a = $entry.Item
            $name = ''; $upn = ''
            if ($IncludeNames -and $a.PrincipalId) {
                if (-not $cache.ContainsKey($a.PrincipalId)) {
                    try {
                        $cache[$a.PrincipalId] = Invoke-MgGraphRequest -Method GET -Uri ('https://graph.microsoft.com/v1.0/directoryObjects/' + $a.PrincipalId) -OutputType PSObject
                    } catch {
                        Write-Warning ('Unable to resolve principal ' + $a.PrincipalId)
                        $cache[$a.PrincipalId] = $null
                    }
                }
                $obj = $cache[$a.PrincipalId]
                if ($obj) { $name = $obj.displayName; $upn = $obj.userPrincipalName }
            }
            $roleName = $roles[$a.RoleDefinitionId]
            if (-not $roleName) { $roleName = $a.RoleDefinitionId }
            [pscustomobject]@{Role=$roleName;DisplayName=$name;UPN=$upn;PrincipalId=$a.PrincipalId;Scope=$a.DirectoryScopeId;Assignment=$entry.Kind}
        })
    } finally {
        Disconnect-MgGraph | Out-Null
    }
}
$report = @($report | Sort-Object Role, Assignment, PrincipalId)
if ($report.Count -eq 0) { Write-Host 'No assignments returned.'; return }
if ($CsvPath) {
    # Prevent accidental spreadsheet formula interpretation in exported text.
    $report | ForEach-Object {
        $safe = [ordered]@{}
        foreach ($p in $_.PSObject.Properties) {
            $value = [string]$p.Value
            if ($value -match '^[\s]*[=+@-]') { $value = "'" + $value }
            $safe[$p.Name] = $value
        }
        [pscustomobject]$safe
    } | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 -NoClobber
    Write-Host ('CSV saved: ' + $CsvPath)
}
$report | Format-Table -AutoSize
Write-Host ('Total assignment records: ' + $report.Count)
