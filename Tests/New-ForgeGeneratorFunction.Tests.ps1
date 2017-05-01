Set-PSDebug -Strict
$ErrorActionPreference = "Stop"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
if (!(Get-Module Forge)) {
    Import-Module "Forge"
}
. "$PSScriptRoot\..\Forge.Generator\New-ForgeGenerator.ps1"
. "$PSScriptRoot\..\Forge.Generator\$sut"

Describe "New-ForgeGeneratorFunction" {
    $ModuleName = "TestModule"
    $FunctionName = "TestFunction"
    $TestBase   = Setup -Dir $ModuleName -Passthru

    Context "-Name $FunctionName -Parameter a,b,c" {
        BeforeEach {
            $FunctionName = "TestFunction1"
            $FunctionPath = Join-Path $ModulePath "$FunctionName.ps1"
            $FunctionTestsPath = Join-Path Tests "$FunctionName.Tests.ps1"
        }
        it "should generate a function file with parameters" {

            New-ForgeGeneratorFunction -Name $FunctionName -Parameter a1,b1,c1
            $FunctionPath     | Should Exist
            $FunctionPath     | Should Contain '\$a1,'
            $FunctionPath     | Should Contain '\$b1,'
            $FunctionPath     | Should Contain '\$c1'
            $FunctionTestsPath | Should Exist
        }

        it "should fail if 'Name' parameter is in the list of parameters" {
            {
                New-ForgeGeneratorFunction -Name $FunctionName -Parameter a1,Name,b1,c1
            } | Should Throw "Parameter 'Name' is always added"
        }        

        it "should fail if 'Path' parameter is in the list of parameters" {
            {
                New-ForgeGeneratorFunction -Name $FunctionName -Parameter a1,Path,b1,c1
            } | Should Throw "Parameter 'Path' is always added"
        }        
    }

    Context "-Name $FunctionName" {
        It "should generate a function file" {
            $FunctionPath | Should Exist
            $FunctionPath | Should Contain "function $FunctionName"
        }

        It "should generate a test file" {
            $FunctionTestsPath | Should Exist
            $FunctionTestsPath | Should Contain "Describe `"$FunctionName`""
        }

        It "should add the function to the exported ones" {
            $PsdPath = Join-Path $ModulePath "$ModuleName.psd1"
            (Import-PowerShellDataFile $PsdPath)["FunctionsToExport"] | Should Be @($FunctionName)
        }

        BeforeEach {
            New-ForgeGeneratorFunction -Name $FunctionName -Description BLABLA
            $FunctionPath = (Join-Path $ModulePath "$FunctionName.ps1") 
            $FunctionTestsPath = (Join-Path Tests "$FunctionName.Tests.ps1")
        }
    }

    Context "Incorrect directory structure: no module dir" {
        It "should fail if '<ModuleName>' directory does not exist" {
            Remove-Item -Recurse $ModulePath
            { 
                New-ForgeGeneratorFunction -Name $FunctionName
            } | Should Throw "Module directory '$ModulePath' does not exist"
        }
    }

    Context "Incorrect directory structure: no Tests dir" {
        It "should fail if 'Tests' directory does not exist" {
            Remove-Item $TestsPath
            { 
                New-ForgeGeneratorFunction -Name $FunctionName
            } | Should Throw "Test directory 'Tests' does not exist"
        }
    }

    BeforeEach {
        $Script:OldLocation = Get-Location
        Set-Location $TestBase

        $ModulePath = New-Item (Join-Path $TestBase $ModuleName) -Type Container
        $TestsPath  = New-Item (Join-path $TestBase Tests) -Type Container
        New-ModuleManifest "$ModuleName/$ModuleName.psd1"
    }

    AfterEach {
        Set-Location $Script:OldLocation
        Remove-Item -Recurse $TestBase/*
   }
}