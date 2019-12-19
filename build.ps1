[cmdletbinding()]
param(
    [ValidateSet('Default', 'Build', 'Analyze', 'Test', 'WinZip')]
    $Task = 'Default'
)

Write-Host "Importing Modules:" -ForegroundColor Yellow
$Modules = @('Psake', 'BuildHelpers', 'Pester', 'PSScriptAnalyzer', 'PSDeploy')


function Resolve-Module {
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name
    )

    Process {
        foreach ($ModuleName in $Name) {
            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"

            if ($Module) {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -lt $GalleryVersion) {

                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"

                    Install-Module -Name $ModuleName -Force -Scope CurrentUser -SkipPublisherCheck
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                }
                else {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            }
            else {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                Install-Module -Name $ModuleName -Force -Scope CurrentUser -SkipPublisherCheck
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        }
    }
}
# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Resolve-Module $Modules

Write-Host "Completed Importing Modules`r`n" -ForegroundColor Green

Push-Location $PSScriptRoot
Write-Verbose "Cleaning current Build variables"
Get-ChildItem -Path env:\bh* | Remove-Item
Write-Verbose "Setting Build Variables"
Set-BuildEnvironment

Write-Host "Executing PSake Build`r`n" -ForegroundColor Green

Invoke-Psake -buildFile .\psake.ps1 -properties $PSBoundParameters -noLogo -taskList $Task
exit ( [int]( -not $psake.build_success ) )
