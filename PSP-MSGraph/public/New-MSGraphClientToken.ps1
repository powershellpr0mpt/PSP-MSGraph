<#
.SYNOPSIS
Obtain a JWT token used to access the MS Graph API based on a client/application code

.DESCRIPTION
Obtain a JWT token used to access the MS Graph API based on a client/application code
A JWT token based on a client code provides application access to the MS Graph API
This uses the permissions/scope as defined in your MS Graph Device Code

.PARAMETER ClientId
Provide the ClientID [Application ID] to which you should connect

.PARAMETER ClientSecret
Provide the Client Secret which is defined for your Application

.PARAMETER TenantId
Provide the Tenant ID to which you should connect

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $ClientSecret = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $TenantId = 'cccccccc-cccc-cccc-cccc-cccccccccccc'
PS C:\> $ClientToken = New-MSGraphClientToken -ClientId $ClientId -ClientSecret $ClientSecret -TenantId $TenantId
PS C:\> $ClientToken

StatusCode        : 200
StatusDescription : OK
TokenType         : Bearer
TokenContent      : eyJ0eXAiOiJKV1QiLCJub47jZSI6IndXUEs3WnVCRHNGSU52NUN2QWI5Q0xIdkllV1AxSkJGRGRyQ1NVWHdDbWciLCJhbGciOiJSUzI1NiIsIng1dCI6InBpVmxsb1FEU01LeGgxbTJ5Z3FHU1ZkZ0ZwQSIsImtpZCI6InBpVmxsb1FEU01LeGgxbTJ5Z3FHU1
                    ZkZ0ZwQSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9mNDMwNzVlZC0xMjNmLTRlZjgtODRjMi04Yzk5YmRjODUzMDQvIiwiaWF0IjoxNTc2NzQ5MjQ4LCJuYmYiOjE1NzY3NDk
                    yNDgsImV4cCI6MTU3Njc1MzE0OCwiYWlvIjoiNDJWZ1lGZ2dzWCtMR2I4Lys1cjdpOWNsYUNZL0FRQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJQU1AtR3JhcGgtQVBJIiwiYXBwaWQiOiJkZGJjZWU0OC05NDQxLTQ4NmMtOTg2MC1hMGQ2NWJhNmZlY2YiLCJhc
                    HBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9mNDMwNzVlZC0xMjNmLTRlZjgtODRjMi04Yzk5YmRjODUzMDQvIiwib2lkIjoiNDBhZGZiZjgtZTFlNi00ZTNmLWFlMjgtNTMwNGI2ODZmMDllIiwicm9sZXMiOlsiR3JvdXAuUmV
                    hZC5BbGwiLCJEaXJlY3RvcnkuUmVhZC5BbGwiLCJEZXZpY2VNYW5hZ2VtZW50U2VydmljZUNvbmZpZy5SZWFkV3JpdGUuQWxsIiwiRGV2aWNlTWFuYWdlbWVudENvbmZpZ3VyYXRpb24uUmVhZC5BbGwiLCJNYWlsLlJlYWQiLCJQb2xpY3kuUmVhZC5BbGwiX
                    Swic3ViIjoiNDBhZGZiZjgtZTFlNi00ZTNmLWFlMjgtNTMwNGI2ODZmMDllIiwidGlkIjoiZjQzMDc1ZWQtMTIzZi00ZWY4LTg0YzItOGM5OWJkYzg1MzA0IiwidXRpIjoiX19LaWZaZ3l1MG1Ja0JLb0NxNFNBQSIsInZlciI6IjEuMCIsInhtc190Y2R0Ijo
                    xNDM3NzMwNzk1fQ.nQM3PQozQqX8A0C38RO8w0lDDdfZXjof8KWq-UrBF6gIpQO7NXuNhAsJCd_G9WhgEgc6IBQF1Fq99aESga07PmQhZZBvRVxO8CFdevsuKwpe7-952dbVQdqS_O13bFhTFTk1IpBQE2g4eOU5m_fd-DjZmTCTCIurmVIM533Cg32olc3Dy0
                    TdwIsRUj52vcEQGcTt17hRq84p7qdtUMEwYVIJ1t1Ieol-7zrANuubOjrd5RWYplkAysVmi73vftv39QuZ60z2co57QwjEYIhMRxa4mFKf-UBRk_pYo8GePEOiWlQgLyGqQ1F5Zqyv2kSZPqg2ESLkcFpMXN8Bycyl8g
TokenExpiration   : 3599

.NOTES
Name: New-MSGraphClientToken.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 18-12-2019

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function New-MSGraphClientToken {
    [OutputType('PSP-MSGraph-Token')]
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
        [string]$TenantId
    )
    [string]$Resource = 'https://graph.microsoft.com/.default'
    [string]$GrantType = 'client_credentials'
    $TokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $Tokenbody = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = $Resource
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
        $accessTokenJson = Invoke-WebRequest @MethodProperties
        if ($accessTokenJson.StatusCode -eq 200) {
            $accessToken = $accessTokenJson.Content | ConvertFrom-Json
            [PSCustomObject]@{
                PSTypeName        = 'PSP-MSGraph-Token'
                StatusCode        = $accessTokenJson.StatusCode
                StatusDescription = $accessTokenJson.StatusDescription
                TokenType         = $accessToken.token_type
                TokenContent      = $accessToken.access_token
                TokenExpiration   = $accessToken.expires_in
            }
        } else {
            Write-Error "Invalid Access token"
        }
    } catch {
        Write-Error "Unable to get access token"
        throw
    }
}
