<#
.SYNOPSIS
Modul odswieza zestaw danych (dataset) w ramach wskazanego obszaru roboczego (workspace)

.DESCRIPTION
Wykorzystujac dane logowania w srodowisku raportowym, skrypt uwierzytelnia wskazanego uzytkownika. Nastepnie wysylane jest zapytanie do wskazanego obszaru roboczego o odswiezenie konkretnego zestawu danych. 

.EXAMPLE
Start-DatasetRefresh -UserEmail "jan.nowak@firma.net" -UserPwd $ENV:PBI_PWD -DatasetId "7b96fa0a-8568-489e-a589-2e9aa0a9383f"
#>

function Start-DatasetRefresh {
    [CmdletBinding(
        PositionalBinding=$true)] 

        param(
            [Parameter(Mandatory=$true)]
            [string] $UserEmail,
    
            [Parameter(Mandatory=$true)]
            [string] $UserPwd,
    
            [Parameter(Mandatory=$true)]
            [string] $DatasetId
        )

        [securestring]$secure_pwd = ConvertTo-SecureString $UserPwd -AsPlainText -Force
        [pscredential]$creds = New-Object System.Management.Automation.PSCredential($UserEmail,$secure_pwd)
        $url = "datasets/$DatasetId/refreshes"

        Connect-PowerBIServiceAccount -Credential $creds
        Invoke-PowerBIRestMethod -Url $url -Method Post -Body $DatasetId
}
