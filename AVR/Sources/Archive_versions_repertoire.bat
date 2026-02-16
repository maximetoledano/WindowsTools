@echo off

rem ############################################################
rem Initialisation des variables locales

setlocal

set AVRRepInstal=%~dp0

set AVRRepSrc=%1


rem ############################################################

perl.exe %AVRRepInstal%\archive_versions_repertoire.pl %AVRRepSrc%

pause
