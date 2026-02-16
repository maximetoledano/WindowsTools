# ____________________________________________________________
#
# Script de filtrage et de preparation de fichiers de sources
# pour encodage et optimisation des flux echanges.
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
my $path_mask_src_name = $ENV{CCSMaskSrcName};
my $path_mask_src_tags = $ENV{CCSMaskSrcTags};
my $path_result = $ENV{CCSFichResult};
my $path_tmp_src = $ENV{CCSFichTmpSrc};
my $path_tmp_1 = $ENV{CCSFichTmp1};
my $path_tmp_2 = $ENV{CCSFichTmp2};

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$path_tmp =~ s/\\/\//g;
$path_rep_src_files =~ s/\"//g;
$path_rep_src_files =~ s/\\/\//g;
$path_rep_dst_files =~ s/\"//g;
$path_rep_dst_files =~ s/\\/\//g;
$path_list_src_files =~ s/\"//g;
$path_list_src_files =~ s/\\/\//g;
$path_mask_src_name =~ s/\"//g;
$path_mask_src_name =~ s/\\/\//g;
$path_mask_src_tags =~ s/\"//g;
$path_mask_src_tags =~ s/\\/\//g;
$path_result =~ s/\"//g;
$path_result =~ s/\\/\//g;
$path_tmp_src =~ s/\"//g;
$path_tmp_src =~ s/\\/\//g;
$path_tmp_1 =~ s/\"//g;
$path_tmp_1 =~ s/\\/\//g;
$path_tmp_2 =~ s/\"//g;
$path_tmp_2 =~ s/\\/\//g;

# parametre optionnel
my $path_mask_src_files = $ENV{CCSMaskSrcFiles};
if ("$path_mask_src_files" eq "")
{
  undef $path_mask_src_name;
}

# ____________________________________________________________
# Corps du programme

my $nb_files = 0;

# tableau des masques optionnels pour conversion du nom de fichier source
my @atabl_nametags;
my $nb_nametags = 0;

# tableau des masques a toutes les tags pour transformation du fichier source
my @atabl_globtags;
my $nb_globtags = 0;

my $nb_tags = 0;
my $nb_masks = 0;
my $nb_files = 0;

my $sep_result = "\n-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-\n";

autoflush STDOUT 1;

purge_rep_dst();

load_masks();

parse_all_src_files();

print "\n\tTraitement des fichiers candidats :\n";
print "\t\t... $nb_nametags masques sur noms de fichier charges\n";
print "\t\t... $nb_globtags masques de traitement charges\n\n";

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
# SUB: load_masks ( )

sub load_masks
{
  my $hdl_mask_src_name;
  my $hdl_mask_src_tags;
  my $line;
  
  # recuperation prealable des masques optionnels sur nom de fichier candidat
  if (defined $path_mask_src_name)
  {
    $hdl_mask_src_name = new IO::File $path_mask_src_name, O_RDONLY;
    unless (defined $hdl_mask_src_name)
    { die "$nom_cmd: Masque sur noms de sources incorrecte ($path_mask_src_name)\n"; }
    
    $/ = "\n";
    
    # chargement en memoire du masque unique
    while ($line = $hdl_mask_src_name->getline)
    {
      # suppression fin de ligne Windows
      chomp $line;
      
      # suppression des lignes vides ou de commentaires (lignes commencant par '#')
      $_ = $line;
      if ((! /^\s*$/) and (! /^\#/))
      {
        # ajout de l'expression dans le tableau des tags sur nom de fichier
        push @atabl_nametags, "$line";
        $nb_nametags ++;
      }
    }
    
    if (defined $hdl_mask_src_tags) { undef $hdl_mask_src_tags; }
  }
  
  # traitement des masques sur elements a extraire
  $hdl_mask_src_tags = new IO::File $path_mask_src_tags, O_RDONLY;
  unless (defined $hdl_mask_src_tags)
  { die "$nom_cmd: Masques des elements de sources a extraire incorrecte ($path_mask_src_tags)\n"; }

  $/ = "\n";

  # chargement en memoire des masques d'elements a extraire
  while ($line = $hdl_mask_src_tags->getline)
  {
    my $regexp_eval;
    my $regexp_parse;
    my $tag;
    my $pos_tag;
    my $mask;
    
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # -------------------------------- #
      # Format des lignes: '*=eval_expr' #
      # -------------------------------- #
      if (/^\s*\*\s*=(.+)$/)
      {
        # ajout de l'expression dans le tableau des tags d'initialisation
        push @atabl_globtags, "$1";
        $nb_globtags ++;
      }
      else
      { die "$nom_cmd: Parametrage des tags/masques incorrect ($line)\n"; }
      
      $nb_masks ++;
    }
  }
  
  if (defined $hdl_mask_src_tags) { undef $hdl_mask_src_tags; }
}

# ____________________________________________________________
# SUB: parse_all_src_files ( )

sub parse_all_src_files
{
  my $hdl_stdout;
  my $path_file;
  my $hdl_list_src_files;
  my $line;
  
  $hdl_stdout = select();
  
  $hdl_list_src_files = new IO::File $path_list_src_files, O_RDONLY;
  unless (defined $hdl_list_src_files)
  { die "$nom_cmd: Fichier des sources a traiter incorrect ($path_list_src_files)\n"; }
  
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
      parse_src_file($line);
      
      $nb_files ++;
    }
  }
  
  if (defined $hdl_list_src_files) { undef $hdl_list_src_files; }
  
  select ($hdl_stdout);
}

# ____________________________________________________________
# SUB: parse_src_file ( )

sub parse_src_file
{
  my ($path_src_file) = @_;
  my $rel_path_file;
  my $rel_path_rep;
  my $path_dst_file;
  my $hdl_stdout;
  my $tag;
  my $pos_tag;
  my $pos;
  my $mask;
  my $nb_elts;
  my $cpt;
  my $result;
  my $read_mode;

  # extraction du chemin relatif du fichier a traiter
  ($rel_path_file = $path_src_file) =~ s/$path_rep_src_files\///i;
  
  # extraction des sous-repertoires eventuels
  ($rel_path_rep = $path_src_file) =~ s/$path_rep_src_files\/(.+)\/[^\/]+$/$1/i
    or $rel_path_rep = "";
  
  # preparation d'une lecture ligne a ligne des fichiers
  $read_mode = $/;
  $/ = '\n';
  
  # application d'eventuels filtres sur le nom du fichier
  foreach $tag (@atabl_nametags)
  {
    # ... sur chemin de fichier candidat
    $_ = $rel_path_rep;
    eval $tag;
    $rel_path_rep = $_;
    
    # ... sur nom de fichier candidat
    $_ = $rel_path_file;
    eval $tag;
    $rel_path_file = $_;
  }
  
  # creation, si besoin, des repertoires intermediaires
  if ("$rel_path_rep")
  { mkpath(["$path_rep_dst_files/$rel_path_rep"]); }
  
  # reconstitution du chemin du fichier a creer
  $path_dst_file = "$path_rep_dst_files/$rel_path_file";
  
  # memorisation de la sortie standard actuelle
  $hdl_stdout = select();
  
  # preparation d'une lecture d'une traite des fichiers
  undef $/;
  
  # generation du fichier destination par filtrage
  if (@atabl_globtags)
  {
    my $hdl_travail = new IO::File $path_dst_file, O_WRONLY|O_CREAT;
    unless (defined $hdl_travail)
    { die "$nom_cmd: Creation fichier filtre incorrecte ($path_dst_file)\n"; }
    
    select $hdl_travail;
    
    # ouverture du fichier d'origine
    open(SOURCE, "< $path_src_file")
        or die "$nom_cmd: Ouverture fichier source incorrecte ($path_src_file)\n";
    
    # preparation du fichier d'analyse, a partir du fichier source,
    # et par application des tags globaux
    while (<SOURCE>)
    {
      # recherche de l'expression dans le fichier lu
      foreach $tag (@atabl_globtags)
      { eval $tag; }
      print;
    }
    
    # fermeture du fichier ouvert
    close(SOURCE);
    
    if (defined $hdl_travail) { undef $hdl_travail; }
  }

  select $hdl_stdout;
  $/ = $read_mode;
}

# ____________________________________________________________
