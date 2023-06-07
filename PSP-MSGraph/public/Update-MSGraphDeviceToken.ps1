<#
.SYNOPSIS
Obtain a "refreshed" Device token

.DESCRIPTION
Obtain a "refreshed" Device token
In case your token has expired (>1 hour) you will need to refresh your token instead of request a new one.
This function will assist you with this process.

.PARAMETER ClientId
Provide the ClientID [Application ID] to which you should connect

.PARAMETER TenantId
Provide the Tenant ID to which you should connect

.PARAMETER Scope
Provide the Scope for which your current token has access
You should be able to obtain this data from the current token

.PARAMETER RefreshToken
Provide the refresh token information for your current token

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $TenantId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $DeviceCode = New-MSGraphDeviceCode -ClientId $ClientId -TenantId $TenantId
PS C:\> $DeviceToken = New-MSGraphDeviceToken -ClientId $ClientId -TenantId $TenantId -DeviceCode $DeviceCode.device_code
PS C:\> $NewDeviceToken = Update-MSGraphDeviceToken $ClientId $ClientId -TenantId $TenantId -Scope $DeviceToken.TokenScope -RefreshToken $DeviceToken.TokenRefresh

.NOTES
Name: Update-MSGraphDeviceToken.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 18-12-2019

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function Update-MSGraphDeviceToken {
    [OutputType('PSP_MSGraph_Token')]
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('ApplicationId')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [parameter(Mandatory)]
        [string]$Scope,
        [parameter(Mandatory)]
        [string]$RefreshToken
    )
    [string]$GrantType = 'refresh_token'
    $TokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $TokenBody = @{
        grant_type    = $GrantType
        client_id     = $ClientId
        scope         = $Scope
        refresh_token = $RefreshToken
    }

    $MethodProperties = @{
        Method      = 'Post'
        Uri         = $TokenUri
        Body        = $TokenBody
        ContentType = 'application/x-www-form-urlencoded'
        ErrorAction = 'Stop'
    }

    try {
        $AccessTokenJson = Invoke-WebRequest @MethodProperties
        if ($accesstokenjson.StatusCode -eq 200) {
            $AccessToken = $AccessTokenJson.Content | ConvertFrom-Json
            [PSP_MSGraph_Token]@{
                TokenScope      = $AccessToken.scope
                TokenType       = $AccessToken.token_type
                TokenContent    = $AccessToken.access_token
                TokenExpiration = $AccessToken.expires_in
                TokenRefresh    = $AccessToken.refresh_token
                TokenId         = $AccessToken.id_token
            }
        } else {
            throw "Error: $($AccessTokenJson.StatusCode) $($AccessTokenJson.StatusDescription)"
        }
    } catch {
        $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
        # If not waiting for auth, throw error
        if ($errorMessage.error -ne "authorization_pending") {
            throw
        }
    }
}