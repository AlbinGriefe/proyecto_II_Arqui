@echo off
t:\tasm.exe /zi /m2 main.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 data.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 video.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 input.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 game.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 ui.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tasm.exe /zi /m2 tests.asm >> BUILD.LOG
if errorlevel 1 goto fail
t:\tlink.exe /v main+data+video+input+game+ui+tests,JUEGO.EXE,JUEGO.MAP >> BUILD.LOG
if errorlevel 1 goto fail
JUEGO.EXE /T > TESTS.TXT
if errorlevel 1 goto fail
echo OK>SUCCESS.OK
goto done
:fail
echo FAIL>FAILED.OK
:done
exit
