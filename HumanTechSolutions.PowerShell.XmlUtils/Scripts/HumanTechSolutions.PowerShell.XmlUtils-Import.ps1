<#
	.SYNOPSIS
	Import HumanTechSolutions.PowerShell.XmlUtils module.
	.DESCRIPTION
	If you use the "Force" parameter it should drop and import the module again.
	.EXAMPLE
	HumanTechSolutions.PowerShell.XmlUtils-Import.ps1
	Import the module. If it already exists it does not do anything.
	.EXAMPLE
	HumanTechSolutions.PowerShell.XmlUtils-Import.ps1 -Force
	Import the module. If it exists it is imported again.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter()]
    [Switch]
    $Force = $false
)


$module = $null
$xmlUtilsPath = (Split-Path $PSCommandPath | Split-Path | Join-Path -ChildPath 'HumanTechSolutions.PowerShell.XmlUtils.psd1' -Resolve)
$moduleManifest = Test-ModuleManifest -Path $xmlUtilsPath
Write-Information "Loading module from: $moduleManifest..."
if($moduleManifest) {
	Write-Debug "Module file: $moduleManifest has found"
	$moduleName = $moduleManifest.Name
	$module = Get-Module -Name $moduleName
	if($module) {
		Write-Information "Module: $moduleName already loaded"
		if($Force) {
			Remove-Module -Name $moduleName
		}
	}
	if(-not $module -or ($module -and $Force)) {
		Import-Module -Name $xmlUtilsPath
	}
	Write-Information "Importing module from file: $xmlUtilsPath"
	Import-Module $xmlUtilsPath
} else {
	Write-Error "Module file: $xmlUtilsPath not found!"
}
return $module