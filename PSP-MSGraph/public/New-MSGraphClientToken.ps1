<#
.SYNOPSIS
Obtain a JWT token used to access the MS Graph API based on a client/application code.

.DESCRIPTION
Obtain a JWT token used to access the MS Graph API based on a client/application code.
A JWT token based on a client code provides application access to the MS Graph API.
This uses the permissions/scope as defined in your MS Graph Device Code.

.PARAMETER ClientId
The Client ID [Application ID] to which you should connect.

.PARAMETER ClientSecret
The Client Secret which is defined for your Application.

.PARAMETER TenantId
The Tenant ID to which you should connect.

.PARAMETER Scope
The scope of the token. This parameter is optional and defaults to 'https://graph.microsoft.com/.default'.

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $ClientSecret = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $TenantId = 'cccccccc-cccc-cccc-cccc-cccccccccccc'
PS C:\> $ClientToken = New-MSGraphClientToken -ClientId $ClientId -ClientSecret $ClientSecret -TenantId $TenantId
PS C:\> $ClientToken

TokenScope        : https://graph.microsoft.com/.default
TokenType         : Bearer
TokenContent      : eyJ0eXAiOiJKV8Mqd77TTCIHCp8O7b5BnzkgHZHvk858pgiFQ9u1FfRvzwbN5_01j3fDUD6_fHHhDBhYPH1oDv-c8KtP3MOXn3l8r8VGDdiFkWEIPlD-e9A
TokenExpiration   : 3599
StatusCode        : 200
StatusDescription : OK

.NOTES
Name: New-MSGraphClientToken.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 02-06-2023

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function New-MSGraphClientToken {
    [OutputType('PSP_MSGraph_Token')]
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [Alias('ApplicationId')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory)]
        [Alias('Secret')]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter()]
        [ValidateSet('https://graph.microsoft.com/.default', 'https://management.core.windows.net/.default')]
        [string]$Scope = 'https://graph.microsoft.com/.default'
    )
    begin {
        # # load the class defining the token object
        # . "$PSScriptRoot\classes\PSP_MSGraph_Token.ps1"
    }
    process {
        [string]$GrantType = 'client_credentials'
        $TokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
        $Tokenbody = @{
            client_id     = $ClientId
            client_secret = $ClientSecret
            scope         = $Scope
            grant_type    = $GrantType
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
                $accessToken = $AccessTokenJson.Content | ConvertFrom-Json
                [PSP_MSGraph_Token]@{
                    TokenScope        = $AccessToken.scope
                    TokenType         = $accessToken.token_type
                    TokenContent      = $accessToken.access_token
                    TokenExpiration   = $accessToken.expires_in
                    StatusCode        = $AccessTokenJson.StatusCode
                    StatusDescription = $AccessTokenJson.StatusDescription
                }
            }
            else {
                Write-Error "Invalid Access token"
                throw $_.Exception.Message
            }
        }
        catch {
            Write-Error "Unable to get access token"
            throw $_.Exception.Message
        }
    }
    end {

    }
}
