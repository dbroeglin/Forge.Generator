<#
Copyright 2016 Dominique Broeglin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>
function New-ForgeGeneratorFunction {
    <#
    .SYNOPSIS
        Creates a new generator function in a generator module.

    .DESCRIPTION
        Creates a new skeleton generator function based on the arguments passed to the function.

    .EXAMPLE
        New-ForgeGeneratorFunction -Name MyFunction

    .PARAMETER Name
        The name of the new function.
    
    .PARAMETER Path
        The path where the function should be generated.

        Default: .\

    .PARAMETER ModuleName
        The name of the module in which the function is generated if it is not the
        same as the parent directory name.

    .PARAMETER Parameter
        An array of parameter names to generate for the new function.

    .PARAMETER DESCRIPTION
        A very short description of the generated result. Should make sense in a
        sentence like "<%= $Name %> generates <%= $Description %>"

        Default: "TODO"
    #>
    [CmdletBinding(ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [String]$Path = ".\",

        [String]$ModuleName,

        [String[]]$Parameter = @(),

        [String]$Description = "TODO"
    )
    Begin {
        Initialize-ForgeContext -SourceRoot (Join-Path $PSScriptRoot "Templates") `
            -DestinationPath $Path

        if (-not $ModuleName) {
            $ModuleName = Split-Path -Leaf (Get-ForgeContext).DestinationPath
        }
    }
    Process {
        $ModulePath = Join-Path (Get-ForgeContext).DestinationPath $ModuleName
        $PsdPath = Join-Path $ModulePath "$ModuleName.psd1"
        if (-not (Test-Path -PathType Container $ModulePath)) {
            throw "Module directory '$ModulePath' does not exist"
        }
        if (-not (Test-Path -PathType Container 'Tests')) {
            throw "Test directory 'Tests' does not exist"
        }
        if (-not (Test-Path -PathType Leaf $PsdPath)) {
            throw "PSD file '$PsdPath' does not exist"
        }
        if ($Parameter.Contains('Name')) {
            throw "Parameter 'name' is always added to the generated command. " +
              "It should not be added to the Parameter list."
        }


        Set-ForgeBinding @{
            Name        = $Name
            ModuleName  = $ModuleName
            Parameters  = $Parameter
            Description = $Description
        }

        $FunctionFilename = "$Name.ps1"
        $TestsFilename    = "$Name.Tests.ps1"
        Copy-ForgeFile -Source "Function.ps1" -Dest (Join-Path $ModuleName $FunctionFilename)
        Copy-ForgeFile -Source "Function.Tests.ps1" -Dest (Join-Path Tests $TestsFilename)
        Update-ModuleManifest -Path $PsdPath -FunctionsToExport (
            (Import-PowerShellDataFile $PsdPath)["FunctionsToExport"] + $Name
        )
    }
}