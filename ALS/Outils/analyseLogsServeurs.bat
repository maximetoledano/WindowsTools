@echo off

rem ############################################################

rem      --------------------------------------------------
rem      - Recuperation et analyse d'un lot de serveurs.  -
rem      --------------------------------------------------

rem ############################################################
rem Initialisation des variables locales

setlocal

set ALSRepInstal=%~dp0\..\
set ALSRepCommun=%ALSRepInstal%\Outils

rem Parametres communs
set ALSTempDir=%ALSRepInstal%\Travail
set ALSConfigDir=%ALSRepInstal%\Config

rem Parametres d'entree pour 'recup_logs_serveurs'
set ALSFichServeurs=%ALSConfigDir%\%1
set ALSDateHeurePlusTot=
if not "%2" == "" set ALSDateHeureDebut="%2"

rem Parametres de sortie des logs recuperes
set ALSFichLogsResult=%ALSTempDir%\all_logs.csv

rem ############################################################

if exist %ALSFichLogsResult% del %ALSFichLogsResult%
echo.

rem %ALSRepCommun%\recup_logs_serveurs.exe
perl %ALSRepInstal%\Sources\recup_logs_serveurs.pl

pause
