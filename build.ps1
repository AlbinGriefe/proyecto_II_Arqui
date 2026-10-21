param(
    [string]$Tasm = 'C:\TASM',
    [string]$Dosbox = 'C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe',
    [switch]$Test
)
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$stage = Join-Path $projectRoot 'tmp\dosbuild'
$output = Join-Path $projectRoot 'bin'
foreach ($tool in @((Join-Path $Tasm 'TASM.EXE'), (Join-Path $Tasm 'TLINK.EXE'), $Dosbox)) {
    if (!(Test-Path -LiteralPath $tool)) { throw "No se encontro: $tool" }
}
New-Item -ItemType Directory -Force -Path $stage, $output | Out-Null
Copy-Item -Path (Join-Path $projectRoot 'src\*.asm'), (Join-Path $projectRoot 'src\*.inc') -Destination $stage -Force
# Solo limpiar productos conocidos en este directorio de construccion.
foreach ($name in @('SUCCESS.OK','FAILED.OK','JUEGO.EXE','TESTS.TXT','BUILD.LOG')) {
    $artifact = Join-Path $stage $name
    if (Test-Path -LiteralPath $artifact) { Remove-Item -LiteralPath $artifact }
}
$modules = @('main','data','video','input','game','ui','tests')
$commands = [System.Collections.Generic.List[string]]::new()
$commands.Add('@echo off')
foreach ($module in $modules) {
    $commands.Add("t:\tasm.exe /zi /m2 $module.asm >> BUILD.LOG")
    $commands.Add('if errorlevel 1 goto fail')
}
$commands.Add(('t:\tlink.exe /v ' + ($modules -join '+') + ',JUEGO.EXE,JUEGO.MAP >> BUILD.LOG'))
$commands.Add('if errorlevel 1 goto fail')
if ($Test) {
    $commands.Add('JUEGO.EXE /T > TESTS.TXT')
    $commands.Add('if errorlevel 1 goto fail')
}
$commands.Add('echo OK>SUCCESS.OK')
$commands.Add('goto done')
$commands.Add(':fail')
$commands.Add('echo FAIL>FAILED.OK')
$commands.Add(':done')
$commands.Add('exit')
[IO.File]::WriteAllText((Join-Path $stage 'BUILD.BAT'), ($commands -join "`r`n") + "`r`n", [Text.Encoding]::ASCII)
$configuration = @"
[sdl]
fullscreen=false
output=surface
[cpu]
cycles=fixed 30000
[mixer]
nosound=true
[autoexec]
mount c "$stage"
mount t "$Tasm"
c:
BUILD.BAT
"@
$configPath = Join-Path $stage 'build.conf'
[IO.File]::WriteAllText($configPath, $configuration, [Text.UTF8Encoding]::new($false))
$oldVideo = $env:SDL_VIDEODRIVER
$oldAudio = $env:SDL_AUDIODRIVER
try {
    $env:SDL_VIDEODRIVER = 'dummy'
    $env:SDL_AUDIODRIVER = 'dummy'
    $process = Start-Process -FilePath $Dosbox -ArgumentList @('-noconsole', '-conf', ('"' + $configPath + '"')) -WorkingDirectory $stage -WindowStyle Hidden -PassThru
    if (!$process.WaitForExit(60000)) {
        $process.Kill()
        throw "DOSBox no termino en 60 segundos. Revisa $stage"
    }
} finally {
    $env:SDL_VIDEODRIVER = $oldVideo
    $env:SDL_AUDIODRIVER = $oldAudio
}
$logPath = Join-Path $stage 'BUILD.LOG'
if (Test-Path -LiteralPath $logPath) {
    Copy-Item -LiteralPath $logPath -Destination (Join-Path $output 'BUILD.LOG') -Force
    $log = Get-Content -LiteralPath $logPath -Raw
} else { throw 'DOSBox no genero BUILD.LOG.' }
if (!(Test-Path -LiteralPath (Join-Path $stage 'SUCCESS.OK'))) {
    Write-Output $log
    $testLog = Join-Path $stage 'TESTS.TXT'
    if (Test-Path -LiteralPath $testLog) { Get-Content -LiteralPath $testLog }
    throw 'Ensamblado, enlace o pruebas fallaron. El ejecutable anterior no fue reemplazado.'
}
if ($log -match '(?im)Warning messages:\s*[1-9]|\bWarning\b.*\([0-9]+\)|^Warning:|\*Warning\*') {
    throw 'Se detectaron advertencias de ensamblado. Revisa bin/BUILD.LOG.'
}
foreach ($name in @('JUEGO.EXE','JUEGO.MAP','TESTS.TXT')) {
    $source = Join-Path $stage $name
    if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $output -Force }
}
Write-Output 'Ensamblado y enlace completados: bin/JUEGO.EXE'
if ($Test) { Get-Content -LiteralPath (Join-Path $output 'TESTS.TXT') }
