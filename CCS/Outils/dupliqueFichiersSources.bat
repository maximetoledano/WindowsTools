@echo off

rem ############################################################

rem Auteur:    Maxime TOLEDANO
rem Version:   0.1
rem Date:      19/12/2003

rem ############################################################
rem Initialisation des variables locales

setlocal

set CCSRepInstal=%~dp0\..\
set CCSRepCommun=%CCSRepInstal%\Outils
set CCSTempDir=%CCSRepInstal%\Travail

set CCSMaskSrcFiles=%CCSRepInstal%\Config\%1
set CCSMaskSrcTags=%CCSRepInstal%\Config\%2
set CCSRepFichSrc=%3
set CCSRepFichDst=%CCSTempDir%\%4

set CCSFichListSrcFiles=%CCSTempDir%\_listSrcFiles.txt

rem ############################################################

if exist %CCSFichListSrcFiles% del %CCSFichListSrcFiles%
echo.

rem %CCSRepCommun%\recup_fichiers_sources.exe
perl.exe %CCSRepInstal%\Sources\recup_fichiers_sources.pl

rem %CCSRepCommun%\duplique_fichiers_sources.exe
perl.exe %CCSRepInstal%\Sources\duplique_fichiers_sources.pl

pause
