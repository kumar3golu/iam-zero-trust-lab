<#
.SYNOPSIS
Lists active directory role assignments for an Entra ID security review.
.NOTES
Requires Microsoft.Graph.Authentication and Microsoft.Graph.Identity.Governance.
Install if needed: Install-Module Microsoft.Graph.Identity.Governance -Scope CurrentUser
Run only against a tenant you are authorized to review.
Delegated RoleManagement.Read.Directory requires appropriate consent and user permissions.
Read-only: no users, roles or policies are modified.
Does not enumerate PIM eligible assignments or expand group membership.
Do not publish real tenant output. No cloud resources are provisioned.
Educational sample; not live-tested.
#>
$ErrorActionPreference = 'Stop'
Import-Module Microsoft.Graph.Identity.Governance
Connect-MgGraph -Scopes 'RoleManagement.Read.Directory' -ContextScope Process -NoWelcome
try {
    $roles = @{}
    Get-MgRoleManagementDirectoryRoleDefinition -All | ForEach-Object {
        $roles[$_.Id] = $_.DisplayName
    }
    Get-MgRoleManagementDirectoryRoleAssignment -All |
        Select-Object @{Name='Role';Expression={$roles[$_.RoleDefinitionId]}},
            PrincipalId, DirectoryScopeId |
        Sort-Object Role |
        Format-Table -AutoSize
} finally {
    Disconnect-MgGraph | Out-Null
}
