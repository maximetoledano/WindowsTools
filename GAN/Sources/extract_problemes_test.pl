# ____________________________________________________________
#
# Script d'extraction des problemes potentiels identifies par
# auto-test du glossaire des abreviations normalisees.
# ____________________________________________________________
# ==> $Workfile: extract_problemes_test.pl $
# ==> $Revision: 3 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/extract_problemes_test.pl $
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
my $path_src = $ENV{GANFichNomsConvert};
my $path_orig = $ENV{GANFichNomsOrigine};

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_result = "$path_tmp/_pb_test.txt";

my $nb_result = 0;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src = new IO::File $path_src, O_RDONLY;
unless (defined $hdl_src)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src)\n"; }

my $hdl_orig = new IO::File $path_orig, O_RDONLY;
unless (defined $hdl_orig)
{ die "$nom_cmd: Ouverture origine incorrecte ($path_orig)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des abreviations incorrecte ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

my %htabl_codes;
my %htabl_releg;

load_codes_origine();

parse_source();

print_parse_infos();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_codes_origine ( )

sub load_codes_origine
{
  my $line;

  # chargement en memoire des couples 'code/item_norm'
  while ($line = $hdl_orig->getline)
  {
    my $word_numligne;
    my $word;
    my $numligne;
    my $code;
    
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if (! /^\s*$/)
    {
      ($word_numligne, $code) = split(/\|/, $line, 2);
      
      # passage en minuscule du mot candidat
      $word_numligne = lc($word_numligne);
      
      # extraction des nom et numero de ligne
      ($word, $numligne) = split(/:/, $word_numligne, 2);
      
      # elimination des abreviations non conformes
      $_ = $code;
      if (/^[-A-Z0-9.]+/)
      {
        if (! exists($htabl_codes{$word}))
        { $htabl_codes{$word} = "$code:$numligne"; }
        else
        {
        	print $hdl_result "Doublon trouve [$word] [$code:$numligne]#[$htabl_codes{$word}]\n\n";
        	print "$nom_cmd: Doublon trouve dans fichier des codes origines ($word) !!!\n";
        	$nb_result ++;
        }
      }
      
      # traitement des codes rejetes
      else
      {
        print $hdl_result "Code non conforme trouve [$code] [$word]\n\n";
        print "$nom_cmd: Code non conforme trouve dans fichier des codes origines ($code) !!!\n";
     	}
    }
  }
}

# ____________________________________________________________
# SUB: parse_source ( )

sub parse_source
{
  my $line;
  my $first;
  my $word;
  my $item_norm;
  my $remain;
  my $officiel;
  
  # boucle sur les lignes de donnees
  while ($line = $hdl_src->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # ------------------------- #
    # ATTENTION: separateur '=' #
    # ------------------------- #
    
    # recuperation du SECOND champs uniquement
    ($word, $item_norm, $remain) = split(/=/, $line, 3);
    
    # passage en minuscule du mot candidat
    $word = lc($word);
    
    # rejet des lignes incompletement transformees
    $_ = $item_norm;
    if (/^[^()]*\#[^()]*$/)
    {
    	# recuperation du code normalise officiel
    	$officiel = $htabl_codes{$word};
    	
    	# on troncque le numero de ligne
    	$officiel =~ s/\:[0-9]+//;
    	
    	if ($officiel ne "")
    	{ print $hdl_result "$line\t\t[$officiel]\n"; $nb_result ++; }
    }
    
    # sinon, comparaison avec le code normalise officiel
    else
    {
    	# recuperation du code normalise officiel
    	$officiel = $htabl_codes{$word};
    	
    	# on troncque le numero de ligne
    	$officiel =~ s/\:[0-9]+//;
    	
    	# comparaison avec le code trouve
    	if (($officiel ne "") and ($item_norm ne $officiel))
    	{ print $hdl_result "$line\t\t[$officiel]\n"; $nb_result ++; }
    }
  }
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  print "Problemes potentiels trouves :\t\t\t$nb_result\n";
}

# ____________________________________________________________

if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_orig) { undef $hdl_orig; }
if (defined $hdl_src) { undef $hdl_src; }

# ____________________________________________________________
