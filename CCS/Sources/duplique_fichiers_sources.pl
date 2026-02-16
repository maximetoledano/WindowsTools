# ____________________________________________________________
#
# Script de duplication d'une arborescence de fichiers sources
# pour manipulation ulterieure des copies obtenues.
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies standard

use IO::File;
use File::Path;
use File::Copy;

use strict "vars";
#use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des elements specifiques de l'environnement
my $path_tmp = $ENV{CCSTempDir};
my $path_rep_src_files = $ENV{CCSRepFichSrc};
my $path_rep_dst_files = $ENV{CCSRepFichDst};
my $path_list_src_files = $ENV{CCSFichListSrcFiles};

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$path_tmp =~ s/\\/\//g;
$path_rep_src_files =~ s/\"//g;
$path_rep_src_files =~ s/\\/\//g;
$path_rep_dst_files =~ s/\"//g;
$path_rep_dst_files =~ s/\\/\//g;
$path_list_src_files =~ s/\"//g;
$path_list_src_files =~ s/\\/\//g;

# ____________________________________________________________
# Corps du programme

my $nb_files = 0;

autoflush STDOUT 1;

purge_rep_dst();

copy_all_src_files();

# ____________________________________________________________
# SUB: purge_rep_dst ()

sub purge_rep_dst
{
  # purge reccursive de l'arborescence de repertoires obsoletes
  rmtree(["$path_rep_dst_files"], 0, 0);
  
  # creation du repertoire vide pour accueil des futurs fichiers compiles
  mkdir $path_rep_dst_files;
}

# ____________________________________________________________
# SUB: copy_all_src_files ( )

sub copy_all_src_files
{
  my $hdl_list_src_files;
  my $line;

  $hdl_list_src_files = new IO::File $path_list_src_files, O_RDONLY;
  unless (defined $hdl_list_src_files)
  { die "$nom_cmd: Fichier des sources a traiter incorrect ($path_list_src_files)\n"; }

  $/ = "\n";

  # parcours des noms de fichiers de sources candidats
  while ($line = $hdl_list_src_files->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # purge des eventuels '"' parasites
      $line =~ s/\"//g;
      $line =~ s/\\/\//g;
      
      # traitement du fichier candidat
      copy_src_file($line);
       
      $nb_files ++;
    }
  }
  
  if (defined $hdl_list_src_files) { undef $hdl_list_src_files; }
}

# ____________________________________________________________
# SUB: copy_src_file ()

sub copy_src_file
{
  my ($path_src_file) = @_;
  my $rel_path_file;
  my $rel_path_rep;
  
  # extraction du chemin relatif du fichier a traiter
  ($rel_path_file = $path_src_file) =~ s/$path_rep_src_files\///;
  
  # extraction des sous-repertoires eventuels
  ($rel_path_rep = $path_src_file) =~ s/$path_rep_src_files\/(.+)\/[^\/]+$/$1/
    or $rel_path_rep = "";
  
  # creation, si besoin, des repertoires intermediaires
  if ("$rel_path_rep")
  { mkdir "$path_rep_dst_files/$rel_path_rep"; }
}

# ____________________________________________________________
