@echo off

rem ############################################################

rem      --------------------------------------------------
rem      - Compare deux versions de fichiers textes, dont les colonnes sont séparées par des ''       -
rem      --------------------------------------------------

rem ############################################################

rem Auteur:    Maxime TOLEDANO
rem Version:   0.1
rem Date:      14/05/2003

rem ############################################################
rem Initialisation des variables locales

setlocal

rem Parametres communs
set GANRepInstal=%~dp0\..\
set GANRepCommun=%GANRepInstal%\Outils
set GANTempDir=%GANRepInstal%\Travail

rem Parametres d'entree pour 'compare_versions'
set GANFichV1=%GANTempDir%\%1
set GANFichV2=%GANTempDir%\%2
set GANColDebIdent=%3
set GANColFinIdent=%4
set GANColDebInfos=%5
set GANColFinInfos=%6

rem Parametres de sortie pour 'compare_versions'
set GANFichDiff=%GANTempDir%\_diff_versions.txt
set GANFichAjout=%GANTempDir%\_ajout_v2.txt
set GANFichSuppr=%GANTempDir%\_suppr_v2.txt
set GANFichIdem=%GANTempDir%\_idem_versions.txt

rem ############################################################

if exist %GANFichDiff% del %GANFichDiff%
if exist %GANFichAjout% del %GANFichAjout%
if exist %GANFichSuppr% del %GANFichSuppr%
if exist %GANFichIdem% del %GANFichIdem%
echo.

%GANRepCommun%\compare_versions.exe

pause
