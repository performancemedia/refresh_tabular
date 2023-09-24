Import-Module .\modules\read_params.psm1

$x = Get-Content .\data\metadane.yml | ConvertFrom-Yaml

# $x

$z = Read-Params -ParamsFile $x -ReturnedValue "Tabele"

# foreach ($row in $z) {
#     $row
# }
# @(Read-Params -ParamsFile $params_file -ReturnedValue "Tabele" | Foreach-Object {$_.Keys})