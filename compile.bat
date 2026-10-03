@rem compile.bat

@echo off
setlocal

set "appname=aottext"

rem Set an AHK 2 version:
set "VER=1"


rem Use the batch file directory as source and target folder
set "dir=%~dp0"

rem Source and output file names
set "src=%dir%%appname%.ahk"
set "out=%dir%%appname%.exe"
set "ico=%dir%%appname%.ico"


set "autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

rem Select compiler path by version
if "%VER%"=="1" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.1\AutoHotkey64.exe"
if "%VER%"=="7" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.7\AutoHotkey64.exe"
if "%VER%"=="22" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.22\AutoHotkey64.exe"
if "%VER%"=="23" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.23\AutoHotkey64.exe"
if "%VER%"=="24" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.24\AutoHotkey64.exe"
if "%VER%"=="25" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.25\AutoHotkey64.exe"
if "%VER%"=="26" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.26\AutoHotkey64.exe"
if "%VER%"=="27" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.27\AutoHotkey64.exe"
if "%VER%"=="28" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2.0.28\AutoHotkey64.exe"
if "%VER%"=="29" set "autohotkeyBase=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

rem call %appname%.exe remove
call "%autohotkeyExe%" /in %src% /out %out% /icon %ico% /base "%autohotkeyBase%"

echo.
echo Done: %out%
timeout /t 4
endlocal




