param(
    [string]$Dosbox = 'C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe',
    [string]$Tasm = 'C:\TASM',
    [switch]$Debug
)
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
if (!(Test-Path -LiteralPath (Join-Path $projectRoot 'bin\JUEGO.EXE'))) {
    throw 'Primero ejecuta .\build.ps1 -Test'
}
$configDir = Join-Path $projectRoot 'tmp'
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
$launchCommand = 'JUEGO.EXE'
if ($Debug) { $launchCommand = 't:\TD.EXE JUEGO.EXE' }
$configuration = @"
[sdl]
fullscreen=false
output=surface
windowresolution=960x600
[render]
aspect=false
scaler=normal3x
[cpu]
cycles=auto
[autoexec]
mount c "$projectRoot"
mount t "$Tasm"
c:
cd \bin
$launchCommand
exit
"@
$configPath = Join-Path $configDir 'run.conf'
[IO.File]::WriteAllText($configPath, $configuration, [Text.UTF8Encoding]::new($false))
# La ventana es visible porque el usuario va a jugar o depurar.
Start-Process -FilePath $Dosbox -ArgumentList @('-noconsole','-conf',('"' + $configPath + '"')) -WorkingDirectory $configDir -Wait
