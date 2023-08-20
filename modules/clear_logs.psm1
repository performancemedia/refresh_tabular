<#
.SYNOPSIS
Usuwa folder z logami 

.DESCRIPTION
Na podstawie prawidlowo uzupelnionego pliku .env w notacji <klucz>:<wartosc>, skrypt wczytuje kazda pozycje jako zmienna srodowiskowa, do ktorej mozna sie odwolywac. Dla zapewnienia prawidlowego odczytu i zapisu z, najlepiej trzymac sie wymienionej wyzej konwencji, unikajac znakow specjalnych w nazwach zmiennych

.EXAMPLE
Read-ConfigFile -DotenvPath "./folder/.config"

#>