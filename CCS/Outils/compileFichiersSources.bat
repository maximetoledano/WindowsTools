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

set CCSFichTmpSrc=%CCSTempDir%\_tmp_source.txt
set CCSFichTmp1=%CCSTempDir%\_tmp_parse_1.txt
set CCSFichTmp2=%CCSTempDir%\_tmp_parse_2.txt

rem ############################################################

if exist %CCSFichListSrcFiles% del %CCSFichListSrcFiles%
echo.

%CCSRepCommun%\recup_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\recup_fichiers_sources.pl

%CCSRepCommun%\filtre_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\filtre_fichiers_sources.pl

rem if exist %CCSFichTmpSrc% del %CCSFichTmpSrc%
rem if exist %CCSFichTmp1% del %CCSFichTmp1%
rem if exist %CCSFichTmp2% del %CCSFichTmp2%
rem echo.

rem %CCSRepCommun%\compile_fichiers_sources.exe
rem perl.exe %CCSRepInstal%\Sources\compile_fichiers_sources.pl

pause

rem if exist %CCSFichTmp2% del %CCSFichTmp2%
rem if exist %CCSFichTmp1% del %CCSFichTmp1%
rem if exist %CCSFichTmpSrc% del %CCSFichTmpSrc%
