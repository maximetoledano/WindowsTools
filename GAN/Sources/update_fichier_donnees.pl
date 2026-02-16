# ____________________________________________________________
#
# Script d'ajout du nom normalise produit a partir et dans les
# informations d'origine (libelles explicites).
# ____________________________________________________________
# ==> $Workfile: update_fichier_donnees.pl $
# ==> $Revision: 6 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/update_fichier_donnees.pl $
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
my $path_src_cls_elt = $ENV{GANFichSourceUpdate};
my $path_cib_cls_elt = $ENV{GANFichCibleUpdate};
my $path_src_noms_norm = $ENV{GANFichNormUpdate};
my $path_src_nuls = $ENV{GANFichNulsUpdate};
my $result_1_col = $ENV{GAN1Col};
my $mode_sep_souligne = $ENV{GANSeparateurMotSouligne};

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_rejet = "$path_tmp/_donnees_rej.txt";

my $path_result = "$path_tmp/_donnees_upd.txt";
if ($path_cib_cls_elt ne "")
{ $path_result = $path_cib_cls_elt; }

my $nb_abrev = 0;
my $nb_rejet = 0;
my $nb_accept = 0;
my $nb_result = 0;
my $nb_nuls = 0;

my $mode_1_col = 0;
if ($result_1_col == 1)
{ $mode_1_col = 1; }

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src_noms_norm = new IO::File $path_src_noms_norm, O_RDONLY;
unless (defined $hdl_src_noms_norm)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src_noms_norm)\n"; }

my $hdl_src_cls_elt = new IO::File $path_src_cls_elt, O_RDONLY;
unless (defined $hdl_src_cls_elt)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src_cls_elt)\n"; }

my $hdl_nuls = new IO::File $path_src_nuls, O_RDONLY;
unless (defined $hdl_nuls)
{ die "$nom_cmd: Creation resultat incorrecte ($path_src_nuls)\n"; }

my $hdl_rejet = new IO::File $path_rejet, O_WRONLY|O_CREAT;
unless (defined $hdl_rejet)
{ die "$nom_cmd: Creation resultat incorrecte ($path_rejet)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation resultat incorrecte ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

my %htabl_nomsnorm;
my %htabl_nuls;

print "\n";

# preparation colonnes fichier resultat:
#
#  Nomnorm     ==>  1er champs
#  XXX       ==>  complement les champs du fichier origine

load_nuls();

load_noms_norm();

parse_source();

print_parse_infos();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_nuls ( )

sub load_nuls
{
  my $line;

  # chargement en memoire des lignes declarees nulles a l'aide
  # du mecanisme d'exception
  #
  # le fichier ne contient que les libelles annules (1 colonne)
  while ($line = $hdl_nuls->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if (! /^\s*$/)
    {
      # passage en minuscule du mot candidat
      $line = lc($line);
      
      # alimentation de la table de hash dediee
      if (! exists($htabl_nuls{$line}))
      { $htabl_nuls{$line} = 1; }
      else
      {
     	  print $hdl_result "Doublon trouve dans fichier des libelles nuls [$line]\n\n";
     	  print "$nom_cmd: Doublon trouve dans fichier des libelles nuls ($line) !!!\n";
      }
    }
  }
}

# ____________________________________________________________
# SUB: load_noms_norm ( )

sub load_noms_norm
{
  my $line;
  my $item;
  my $abrev;
  
  # chargement en memoire des couples 'item/abreviation'
  while ($line = $hdl_src_noms_norm->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if (! /^\s*$/)
    {
      ($item, $abrev) = split(/\|/, $line, 2);
      
      # elimination des abreviations non conformes
      $_ = $abrev;
    
      if (/^[-A-Z0-9._]+$/)
      {
        if (! exists($htabl_nomsnorm{$item}))
        { $htabl_nomsnorm{$item} = "$abrev"; $nb_abrev ++; }
        else
        { die "$nom_cmd: Doublon trouve dans fichier des noms abreges ($item) !!!\n"; }
      }
    }
  }
  
  print "\t\t... $nb_abrev noms abreges charges\n\n";
}

# ____________________________________________________________
# SUB: parse_source ( )

sub parse_source
{
  my $line;

  # boucle sur les lignes de donnees
  while ($line = $hdl_src_cls_elt->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    (/^$/ or (parse_line($line)));
  }
}

# ____________________________________________________________
# SUB: parse_line ( line  )

sub parse_line
{
  my ($line) = @_;
  my $libelle_brut;
  my $libellenorm;
  my $reste;
  my $nomnorm;
  
  $_ = $line;
  
  # reprise telle qu'elle des lignes de commentaires
  if (/^#.*/)
  { print $hdl_result "$line\n"; }
  
  # sinon, recomposition a l'aide du code norm genere
  else
  {
    ($libelle_brut, $reste) = split(/\|/, $line, 2);
    
    # preservation des separateurs de blocs si imposes
    if ($mode_sep_souligne)
      { $libelle_brut =~ s/__/\./g;}
    
    # epuration pour obtention libelle norm
    $libellenorm = purge_libelle_origine($libelle_brut);
    
    # elimination des lignes annulees par exception
    if (exists($htabl_nuls{$libellenorm}))
    {
    	# generation d'une ligne vide, si mode resultats sur 1 colonne
  		if (mode_1_col)
  		{ print $hdl_result "\n"; }
    	
    	$nb_nuls ++;
    }
    
    # traitement des lignes a analyser
    else
    {
      # recuperation du nom norm
      # ATTENTION: rechercher sur texte en minuscule !
      if (exists($htabl_nomsnorm{$libellenorm}))
      {
      	$nomnorm = $htabl_nomsnorm{$libellenorm};
      	$nb_accept ++;
      
        # prise en compte des tags englobants de fin
        $_ = $libelle_brut;
        if (/^\s*\//)
        {
        	if (mode_1_col)
        	{ print $hdl_result "/$nomnorm\n"; }
        	else
        	{ print $hdl_result "/$nomnorm|$libelle_brut|$reste\n"; }
        }
        
        else
        {
        	if (mode_1_col)
        	{ print $hdl_result "$nomnorm\n"; }
        	else
        	{ print $hdl_result "$nomnorm|$libelle_brut|$reste\n"; }
        }
      }
      else
      { 
        if (mode_1_col)
      	{ print $hdl_result "?\n"; print $hdl_rejet "$line\n"; $nb_rejet ++; }
      	else
      	{ print $hdl_result "?|$line\n"; print $hdl_rejet "$line\n"; $nb_rejet ++; }
      }
      
      $nb_result ++;
    }
  }
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  no integer;
  
  my $prct = int(100 * $nb_accept / $nb_result);
  
  print "Unites traitees :\t\t\t$nb_result\n";
  print "\tdont $nb_accept converties norm (soit $prct %)\n";
  
  if ($nb_rejet)
  { print "\tet $nb_rejet rejetees\n\n"; }
  
  if ($nb_nuls)
  { print "\tet $nb_nuls annulees\n\n"; }
}

# ____________________________________________________________

if (defined $hdl_nuls) { undef $hdl_nuls; }
if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_rejet) { undef $hdl_rejet; }
if (defined $hdl_src_cls_elt) { undef $hdl_src_cls_elt; }
if (defined $hdl_src_noms_norm) { undef $hdl_src_noms_norm; }

# ____________________________________________________________
