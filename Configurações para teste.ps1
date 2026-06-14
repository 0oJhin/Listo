$ErrorActionPreference = 'Stop'

$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$flutterProject = Join-Path $PSScriptRoot 'Mobile\listomobile'

if (-not (Test-Path -LiteralPath $adb)) {
    Write-Error "ADB não encontrado em: $adb"
}

if (-not (Test-Path -LiteralPath $flutterProject)) {
    Write-Error "Projeto Flutter não encontrado em: $flutterProject"
}

$devices = & $adb devices
$connectedDevices = @(
    $devices |
        Select-Object -Skip 1 |
        Where-Object { $_ -match '\sdevice$' } |
        ForEach-Object { ($_ -split '\s+')[0] }
)

if ($connectedDevices.Count -eq 0) {
    Write-Error 'Nenhum celular conectado. Ative a depuração USB e conecte o aparelho.'
}

$deviceId = $connectedDevices[0]

Write-Host "Celular encontrado: $deviceId"
Write-Host 'Configurando túnel USB para o backend na porta 8080...'

& $adb -s $deviceId reverse tcp:8080 tcp:8080

Write-Host 'Túnel configurado. Iniciando o Flutter...'

Push-Location $flutterProject
try {
    flutter run -d $deviceId --dart-define=API_BASE_URL=http://localhost:8080
}
finally {
    Pop-Location
}
