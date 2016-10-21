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
function New-ForgeGenerator {
    <#
    .SYNOPSIS
        Generates a new module.

    .DESCRIPTION
        Generates a new skeleton module based on the arguments passed to the function.

    .EXAMPLE
        New-ForgeModule -Name MyModule

    .PARAMETER Name
        The name of the new module.

    .PARAMETER Path
        The path where the new module is created.

    .PARAMETER Description
        Description of the generator.   

    .PARAMETER License
        License to add to the generator.

        Allowed values are:
        - Apache : Apache License
        - MIT : MIT License   

    .PARAMETER Author
        Name to use as module author.

    .PARAMETER Email
        Email to use for the generator.

    .PARAMETER Git
        If true add a .gitignore file to the generator.   
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [String]$Path = "$Name",

        [String]$Description = "$Name module",

        [ValidateSet('', 'Apache', 'MIT')]
        [String]$License,

        [String]$Author,

        [String]$Email,

        [Switch]$Git
    )
    Begin {
        Initialize-ForgeContext -SourceRoot (Join-Path $PSScriptRoot "Templates") `
            -DestinationPath $Path
    }
    Process {
        if (!$PSCmdlet.ShouldProcess($Name, "Create forge generator module")) {
            return
        }
        $Author = Get-ValueOrGitOrDefault $Author "user.user" "John Doe"
        $Email  = Get-ValueOrGitOrDefault $Email "user.email" "JohnDoe@example.com"
        $CopyrightYear = Get-Date -UFormat %Y

        Set-ForgeBinding @{
            Name          = $Name
            Description   = $Description
            Author        = $Author
            Email         = $Email
            CopyrightYear = $CopyrightYear
        }

        New-ForgeModule -Name $Name -Path (Get-ForgeContext).DestinationPath `
            -Description $Description -Email $Email -Author $Author -License $License `
            -Git:$Git

        New-ForgeDirectory -Destination (Join-Path $Name "Templates") > $Null
        Copy-ForgeFile -Source "README.md"
    }
}