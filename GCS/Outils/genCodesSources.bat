@echo off

rem ############################################################

rem      ---------------------------------------------------
rem      -   Outillage de la generation de codes sources   -
rem      ---------------------------------------------------

rem ############################################################

rem Auteur:    Maxime TOLEDANO
rem Version:   1.0
rem Date:      20/09/2002

rem ############################################################
rem Initialisation des variables locales

setlocal

set GCSRepInstal=%~dp0\..\
set GCSRepCommun=%GCSRepInstal%\Outils

rem Parametres communs
set GCSTempDir=%GCSRepInstal%\Travail

rem Parametres d'entree pour 'gen_codes_sources'
set GCSFichListTpl=%GCSRepInstal%\Config\%1
set GCSFichDeclVarGen=%GCSRepInstal%\Config\%2

rem Parametres de sortie pour 'gen_codes_sources'
set GCSFichCodesGen=%GCSTempDir%\_genCodesSources.txt

rem ############################################################

if exist %GCSFichCodesGen% del %GCSFichCodesGen%
echo.

%GCSRepCommun%\gen_codes_sources.exe

pause
