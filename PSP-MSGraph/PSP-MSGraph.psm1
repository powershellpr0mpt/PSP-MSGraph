<#
    .DESCRIPTION
        Loader file for functions in PSP-MSGraph module.

    .NOTES

        Name: PSP-MSGraph
        Author: Robert Prust
        Version: 0.1.0
        Blog: http://powershellpr0mpt.com

    .LINK
        http://powershellpr0mpt.com
#>

[cmdletbinding()]
param()
Write-Verbose $PSScriptRoot

#Import classes
Write-Verbose 'Import Classes'
class PSP_MSGraph_Token {
    [string]$TokenScope
    [string]$TokenType
    [string]$TokenContent
    [Int64]$TokenExpiration
    [object]$TokenRefresh
    [object]$TokenId
    [int]$StatusCode
    [string]$StatusDescription
}

#Function Loader
Write-Verbose 'Import Private Functions'
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Write-Verbose 'Import Public Functions'
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($Function in @($Public + $Private)) {
    Try {
        . $Function.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($Function.FullName): $_"
    }
}

### Export Public functions
Export-ModuleMember -Function $Public.Basename

