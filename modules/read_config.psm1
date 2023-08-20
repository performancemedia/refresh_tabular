<#
.SYNOPSIS
Odczytuje i zapisuje zmienne srodowiskowe na podstawie pliku .config

.DESCRIPTION
Na podstawie prawidlowo uzupelnionego pliku .env w notacji <klucz>:<wartosc>, skrypt wczytuje kazda pozycje jako zmienna srodowiskowa, do ktorej mozna sie odwolywac. Dla zapewnienia prawidlowego odczytu i zapisu z, najlepiej trzymac sie wymienionej wyzej konwencji, unikajac znakow specjalnych w nazwach zmiennych

.EXAMPLE
Read-ConfigFile -DotenvPath "./folder/.config"

#>

function Read-ConfigFile {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string] $ConfigFilePath
    )

    Get-Content $ConfigFilePath | Foreach-Object {
        $Name, $Value = $_.split(':')
        if ([string]::IsNullOrWhiteSpace($name) -and $name.Contains('#')) {
            continue
          }

        Set-Content ENV:\$Name $Value
    }
}