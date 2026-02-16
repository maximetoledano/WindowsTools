@echo off

rem ############################################################

rem      --------------------------------------------------
rem      - Reconstitution des dependances entre classes,  -
rem      - puis entre packages, d'un modele Rose.         -
rem      --------------------------------------------------

rem ############################################################

rem Auteur:    Maxime TOLEDANO
rem Version:   1.2
rem Date:      07/04/2003

rem ############################################################
rem Initialisation des variables locales

setlocal

set ADPRepInstal=%~dp0\..\
set ADPRepCommun=%ADPRepInstal%\Outils

rem Parametres communs
set ADPTempDir=%ADPRepInstal%\Travail

rem Parametres d'entree pour 'extract_depends_class'
set ADPFichUses=%ADPTempDir%\UsesClassesRose.txt

rem Parametres de sortie pour 'extract_depends_class'
set ADPFichDepends=%ADPTempDir%\DependsClassesRose.txt

rem ############################################################

if exist %ADPFichDepends% del %ADPFichDepends%
echo.

%ADPRepCommun%\extract_depends_class.exe
