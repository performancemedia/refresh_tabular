<#
.SYNOPSIS
Odczytuje plik z parametrami w typie hashtable

.DESCRIPTION
Na podstawie wprowadzonego obiektu typu hashtable, skrypt zwraca konkretna wartosc przypisana do szukanego klucza (parametr '-ReturnedValue')

.EXAMPLE
Read-Params -ParamsFile $param_hashtable -ReturnedValue "Value2"

#>

function Read-Params {
  [CmdletBinding()]

  param(
    [Parameter(Mandatory = $true)]
    [hashtable]$ParamsFile,

    [Parameter(Mandatory = $true)]
    [string]$ReturnedValue
  )

  foreach ($entry in $ParamsFile.GetEnumerator()) {
    $entry.Value | Where-Object { $entry.Name -eq $ReturnedValue }
  }
}
