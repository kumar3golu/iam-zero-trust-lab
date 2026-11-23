# Entra ID MFA Registration Audit

A small, read-only PowerShell automation example for Microsoft Entra ID identity security.

## What it does
- Retrieves authentication-method registration details using Microsoft Graph
- Reports MFA registration and capability status
- Exports a CSV file for authorized internal review

## Prerequisites
- PowerShell and Microsoft Graph PowerShell SDK
- `Install-Module Microsoft.Graph -Scope CurrentUser`
- `AuditLog.Read.All` delegated permission with required consent
- Appropriate Entra reporting role (such as Reports Reader)

## Run
```powershell
./Get-EntraMfaRegistrationReport.ps1
```

The output is `MFA_Audit_Report.csv` in the current directory.

**Security:** Do not commit real employee reports, user principal names, or tenant data. MFA registration does not prove MFA is enforced through Conditional Access. This example has not been tested against a live tenant.
