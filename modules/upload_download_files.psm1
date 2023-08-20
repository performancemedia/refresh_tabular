<#
.SYNOPSIS
Umieszcza lub pobiera wskazany plik z bloba

.DESCRIPTION
Zaleznie od wybranego parametru, umieszcza wskazany plik w kontenerze lub pobiera go lokalnie. 

.EXAMPLE
Ponizsza komenda umieszcza plik 'logs.txt' w kontenerze 'logs':

Start-BlobUploadOrDownload -StorageAccount "test1" -Container "logs" -StorageAccountAccessKey "123hj!^&!2zw" -FileNameOrFilePath "logs.txt" -Upload

Chcac pobrac plik 'logs.txt' z kontenera 'logs', wywolujemy nastepujaca komende:

Start-BlobUploadOrDownload -StorageAccount "test1" -Container "logs" -StorageAccountAccessKey "123hj!^&!2zw" -FileNameOrFilePath "logs.txt" Download
#>

function Start-BlobUploadOrDownload {
    [CmdletBinding(
        PositionalBinding=$true
    )]

    param(
        [Parameter(Mandatory=$true)]
        [string] $StorageAccount,

        [Parameter(Mandatory=$true)]
        [string] $Container,

        [Parameter(Mandatory=$true)]
        [string] $StorageAccountAccessKey,

        [Parameter(Mandatory=$true)]
        [string] $FileNameOrFilePath,

        [Parameter(ParameterSetName = "Upload")]
        [switch] $Upload,

        [Parameter(ParameterSetName = "Download")]
        [switch] $Download,

        [Parameter(ParameterSetName = "Upload")]
        [Parameter(ParameterSetName = "Download")]
        [string] $Parameter,

        [Parameter(Mandatory=$false)]
        [string] $FileDestination
    )

    # Nawiazanie polaczenia z kontenerem i umieszczenie w nim wskazanego pliku
    $context = (New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountAccessKey).Context

    if ($Upload) {
        Set-AzStorageBlobContent -File $FileNameOrFilePath -Container $Container -Blob $FileName -Context $context -Force
    }

    elseif ($Download) {
        Get-AzStorageBlobContent -Container $Container -Blob $FileNameOrFilePath -Context $context -Force -Destination $FileDestination
    }
}