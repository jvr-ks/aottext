@rem restart.bat
@rem !file is overwritten by update process!

@cd %~dp0


@echo no news available!
@echo.
@echo Please press a key to restart aottext (%1 bit)!
@echo.
@pause

@echo off

@set version=%1
@if [%1]==[64] set version=

@if [%2]==[noupdate] goto noupdate

@copy /Y aottext.exe.tmp aottext%version%.exe

:noupdate
@del aottext.exe.tmp
@start aottext%version%.exe

:end
@exit