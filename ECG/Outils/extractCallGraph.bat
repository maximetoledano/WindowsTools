@echo off

rem ############################################################

rem      ------------------------------------------------------
rem      - Reconstitution du graphe d'appel package, classes, -
rem      - methodes.                                          -
rem      ------------------------------------------------------

rem ############################################################

rem Auteur:    Maxime TOLEDANO
rem Version:   0.1
rem Date:      12/12/2012

rem ############################################################
rem Initialisation des variables locales

setlocal

set ECGRepInstal=%~dp0\..\
set ECGRepCommun=%ECGRepInstal%\Outils

rem Parametres communs
set ECGTempDir=%ECGRepInstal%\Travail

rem Parametres d'entree pour 'extract_depends_class'
set ECGFichUses=%ECGTempDir%\SourcesCallList.txt

rem Parametres de sortie pour 'extract_depends_class'
set ECGFichDepends=%ECGTempDir%\ResultCallGraph.txt

rem ############################################################

if exist %ECGFichDepends% del %ECGFichDepends%
echo.

perl %ECGRepCommun%\extract_depends_class.pl
