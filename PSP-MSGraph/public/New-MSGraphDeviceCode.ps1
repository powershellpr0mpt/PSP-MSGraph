<#
.SYNOPSIS
Obtain a Device code required to obtain a JWT token to access MS Graph API

.DESCRIPTION
Obtain a Device code required to obtain a JWT token to access MS Graph API
Supports MFA and will automatically open the devicelogin page and copy your device code to clipboard so you can quickly paste the code without further interference
Uses the default scope as permissions provided by the Azure AD Application

.PARAMETER ClientId
Provide the ClientID [Application ID] to which you should connect

.PARAMETER TenantId
Provide the Tenant ID to which you should connect

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $TenantId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $DeviceCode = New-MSGraphDeviceCode -ClientId $ClientId -TenantId $TenantId
PS C:\> $DeviceCode

user_code        : C77DCAUF6
device_code      : CAQABAAEAAACQN9QBRU3jT6bcBSLZNUj76mLqR6wOZa63IFD7ibz3YQzBgHl2iKINwwdkS62TIsSe77jKYIIrbH0Qqu4su86swu4-Hieir4vOOW-M9T33B8O5Clp4jv2jPEkqINw-lGUS876m8pkf-aZrz7FTzul0We2vQC22QFLFEfX6NyB9VYKN2bjuUSPzZn
                   R6py6av38gAA
verification_url : https://microsoft.com/devicelogin
expires_in       : 900
interval         : 5
message          : To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code C77DCAUF6 to authenticate.

.NOTES
Name: New-MSGraphDeviceCode.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 18-12-2019

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function New-MSGraphDeviceCode {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('ApplicationId')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId
    )
    #use permissions/scope as assigned to Application
    [string]$Scope = 'https://graph.microsoft.com/.default'
    [string]$Resource = 'https://graph.microsoft.com/'
    $DeviceUri = "https://login.microsoftonline.com/$tenantId/oauth2/devicecode"
    $DeviceBody = @{
        resource  = $Resource
        client_id = $ClientId
        scope     = $Scope
    }

    $MethodProperties = @{
        Method      = 'Post'
        Uri         = $DeviceUri
        Body        = $DeviceBody
        ContentType = 'application/x-www-form-urlencoded'
        ErrorAction = 'Stop'
    }

    try {
        $DeviceCode = Invoke-RestMethod @MethodProperties
        $DeviceCode
        $DeviceCode.user_code | clip
        Start-Process "https://microsoft.com/devicelogin"

    } catch {
        Write-Error "Unable to get device code"
        throw
    }
}