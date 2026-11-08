@rem compile.bat
@echo off
rem 64 bit AHK only

rem https://www.autohotkey.com/download/2.0/
rem Install AHK 1 first, then AKH 2 !
rem Always use the default installation directory!

setlocal enabledelayedexpansion

set "appname=aottext"

rem appname override:
if not "%~1"=="" set appname="%~1"

if exist "%appname%.exe" (
  rem remove running app from memory:
  rem call %appname%.exe remove
  del /f /q %appname%.exe
)

rem Set an AHK 2 version:
rem latest AHK version:
set "ahkv=2"
rem or: set "ahkv=2.0.28" | "ahkv=2.0.27" ...

rem Use the batch file directory as source and target folder
set "dir=%~dp0"

rem Source and output file names
set "src=%dir%%appname%.ahk"
set "out=%dir%%appname%.exe"
set "ico=%dir%%appname%.ico"

set "autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

if not exist "%autohotkeyExe%" (
  echo ERROR: Autohotkey exe file
  echo %autohotkeyExe%
  echo not found!
  timeout /T 4
  exit /b1
)

set "autohotkeyBase=C:\Program Files\AutoHotkey\v%ahkv%\AutoHotkey64.exe"

if not exist "%autohotkeyBase%" (
  echo ERROR: Autohotkey base file
  echo %autohotkeyBase%
  echo not found!
  timeout /T 4
  exit /b1
)
  
rem echo Command: "%autohotkeyExe%" /in %src% /out %out% /icon %ico% /base %autohotkeyBase%
call "%autohotkeyExe%" /in "%src%" /out "%out%" /icon "%ico%" /base "%autohotkeyBase%"

echo.
echo Done: %out%
timeout /t 1
endlocal




 
