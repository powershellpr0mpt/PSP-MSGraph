<#
.SYNOPSIS
Query the Microsoft Graph API to obtain all kinds of data from your tenant.
Requires a Client or Device token to function

.DESCRIPTION
Query the Microsoft Graph API to obtain all kinds of data from your tenant.
Requires a Client or Device token to function, which can  be obtained using either New-MSGraphClientToken or New-MSGraphDeviceToken

.PARAMETER Token
Provide the Client or Device token as obtained by New-MSGraphClientToken or New-MSGraphDeviceToken

.PARAMETER Uri
Provide the URI you want to connect to

.PARAMETER Body
Provide the body you want to POST or UPDATE.
Normally in JSON format, depending on API endpoint

.PARAMETER Method
Provide the API method you want to use.
Acceptable values are:
    Get
    Post
    Delete
    Put
    Patch
    Options

.EXAMPLE
PS C:\> $ClientId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
PS C:\> $ClientSecret = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
PS C:\> $TenantId = 'cccccccc-cccc-cccc-cccc-cccccccccccc'
PS C:\> $ClientToken = New-MSGraphClientToken -ClientId $ClientId -ClientSecret $ClientSecret -TenantId $TenantId
PS C:\> $GraphBetaUri = 'https://graph.microsoft.com/beta/'
PS C:\> $ConditionalAccessAUri = "{0}conditionalAccess/policies" -f $GraphBetaUri

## Get All conditional access policies using client token
PS C:\> $CApolicies = Invoke-MSGraphMethod -Token $ClientToken -Uri $ConditionalAccessAUri -Method Get
PS C:\> $CApolicies

id               : 5a7038d6-1435-4ac7-88ec-e40b899e1d34
displayName      : 001-BLOCK-Legacy Authentication
createdDateTime  : 10/12/2019 19:58:09
modifiedDateTime :
state            : enabledForReportingButNotEnforced
sessionControls  :
conditions       : @{signInRiskLevels=System.Object[]; clientAppTypes=System.Object[]; platforms=; locations=; deviceStates=; applications=; users=}
grantControls    : @{operator=OR; builtInControls=System.Object[]; customAuthenticationFactors=System.Object[]; termsOfUse=System.Object[]}

id               : 5c9ab59e-6f12-42d4-9a1d-30b88533fea8
displayName      : 002-BLOCK-High-risk Sign-ins
createdDateTime  : 10/12/2019 19:58:09
modifiedDateTime :
state            : enabledForReportingButNotEnforced
sessionControls  :
conditions       : @{signInRiskLevels=System.Object[]; clientAppTypes=System.Object[]; platforms=; locations=; deviceStates=; applications=; users=}
grantControls    : @{operator=OR; builtInControls=System.Object[]; customAuthenticationFactors=System.Object[]; termsOfUse=System.Object[]}


.NOTES
Name: Invoke-MSGraphMethod.ps1
Author: Robert Prüst
Module: PSP-MSGraph
DateCreated: 04-12-2019
DateModified: 18-12-2019

.LINK
https://powershellpr0mpt.com
https://github.com/powershellpr0mpt
#>

function Invoke-MSGraphMethod {
    [Cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('PSP_MSGraph_Token')]$Token,
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        [Parameter()]
        $Body,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get', 'Post', 'Delete', 'Put', 'Patch', 'Options')]
        $Method,
        [switch]$AdvancedFilter
    )
    begin {
        $AuthHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = ("{0} {1}" -f $($Token.TokenType), $($Token.TokenContent))
            'ExpiresOn'     = $Token.TokenExpiration
        }
        if ($AdvancedFilter){
            $AuthHeader.ConsistencyLevel = 'eventual'
        }
        $QueryResults = @()
    }

    process {
        Clear-Variable -Name 'Results', 'StatusCode' -ErrorAction SilentlyContinue

        do {
            try {
                Write-Verbose "$Uri"
                Write-Verbose "$Body"
                $RestProperties = @{
                    Headers         = $AuthHeader
                    Uri             = $Uri
                    UseBasicParsing = $true
                    Method          = $Method
                    ContentType     = $($AuthHeader.'Content-Type')
                    ErrorAction     = 'Stop'
                }

                if ($Method -match "Post|Delete|Put|Patch") {
                    $RestProperties.Body = $Body
                }
                do {
                    $Results = Invoke-RestMethod @RestProperties

                    if ($Results.value) {
                        $QueryResults += $Results.value
                    } else {
                        $QueryResults += $Results
                    }

                    $Uri = $Results.'@odata.nextlink'
                } until (!($Uri))

                $StatusCode = $Results.StatusCode
            } catch {
                $StatusCode = $_.Exception.Response.StatusCode.value__

                if ($StatusCode -eq 429) {
                    Write-Warning "Got throttled by Microsoft. Sleeping for 45 seconds..."
                    Start-Sleep -Seconds 45
                } else {
                    Write-Error $_.Exception
                }
            }
        } while ($StatusCode -eq 429)
        $QueryResults
    }
}