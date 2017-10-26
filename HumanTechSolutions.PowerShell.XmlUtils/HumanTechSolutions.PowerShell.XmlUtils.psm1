# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#HumanTechSolutions.PowerShell.XmlUtils.psm1
#Module file for HumanTechSolutions.PowerShell.XmlUtils

#Set path to find functions
$functionRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve

#Ignore some functions to import
$doNotImport = @{ }

#Import functions by doing dot source magic
Get-ChildItem -Path $functionRoot -Filter '*.ps1' | 
                    Where-Object { -not $doNotImport.Contains($_.Name) } |
                    ForEach-Object {
                        Write-Verbose ("Importing function {0}." -f $_.FullName)
                        . $_.FullName | Out-Null
					}

$moduleName = 'HumanTechSolutions.PowerShell.XmlUtils.psd1'

$module = Test-ModuleManifest -Path (Join-Path -Path $PSScriptRoot -ChildPath $moduleName -Resolve)
if( -not $module )
{
    return
}

Export-ModuleMember -Alias '*' -Function ([string[]]$module.ExportedFunctions.Keys)