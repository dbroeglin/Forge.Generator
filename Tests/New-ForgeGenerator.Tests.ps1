Set-PSDebug -Strict
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
if (!(Get-Module "Forge.Module")) {
    Import-Module "Forge.Module"
}
. "$PSScriptRoot\..\Forge.Generator\$sut"

Describe "New-ForgeGenerator" {
    $Name = "TestGenerator"
    $TestPath = Join-Path $TestDrive $Name 
    $Params = @{ 
        Name   = $Name
        Path   = $TestPath
        Author = "Jane Doe"
    }

    Context "-Name $Name -Path... "{
        New-ForgeGenerator @Params 

        It "should create a project directory" {
            $TestPath | Should Exist
        }

        It "should create a README.md" {
            "$TestPath\README.md" | Should Exist
            "$TestPath\README.md" | Should Contain "# TestGenerator Generator"
        }

        It "should create a module directory" {
            "$TestPath\$Name" | Should Exist
        }

        It "should create a module file" {
            "$TestPath\$Name\$Name.psm1" | Should Exist
            "$TestPath\$Name\$Name.psm1" | Should Contain "Set-StrictMode"
        }

        It "should create a manifest file" {
            "$TestPath\$Name\$Name.psd1" | Should Exist
            "$TestPath\$Name\$Name.psd1" | Should Contain "Jane Doe"
        }

        It "should create a test directory" {
            "$TestPath\Tests" | Should Exist
        }

        It "should create manifest tests" {
            "$TestPath\Tests\Manifest.Tests.ps1" | Should Exist
            "$TestPath\Tests\Manifest.Tests.ps1" | Should Contain "Describe '$Name Manifest"
        }
    }

    Context "-License Apache" {
        New-ForgeGenerator @Params -License Apache

        It "should create an Apache LICENSE file" {
            "$TestPath\LICENSE.txt" | Should Exist
            "$TestPath\LICENSE.txt" | Should Contain "Apache License"            
            "$TestPath\LICENSE.txt" | Should Contain "$(Get-Date -UF %Y) Jane Doe"
        }
    }

    Context "-License MIT" {
        New-ForgeGenerator @Params -License MIT

        It "should create a MIT LICENSE file" {
            "$TestPath\LICENSE.txt" | Should Exist
            "$TestPath\LICENSE.txt" | Should Contain "MIT License"
            "$TestPath\LICENSE.txt" | Should Contain "$(Get-Date -UF %Y) Jane Doe"
        }
    }

    Context "-Git" {
        New-ForgeGenerator @Params -Git

        It "should create a .gitignore file" {
            "$TestPath\.gitignore" | Should Exist
            "$TestPath\.gitignore" | Should Contain "https://github.com/github/gitignore "
        }
    }    
}