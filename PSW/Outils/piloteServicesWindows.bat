@echo off

rem ############################################################

rem      -------------------------------------------
rem      -      Pilotage des services Windows      -
rem      -------------------------------------------

rem ############################################################
rem Initialisation des variables locales

setlocal

set PSWRepInstal=%~dp0\..\
set PSWRepCommun=%PSWRepInstal%\Outils

rem Parametres communs
set PSWConfigDir=%PSWRepInstal%\Config
set PSWTempDir=%PSWRepInstal%\Travail

rem Parametres d'entree pour 'pilote_services_windows'
set PSWAction=%1
set PSWProcessGroup=%2
set PSWFichCommand=%PSWConfigDir%\%PSWAction%_%PSWProcessGroup%.txt
set PSWFichProcess=%PSWTempDir%\_process_%PSWProcessGroup%.txt

rem Parametres de sortie pour 'pilote_services_windows'
set PSWFichTmpSrc=%PSWTempDir%\_tmp_source.txt
set PSWFichResult=%PSWTempDir%\_actionsServices.txt

rem ############################################################

if exist %PSWFichResult% del %PSWFichResult%
if exist %PSWFichTmpSrc% del %PSWFichTmpSrc%
echo.

rem Si 'Start' : Suppression fichier des processus
if %PSWAction% == "Start" if exist %PSWFichProcess% del %PSWFichProcess%

%PSWRepCommun%\pilote_services_windows.exe
rem perl.exe %PSWRepInstal%\Sources\pilote_services_windows.pl

rem Si 'Stop' : Suppression fichier des processus
if %PSWAction% == "Stop" if exist %PSWFichProcess% del %PSWFichProcess%

pause

if exist %PSWFichTmpSrc% del %PSWFichTmpSrc%
