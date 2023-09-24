<#
.SYNOPSIS
Skrypt uruchamia odswiezanie tabel na modelu na podstawie parametrow w pliku .yml i parametrach wprowadzonych do pliku .config
#>

# zaladuj zmienne srodowiskowe
Import-Module .\modules\read_config.psm1
Read-ConfigFile -ConfigFilePath .\.config

# obecna godzina posluzy do zweryfikowania, czy nalezy rozpoczac odswiezanie
$current_hour = Get-Date -Format "HH"

# zaktualizuj plik z metadanymi
Import-Module .\modules\upload_download_files.psm1
# Start-BlobUploadOrDownload -StorageAccount $ENV:STORAGE_ACCOUNT -Container $ENV:YML_CONTAINER -StorageAccountAccessKey $ENV:ACCESS_KEY -FileNameOrFilePath "metadane.yml" -FileDestination .\data\metadane.yml -Download

Import-Module .\modules\check_modules.psm1
# Start-ModuleVerification -Modules @("SqlServer","Az.Accounts","Az.Storage","powershell-yaml", "MicrosoftPowerBIMgmt")

# zaimportuj parametry
$params_file = (Get-Content .\data\metadane.yml) | ConvertFrom-Yaml

Import-Module .\modules\read_params.psm1

# sprawdz, czy odswiezanie powinno zostac wykonane
$is_active = (Read-Params -ParamsFile $params_file -ReturnedValue "Odswiezanie_aktywne").ToUpper()
$scheduled_hour = Read-Params -ParamsFile $params_file -ReturnedValue "Godziny"

if (($is_active -eq "TAK") -and ($current_hour -in $scheduled_hour)) 
{
    Write-Host "Initializing refresh..."
}
else {
    Write-Host "Refresh didn't start.
    Reason: Current time is not maching with scheduled one or the flow is not active"
    break
}

# przypisz odpowiednie parametry z pliku .yml do zmiennych
$refresh_params = 
@{
    AnalysisServicesInstance = Read-Params -ParamsFile $params_file -ReturnedValue "Serwer"
    AnalysisServicesDatabaseName = Read-Params -ParamsFile $params_file -ReturnedValue "Model"
}

# uzyskaj dostep do AAS'a przy pomocy konta serwisowego
$SecurePwd = ConvertTo-SecureString -String $ENV:PWD -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ENV:UID,$SecurePwd
# z principalem powinno być "$ENV:UID@$ENV:TENANT_ID"

Connect-AzAccount -Credential $Credential -Subscription $ENV:SUBSCRIPTION_ID -Tenant $ENV:TENANT_ID -AuthScope AnalysisServices #-ServicePrincipal

# stworz folder z logami, jezeli nie istnial do tej pory
if ((Get-ChildItem .\).Name -contains "logs") {$null}
else {
    Write-Host "Created new directory - 'logs'"
    New-Item -Path (Get-Location) -Name "logs" -ItemType "directory"
}

function Start-TableProcessing {
    [CmdletBinding(
        PositionalBinding=$true)] 

    param(
        [Parameter(Mandatory=$true)]
        [string] $AnalysisServicesInstance,

        [Parameter(Mandatory=$true)]
        [string] $AnalysisServicesDatabaseName

        # [Parameter(Mandatory=$true)]
        # [string[]] $Tables
    )

    $processing_results = @()
    $start_times = @()
    $end_times = @()
    $table_names = @()

    $Tables = Read-Params -ParamsFile $params_file -ReturnedValue "Tabele"
    
    #wyciagnij wejsciowe ilosci wierszy dla kazdej z tabel, przed rozpoczeciem odswiezania
    $Tables_tmp = $Tables.Keys
    $dax_query = ($Tables_tmp | Foreach-object {"(COUNTROWS('{0}'),`"{0}`")" -f $_}) -join ","
    [xml]$response = Invoke-AsCmd -Server $AnalysisServicesInstance -Database $AnalysisServicesDatabaseName -Credential $Credential -Query "EVALUATE {$dax_query}"
    $initial_rows = $response.return.root.row._x005B_Value1_x005D_

    foreach ($entry in $Tables) {

        $start_times += (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
        $table_name = $entry.Keys
        $table_names += $table_name
    
        Write-Host "Processing table $table_name"
        
        try {

            if ((Read-Params -ParamsFile $params_file -ReturnedValue "Dzien_odswiezania_historii") -eq (Get-Date -Format "dd")) {
                Invoke-ProcessTable -TableName $entry.Keys -DatabaseName $AnalysisServicesDatabaseName -Server $AnalysisServicesInstance -RefreshType Full -Verbose -Credential $Credential
            }
            else {
                if ($entry.Values -eq "Odswiezanie_pelne") {
                    Invoke-ProcessTable -TableName $entry.Keys -DatabaseName $AnalysisServicesDatabaseName -Server $AnalysisServicesInstance -RefreshType Full -Verbose -Credential $Credential
                }
                else {
                    Invoke-ProcessPartition -TableName $entry.Keys -PartitionName (Read-Params -ParamsFile $params_file -ReturnedValue "Nazwa_partycji_historycznej") -Database $AnalysisServicesDatabaseName -Server $AnalysisServicesInstance -RefreshType Full -Verbose -Credential $Credential
                }
            
            }
            
            $end_times += (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
            $processing_results += "Sukces"

            Write-Host "Table $table_name was refreshed successfully"
        
    }
        catch {
            $end_times += (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
            $processing_results += $Error[0].Exception.Message

            Write-Host "Processing table $table_name ended with failure"
        }

    }

    # wyciagnij wyjsciowe ilosci wierszy dla kazdej z tabel. Posluzy to do porownania, ile wierszy zostalo zaladowanych dla kazdej z tabel
    [xml]$response = Invoke-AsCmd -Server $AnalysisServicesInstance -Database $AnalysisServicesDatabaseName -Credential $Credential -Query "EVALUATE {$dax_query}"
    $final_rows = $response.return.root.row._x005B_Value1_x005D_

    $refresh_stats = [PSCustomObject]@{
        Tabela = $table_names
        Start = $start_times
        Koniec = $end_times
        Wynik = $processing_results
        Wiersze_wejsciowe = $initial_rows
        Wiersze_wyjsciowe = $final_rows
    }

    # zapisz wyniki odswiezania jako json
    $refresh_stats | ConvertTo-Json -Depth 100 | Out-File ".\logs\$filename"

}

# rozpocznij odswiezanie tabel na modelu
$current_datetime = Get-Date -Format "yyyyMMddHHmmss"
$filename = ".\refresh_logs_$current_datetime.txt"
Start-TableProcessing @refresh_params
# $refresh_params.Values.Keys

# umiesc wyniki na bobie
Start-BlobUploadOrDownload -StorageAccount $ENV:STORAGE_ACCOUNT -Container $ENV:LOG_CONTAINER -StorageAccountAccessKey $ENV:ACCESS_KEY -FileNameOrFilePath ".\logs\$filename" -Upload -Verbose

# odswiez raport z wynikami procesowania modelu (chyba, ze wskazano inaczej w pliku .yml)
if ( (Read-Params -ParamsFile $params_file -ReturnedValue "Raport_odswiezania").ToUpper() -eq "TAK") {
    Import-Module .\modules\refresh_pbi_dataset.psm1

    Start-DatasetRefresh -UserEmail $ENV:PBI_UID -UserPwd $ENV:PBI_PWD -DatasetId $ENV:PBI_DATASETID
}
