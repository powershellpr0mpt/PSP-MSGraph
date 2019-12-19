<#
.SYNOPSIS
Obtain a JWT token used to access the MS Graph API based on a device code
Save this token to CliXML in case a refresh might be needed (>1 hour)

.DESCRIPTION
Obtain a JWT token used to access the MS Graph API based on a device code
A JWT token based on a device code provides delegated access to the MS Graph API, allowing extra actions over a client/application code
This supports MFA and uses the permissions/scope as defined in your MS Graph Device Code
Save this token to CliXML in case a refresh might be needed (>1 hour

.PARAMETER ClientId
Provide the ClientID [Application ID] to which you should connect

.PARAMETER TenantId
Provide the Tenant ID to which you should connect

.PARAMETER Code
Provide the Device Code token which you've received.
You can generate this using the New-MSGraphDeviceCode cmdlet.

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $TenantId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $DeviceCode = New-MSGraphDeviceCode -ClientId $ClientId -TenantId $TenantId
PS C:\> $DeviceToken = New-MSGraphDeviceToken -ClientId $ClientId -TenantId $TenantId -DeviceCode $DeviceCode.device_code
PS C:\> $DeviceToken

TokenScope      : profile openid email https://graph.microsoft.com//Application.Read.All https://graph.microsoft.com//Policy.Read.All https://graph.microsoft.com//Policy.ReadWrite.ConditionalAccess
                  https://graph.microsoft.com//User.Read
TokenType       : Bearer
TokenContent    : eyJ0eXAiOiJKV1QiLCJub25jZSI6Im8zM3FqT0w5c09mWjBqZmplQlFYOW8tdjJjd29vZDBTb05vU0ViSWhjOFUiLCJhbGciOiJSUzI1NiIsIng1dCI5InBpVmxsb1FEU01LeGgxbTJ5Z3FHU1ZkZ0ZwQSIsImtpZCI6InBpVmxsb1FEU01LeGgxbTJ5Z3FHU1Zk
                  Z0ZwQSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvZjQzMDc9ZWQtMTIzZi00ZWY4LTg0YzItOGM5OWJkYzg1MzA0LyIsImlhdCI6MTU3Njc0ODU3MCwibmJmIjoxNTc2NzQ4NTc
                  wLCJleHAiOjE1NzY3NTI0NzAsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJBVlFBcS84TkFBQUFFSWdQUFhGWDJLZ2pBYnA0Zzh3b3lIbi9KMTRwK0lLS0dTR3hYMHd3UVJabmxPWURMMExtem1HVXFibklXTFpTNWNMUCsycFdjOG9hRXF5NUZScVZYRGtYQnp
                  WMUdSZXJLWlJ4RUlNMnVYYz0iLCJhbXIiOlsicHdkIiwibWZhIl0sImFwcF9kaXNwbGF5bmFtZSI6IlBTUC1HcmFwaC1BUEkiLCJhcHBpZCI6ImRkYmNlZTQ4LTk0NDEtNDg2Yy05ODYwLWEwZDY1YmE2ZmVjZiIsImFwcGlkYWNyIjoiMCIsImZhbWlseV9uYW1
                  lIjoiUHLDvHN0IiwiZ2l2ZW5fbmFtZSI6IlJvYmVydCIsImlwYWRkciI6Ijg1LjE0Ny4xMjkuMTY2IiwibmFtZSI6IlJvYmVydCBQcsO8c3QiLCJvaWQiOiIzYjM1ZDNjOC1mZmVhLTQzMjUtYjUxNC1hOWVlOTEyNDA0NWYiLCJwbGF0ZiI6IjMiLCJwdWlkIjo
                  iMTAwMzNGRkY5MkUwMzA4NSIsInNjcCI6IkFwcGxpY5F0aW9uLlJlYWQuQWxsIFBvbGljeS5SZWFkLkFsbCBQb2xpY3kuUmVhZFdyaXRlLkNvbmRpdGlvbmFsQWNjZXNzIFVzZXIuUmVhZCBwcm9maWxlIG9wZW5pZCBlbWFpbCIsInNpZ25pbl9zdGF0ZSI6WyJ
                  rbXNpIl0sInN1YiI6ImhMWlZucUkwZUNyeEtVdDV1M0dHZzNPZGc1RFhMNVZtVlNfWVFrOHgyTTgiLCJ0aWQiOiJmNDMwNzVlZC0xMjNmLTRlZjgtODRjMi04Yzk5YmRjODUzMDQiLCJ1bmlxdWVfbmFtZSI6InJvYmVydEBwb3dlcnNoZWxscHIwbXB0LmNvbSI
                  sInVwbiI6InJvYmVydEBwb3dlcnNoZWxscHIwbXB0LmNvbSIsInV0aSI6ImVqdHRmb1I0MTBTcmpJTFVjUVFSQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbImU4NjExYWI4LWMxODktNDZlOC05NGUxLTYwMjEzYWIxZjgxNCIsIjYyZTkwMzk0LTY5ZjUtNDIzNy0
                  5MTkwLTAxMjE3NzE0NWUxMCIsIjE5NGFlNGNiLWIxMjYtNDBiMi1iZDViLTYwOTFiMzgwOTc5ZCJdLCJ4bXNfc3QiOnsic3ViIjoiTnFJbTQwZlBwanI0RDZOMGRFNDVPeDJiZmN3WFRIRm9FT0lwaDhjVHY4byJ9LCJ4bXNfdGNkdCI6MTQzNzczMDc5NX0.zfe
                  770KNCcx3bGbtgF-hBsZIuqZ06ciGuN9xDVgGtivJrRB4elRv2J7gc3oex3q74HmA0bCcpCcf_5QlBHA1r05-TvjjBGJr8dIa4h-9VhLKuQTQPH6nGaOQrqElgkV65iltCyoYTNtNjjGyDDeB8pGC8Mqd77TTCIHCp8O7b5B7ZC_O98m-6JHTPBhBoFy1n0cR21A
                  6uIYLXk2jC8XAEp3ndg3xiBuDbec1G9rD-82jJYikj8s0NwbMtm2qj8tnzkgHZHvk858pgiFQ9u1FfRvzwbN5_01j3fDUD6_fHHhDBhYPH1oDv-c8KtP3MOXn3l8r8VGDdiFkWEIPlD-e9A
TokenExpiration : 3599
TokenRefresh    :
TokenId         :


.NOTES
Name: New-MSGraphDeviceToken.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 18-12-2019

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function New-MSGraphDeviceToken {
    [OutputType('PSP-MSGraph-Token')]
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('ApplicationId')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [Alias('Code')]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceCode
    )
    [string]$GrantType = 'device_code'
    $TokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $TokenBody = @{
        grant_type = $GrantType
        client_id  = $ClientId
        code       = $DeviceCode
    }

    $MethodProperties = @{
        Method      = 'Post'
        Uri         = $TokenUri
        Body        = $TokenBody
        ContentType = 'application/x-www-form-urlencoded'
        ErrorAction = 'Stop'
    }

    try {
        $AccessToken = Invoke-RestMethod @MethodProperties

        [PSCustomObject]@{
            PSTypeName      = 'PSP-MSGraph-Token'
            TokenScope      = $AccessToken.scope
            TokenType       = $AccessToken.token_type
            TokenContent    = $AccessToken.access_token
            TokenExpiration = $AccessToken.expires_in
            TokenRefresh    = $AccessToken.refresh_token
            TokenId         = $AccessToken.id_token
        }
    } catch {
        $ErrorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
        # If not waiting for auth, throw error
        if ($ErrorMessage.Error -ne "Authorization_Pending") {
            throw
        }
    }
}