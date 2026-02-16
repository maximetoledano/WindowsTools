@echo off

rem ############################################################
rem Initialisation des variables locales

setlocal

set CCSRepInstal=%~dp0\..\
set CCSRepCommun=%CCSRepInstal%\Outils
set CCSTempDir=%CCSRepInstal%\Travail

set CCSMaskSrcFiles=%CCSRepInstal%\Config\%1
set CCSMaskSrcTags=%CCSRepInstal%\Config\%2
set CCSRepFichSrc=%3
set CCSRepFichDst=%4
if "%~5" NEQ "" set CCSMaskSrcName=%CCSRepInstal%\Config\%5

set CCSFichListSrcFiles=%CCSTempDir%\_listSrcFiles.txt

rem ############################################################

if exist %CCSFichListSrcFiles% del %CCSFichListSrcFiles%
echo.

%CCSRepCommun%\recup_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\recup_fichiers_sources.pl

%CCSRepCommun%\filtre_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\filtre_fichiers_sources.pl

pause
