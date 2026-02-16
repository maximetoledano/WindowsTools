# ____________________________________________________________
#
# Script de recuperation des fichiers de sources a compiler.
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies standard

use IO::File;
use File::Find;
use DirHandle;

use strict "vars";
use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des elements specifiques de l'environnement
my $path_tmp = $ENV{CCSTempDir};
my $path_rep_src_files = $ENV{CCSRepFichSrc};
my $path_mask_src_files = $ENV{CCSMaskSrcFiles};
my $path_result = $ENV{CCSFichListSrcFiles};

my $nb_result = 0;

# ____________________________________________________________
# Preparation des fichiers

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$path_tmp =~ s/\\/\//g;
$path_rep_src_files =~ s/\"//g;
$path_rep_src_files =~ s/\\/\//g;
$path_mask_src_files =~ s/\"//g;
$path_mask_src_files =~ s/\\/\//g;
$path_result =~ s/\"//g;
$path_result =~ s/\\/\//g;

my $hdl_mask_src_files = new IO::File $path_mask_src_files, O_RDONLY;
unless (defined $hdl_mask_src_files)
{ die "$nom_cmd: Masques des noms de fichiers sources incorrecte ($path_mask_src_files)\n"; }

my $hdl_result;
$hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des sources trouves incorrecte ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

# tableau des masques sur fichiers sources
my @atabl_masks;
my $nb_masks = 0;

# tableau des fichiers sources candidats
my @atabl_files;
my $nb_files = 0;

autoflush STDOUT 1;

load_masks();

parse_rep();

print "\n\tRecensement des fichiers candidats :\n";
print "\t\t... $nb_masks masques charges\n";
print "\t\t... $nb_files fichiers trouves\n\n";

# ____________________________________________________________
# SUB: load_masks ( )

sub load_masks
{
  my $line;
  my $mask;

  # chargement en memoire des masques sur fichiers sources
  while ($line = $hdl_mask_src_files->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      push @atabl_masks, $line;
      
      $nb_masks ++;
    }
  }
}

# ____________________________________________________________
# SUB: parse_find_entry ( )

sub parse_find_entry
{
  my $mask;
  
  study;
  
  # traitement des masques sur fichiers sources
  foreach $mask (@atabl_masks)
  {
    if (/^$mask$/i)
    {
      print $hdl_result "$File::Find::name\n";
      $nb_files ++;
    }
  }
}

# ____________________________________________________________
# SUB: parse_rep ( )

sub parse_rep
{
  find({ bydepth=>1, wanted=>\&parse_find_entry, follow=>0 }, $path_rep_src_files);
}

# ____________________________________________________________

if (defined $hdl_mask_src_files) { undef $hdl_mask_src_files; }
if (defined $hdl_result) { undef $hdl_result; }

# ____________________________________________________________
