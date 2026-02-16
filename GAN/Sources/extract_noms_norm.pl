# ____________________________________________________________
#
# Script d'extraction des noms XML normalises (uniques sur N
# caracteres)
# ____________________________________________________________
# ==> $Workfile: extract_noms_norm.pl $
# ==> $Revision: 3 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/extract_noms_norm.pl $
# ____________________________________________________________
# 
# Forcage de l'encodage en ISO-8859-15
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies

use utf8;

use IO::File;

use strict "vars";
use strict "refs";
use integer;

# ____________________________________________________________
# Declaration des librairies GAN

use lib qw(C:/Perl/perl/site/lib);

use GAN::Common;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des arguments de la ligne de commande
my $path_tmp = $ENV{GANTempDir};
my $path_src = $ENV{GANFichNomsAbrev};
my $lng_max_nom_norm = $ENV{GANLongueur};

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

if ($lng_max_nom_norm eq "")
{ $lng_max_nom_norm = 20; }

my $path_result = "$path_tmp/_noms_norm.txt";
my $path_lng = "$path_tmp/_noms_norm_lng.txt";
my $path_dbl = "$path_tmp/_noms_norm_dbl.txt";
my $path_rej = "$path_tmp/_noms_norm_rej.txt";
my $path_nul = "$path_tmp/_noms_norm_nul.txt";

my $nb_result = 0;
my $nb_doublons = 0;
my $nb_rejets = 0;
my $nb_nuls = 0;
my $nb_longs = 0;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src = new IO::File $path_src, O_RDONLY;
unless (defined $hdl_src)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des extractions de noms incorrecte ($path_result)\n"; }

my $hdl_lng = new IO::File $path_lng, O_WRONLY|O_CREAT;
unless (defined $hdl_lng)
{ die "$nom_cmd: Creation fichier des noms longs incorrecte ($path_lng)\n"; }

my $hdl_dbl = new IO::File $path_dbl, O_WRONLY|O_CREAT;
unless (defined $hdl_dbl)
{ die "$nom_cmd: Creation fichier des doublons incorrecte ($path_dbl)\n"; }

my $hdl_rej = new IO::File $path_rej, O_WRONLY|O_CREAT;
unless (defined $hdl_rej)
{ die "$nom_cmd: Creation fichier des doublons incorrecte ($path_rej)\n"; }

my $hdl_nul = new IO::File $path_nul, O_WRONLY|O_CREAT;
unless (defined $hdl_nul)
{ die "$nom_cmd: Creation fichier des doublons incorrecte ($path_nul)\n"; }

# ____________________________________________________________
# Corps du programme

my %htable_noms_norm;
my %htable_count;

print "\n";
print "Longueur des tags normalises limitee a $lng_max_nom_norm caracteres !\n\n";

parse_source();

print_sort_noms();

print_parse_infos();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: parse_source ( )

sub parse_source
{
  my $line;
  my $first;
  my $lib_norm;
  my $item_norm;
  my $remain;
  
  # boucle sur les lignes de donnees
  while ($line = $hdl_src->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # ------------------------- #
    # ATTENTION: separateur '=' #
    # ------------------------- #
    
    # recuperation du SECOND champs uniquement
    ($lib_norm, $item_norm, $remain) = split(/=/, $line, 3);
    
    # rejet des lignes non ou incompletement transformees
    # hors exceptions (^#$)
    $_ = $item_norm;
    if (! /^#$/)
    {
      if (/[a-z\#]/)
      { print $hdl_rej "$item_norm\n"; $nb_rejets ++; }
      else
      { parse_line($lib_norm, $item_norm); }
    }
    else
    { print $hdl_nul "$lib_norm\n"; $nb_nuls ++; }
  }
}

# ____________________________________________________________
# SUB: parse_line ( source, nom_norm )

sub parse_line
{
  my ($source, $nom_norm) = @_;
  my $short_nom;
  my $adapt_nom;
  my $uniqId;
  my $lng_uniqId;
  
  $nb_result ++;
  
  # test sur longueur du mot
  if (length $nom_norm > $lng_max_nom_norm)
  {
    # conversion sur $lng_max_nom_norm caracteres
    $short_nom = substr $nom_norm, 0, $lng_max_nom_norm;

    # suppression eventuel '-' en fin de ligne
    $short_nom =~ s/-$//g;
    
    # ajout dans fichier des noms longs troncques
    print $hdl_lng "$nom_norm ==> $short_nom\n";
    
    $nb_longs ++;
  }
  else
  {
    # initialisation du nom normalise
    $short_nom = $nom_norm;
  }
  
  # traitement des cas nominaux
  if (! exists $htable_count{$short_nom})
  {
    $htable_count{$short_nom} = 0;
    $htable_noms_norm{$short_nom} = $source;
  }
  
  # traitement des doublons eventuels
  else
  {
    # signalement des doublons dans fichier dedie
    print $hdl_dbl "$source($htable_noms_norm{$short_nom})|$short_nom\n";
    
    # tentative de recuperation par ajout numero de sequence
    $uniqId = int($htable_count{$short_nom}) + 1;
    $lng_uniqId = length "$uniqId";
    
    $adapt_nom = substr($nom_norm, 0, ($lng_max_nom_norm - $lng_uniqId)) . "$uniqId";

    if (! exists $htable_count{$adapt_nom})
    {
      $htable_count{$adapt_nom} = 0;
      $htable_noms_norm{$adapt_nom} = $source;
      $htable_count{$short_nom} = $uniqId;
      $nb_doublons ++;
    }
    
    else
    { print "Doublon non reductible: [$adapt_nom] [$short_nom] !!!\n\n"; }
  }
}

# ____________________________________________________________
# SUB: print_sort_noms ( )

sub print_sort_noms
{
  my @keys;
  my $key;

  # tri en memoire des noms normalises trouves
  # pour alimentation du fichier associe
  foreach $key (sort(keys %htable_noms_norm))
  { print $hdl_result "$htable_noms_norm{$key}|$key\n"; }
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  print "Unites trouvees :\t\t\t$nb_result\n";
  print "\tdont noms longs :\t\t$nb_longs\n";
  print "\tdont doublons convertis :\t$nb_doublons\n";
  print "\tdont rejets :\t\t\t$nb_rejets\n";
  print "\tdont nuls :\t\t\t$nb_nuls\n";
}

# ____________________________________________________________

if (defined $hdl_nul) { undef $hdl_nul; }
if (defined $hdl_rej) { undef $hdl_rej; }
if (defined $hdl_dbl) { undef $hdl_dbl; }
if (defined $hdl_lng) { undef $hdl_lng; }
if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_src) { undef $hdl_src; }

# ____________________________________________________________
