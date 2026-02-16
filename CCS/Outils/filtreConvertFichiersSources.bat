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

set CCSFichTmpMask=%CCSTempDir%\_tmp_masks.txt
set CCSFichTmp1=%CCSTempDir%\_tmp_convert_1.txt
set CCSFichTmp2=%CCSTempDir%\_tmp_convert_2.txt

rem ############################################################

if exist %CCSFichListSrcFiles% del %CCSFichListSrcFiles%
echo.

%CCSRepCommun%\recup_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\recup_fichiers_sources.pl

%CCSRepCommun%\filtre_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\filtre_fichiers_sources.pl

if exist %CCSFichTmpMask% del %CCSFichTmpMask%
if exist %CCSFichTmp1% del %CCSFichTmp1%
if exist %CCSFichTmp2% del %CCSFichTmp2%

rem %CCSRepCommun%\convert_fichiers_sources.exe
perl.exe %CCSRepInstal%\Sources\convert_fichiers_sources.pl

pause

if exist %CCSFichTmp2% del %CCSFichTmp2%
if exist %CCSFichTmp1% del %CCSFichTmp1%
if exist %CCSFichTmpMask% del %CCSFichTmpMask%
