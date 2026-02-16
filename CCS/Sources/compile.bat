@echo off
cls

PerlApp compile_fichiers_sources.pl --nologo --force --exe compile_fichiers_sources.exe

PerlApp filtre_fichiers_sources.pl --nologo --force --exe filtre_fichiers_sources.exe

PerlApp convert_fichiers_sources.pl --nologo --force --exe convert_fichiers_sources.exe

PerlApp recup_fichiers_sources.pl --nologo --force --exe recup_fichiers_sources.exe

PerlApp duplique_fichiers_sources.pl --nologo --force --exe duplique_fichiers_sources.exe

echo.
pause
