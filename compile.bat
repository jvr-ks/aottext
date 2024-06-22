@rem compile.bat

@echo off

SET appname=aottext

rem call aottext.exe remove

set autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set autohotkeyCompiler=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe

call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /base "%autohotkeyCompiler%





