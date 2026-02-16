@echo off

echo convert_attrib_abbrev.pl ...
call pp -o convert_attrib_abbrev.exe convert_attrib_abbrev.pl
rem PerlApp convert_attrib_abbrev.pl --add GAN::Common --force --exe convert_attrib_abbrev.exe

echo extract_noms_norm.pl ...
call pp -o extract_noms_norm.exe extract_noms_norm.pl
rem PerlApp extract_noms_norm.pl --add GAN::Common --force --exe extract_noms_norm.exe

echo update_fichier_donnees.pl ...
call pp -o update_fichier_donnees.exe update_fichier_donnees.pl
rem PerlApp update_fichier_donnees.pl --add GAN::Common --force --exe update_fichier_donnees.exe

echo reverse_abrev2word.pl ...
call pp -o reverse_abrev2word.exe reverse_abrev2word.pl
rem PerlApp reverse_abrev2word.pl --add GAN::Common --force --exe reverse_abrev2word.exe

echo extract_noms_test.pl ...
call pp -o extract_noms_test.exe extract_noms_test.pl
rem PerlApp extract_noms_test.pl --add GAN::Common --force --exe extract_noms_test.exe

echo extract_problemes_test.pl ...
call pp -o extract_problemes_test.exe extract_problemes_test.pl
rem PerlApp extract_problemes_test.pl --add GAN::Common --force --exe extract_problemes_test.exe
