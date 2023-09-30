<#
.SYNOPSIS
Modul weryfikuje, czy wskazane moduly sa zainstalowane.

.DESCRIPTION
Weryfikuje, czy na srodowisku deweloperskim zainstalowane sa moduly niezbedne do uruchomienia danego skryptu.
W przypadku, gdy modul nie zostanie odnaleziony, rozpoczyna jego instalacje. Zastosowany parametr
'-Scope CurrentUser' pozwala na instalacje modulu nawet wtedy, gdy uzytkowane konto nie posiada 
uprawnien administratora.

.PARAMETER Modules
Lista modulow, ktorych instalacje chcemy zweryfikowac. Argumenty wprowadzane sa nastepujaco:
@('Modul_1','Modul_2')

W przypadku tylko jednego modulu, mozna wprowadzic nazwe bez deklarowania listy:
'Modul_1'

.EXAMPLE
Jezeli planujemy wykorzystac w naszym skrypcie z modulow 'SqlServer' i 'SimplySql', funkcje
wywolujemy ponizszym sposobem:

...
Start-Verification -Modules @('SqlServer','SimplySql')
...

.OUTPUTS
Uzytkownikowi zwrocona zostanie informacja dotyczaca stanu weryfikowanego modulu. Jezeli nie jest
on zainstalowany, funkcja od razu rozpocznie jego instalacje, wyswietlajac przebieg w konsoli.

#>

function Start-ModuleVerification {
  [CmdletBinding()]

  param(
    [string[]]$Modules
  )

  Write-Host "Checking modules..."
  Start-Sleep -Seconds 2

  foreach ($module in $Modules) {
    Start-Sleep -Seconds 2

    if (Get-Module -ListAvailable -Name $module) {
      Write-Host "$module is already installed"
    }

    else {
      Write-Host "Installing $module module..."
      Install-Module $module -Scope CurrentUser
      Write-Host "Operation finished"
    }
  }
}
