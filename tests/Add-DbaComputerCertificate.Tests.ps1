﻿$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        $paramCount = 8
        $defaultParamCount = 13
        [object[]]$params = (Get-ChildItem function:\Add-DbaComputerCertificate).Parameters.Keys
        $knownParameters = 'ComputerName','Credential','Password','Certificate','Path','Store','Folder','EnableException'
        It "Should contain our specific parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {
    Context "Certificate is added properly" {
        $results = Add-DbaComputerCertificate -Path $script:appveyorlabrepo\certificates\localhost.crt -Confirm:$false

        It "Should show the proper thumbprint has been added" {
            $results.Thumbprint | Should Be "29C469578D6C6211076A09CEE5C5797EEA0C2713"
        }

        It "Should be in LocalMachine\My Cert Store" {
            $results.PSParentPath | Should Be "Microsoft.PowerShell.Security\Certificate::LocalMachine\My"
        }

        Remove-DbaComputerCertificate -Thumbprint 29C469578D6C6211076A09CEE5C5797EEA0C2713 -Confirm:$false
    }
}