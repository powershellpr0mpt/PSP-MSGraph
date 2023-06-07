<#
.SYNOPSIS
Obtain a JWT token used to access the MS Graph API based on a device code
Save this token to CliXML in case a refresh might be needed (>1 hour)

.DESCRIPTION
Obtain a JWT token used to access the MS Graph API based on a device code.
This function supports MFA and uses the permissions/scope as defined in your MS Graph Device Code.
The token is saved to CliXML in case a refresh might be needed (>1 hour).

.PARAMETER ClientId
The Client ID (Application ID) to which you should connect.

.PARAMETER TenantId
The Tenant ID to which you should connect.

.PARAMETER DeviceCode
The Device Code token which you've received.
You can generate this using the New-MSGraphDeviceCode cmdlet.

.OUTPUTS
Returns a PSP_MSGraph_Token object with the following properties:
- TokenScope: The scope of the token.
- TokenType: The type of the token.
- TokenContent: The content of the token.
- TokenExpiration: The expiration time of the token.
- TokenRefresh: The refresh token.
- TokenId: The ID token.
- StatusCode: The status code of the response.
- StatusDescription: The status description of the response.

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $TenantId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $DeviceCode = New-MSGraphDeviceCode -ClientId $ClientId -TenantId $TenantId
PS C:\> $DeviceToken = New-MSGraphDeviceToken -ClientId $ClientId -TenantId $TenantId -DeviceCode $DeviceCode.device_code
PS C:\> $DeviceToken

TokenScope      : profile openid email https://graph.microsoft.com//Application.Read.All https://graph.microsoft.com//Policy.Read.All https://graph.microsoft.com//Policy.ReadWrite.ConditionalAccess
                  https://graph.microsoft.com//User.Read
TokenType       : Bearer
TokenContent    : eyJ0eXAiOiJKV8Mqd77TTCIHCp8O7b5BnzkgHZHvk858pgiFQ9u1FfRvzwbN5_01j3fDUD6_fHHhDBhYPH1oDv-c8KtP3MOXn3l8r8VGDdiFkWEIPlD-e9A
TokenExpiration : 3599
TokenRefresh    :
TokenId         :


.NOTES
Name: New-MSGraphDeviceToken.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 02-06-2023

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function New-MSGraphDeviceToken {
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
        [Parameter(Mandatory)]
        [Alias('Code')]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceCode
    )
    begin {
        # # load the class defining the token object
        # . "$PSScriptRoot\classes\PSP_MSGraph_Token.ps1"
    }
    process {
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
            $AccessTokenJson = Invoke-WebRequest @MethodProperties
            if ($AccessTokenJson.StatusCode -eq 200) {
                $AccessToken = $AccessTokenJson.Content | ConvertFrom-Json

                [PSP_MSGraph_Token]@{
                    TokenScope        = $AccessToken.scope
                    TokenType         = $AccessToken.token_type
                    TokenContent      = $AccessToken.access_token
                    TokenExpiration   = $AccessToken.expires_in
                    TokenRefresh      = $AccessToken.refresh_token
                    TokenId           = $AccessToken.id_token
                    StatusCode        = $accessTokenJson.StatusCode
                    StatusDescription = $accessTokenJson.StatusDescription
                }
            }
        }
        catch {
            $ErrorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
            # If not waiting for auth, throw error
            if ($ErrorMessage.Error -ne "Authorization_Pending") {
                throw
            }
        }
    }
    end {

    }
}