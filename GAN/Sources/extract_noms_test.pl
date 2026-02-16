# ____________________________________________________________
#
# Script d'extraction reflexive des abreviations normalisees
# (fichier "Attrb2Abrev.gan") pour depistage des conflits
# potentiels du glossaire des abreviations.
# ____________________________________________________________
# ==> $Workfile: extract_noms_test.pl $
# ==> $Revision: 3 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/extract_noms_test.pl $
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
my $path_src = $ENV{GANFichReverse};

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_result = "$path_tmp/_noms_attr.txt";
my $path_orig = "$path_tmp/_noms_orig.txt";

my $nb_result = 0;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src = new IO::File $path_src, O_RDONLY;
unless (defined $hdl_src)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des abreviations incorrecte ($path_result)\n"; }

my $hdl_orig = new IO::File $path_orig, O_WRONLY|O_CREAT;
unless (defined $hdl_orig)
{ die "$nom_cmd: Creation fichier des noms origine incorrecte ($path_orig)\n"; }

# ____________________________________________________________
# Corps du programme

print "\n";

parse_source();

print_parse_infos();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: parse_source ( )

sub parse_source
{
  my $entete;
  my $line;
  my $item_norm;
  my $remain;
  my @words;
  my $word;

  # boucle sur les lignes de donnees
  while ($line = $hdl_src->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # ----------------------------- #
    # ATTENTION: separateur '<tab>' #
    # ----------------------------- #
    
    # recuperation du premier champs uniquement
    ($item_norm, $remain) = split(/\t/, $line, 2);
    
    # suppression des blancs dans 'remain'
    $remain =~ s/\s*//g;
    
    @words = split(/,/, $remain);
    
    $_ = $item_norm;
    if (! /^$/)
    {
    	for $word (@words)
    	{
        $nb_result ++;
        
        # ajout tel que dans le fichier des noms origine
        print $hdl_orig "$word|$item_norm\n";
        
        # on troncque l'eventuel numero de ligne associe
        $word =~ s/\:[0-9]+//;
        
        # ajout dans le fichier resultat
        print $hdl_result "$word|$item_norm\n";
      }
    }
  }
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  print "Attributs traites :\t\t\t$nb_result\n";
}

# ____________________________________________________________

if (defined $hdl_orig) { undef $hdl_orig; }
if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_src) { undef $hdl_src; }

# ____________________________________________________________
