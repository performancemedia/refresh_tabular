<#
.SYNOPSIS
Modul czysci zawartosc plikow w kontenerze na podstawie okreslonych ram czasowych

.DESCRIPTION
Przy uzyciu biblioteki Az.Storage, skrypt wyszukuje wszystkie pliki umieszczone w kontenerze, grupujac je wg daty modyfikacji. Pozniej, na podstawie zdefiniowanego filtra, wybrane pliki zostaja usuniete z kontenera przy uzyciu komendy Remove-AzStorageBlob.

.EXAMPLE

#>

function Remove-ContainerContents {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true)]
        [string]$AzStorageAccountName,

        [Parameter(Mandatory = $true)]
        [string]$ContainerName,

        [Parameter(Mandatory = $true)]
        [string]$StorageAccountKey,

        [Parameter(Mandatory = $true)]
        [int]$NumberOfDaysToKeepFilesFrom
    )

    $storageContext = New-AzStorageContext -StorageAccountName $AzStorageAccountName -StorageAccountKey $StorageAccountKey
    $FirstDateTimeToKeepFilesFrom = (Get-Date).AddDays(- $NumberOfDaysToKeepFilesFrom)

    Get-AzStorageBlob -Container $ContainerName -Context $storageContext | Where-Object {$_.LastModified.DateTime -lt $FirstDateTimeToKeepFilesFrom} | Foreach-Object {Remove-AzStorageBlob -Context $storageContext -Container $ContainerName -Blob $_.Name -DeleteSnapshot -ErrorAction SilentlyContinue}

}