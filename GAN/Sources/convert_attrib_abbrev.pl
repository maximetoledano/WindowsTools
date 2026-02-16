# ____________________________________________________________
#
# Script de conversion des libelles longs en une combinaison
# d'abreviations normalisees.
# ____________________________________________________________
# ==> $Workfile: convert_attrib_abbrev.pl $
# ==> $Revision: 4 $
# ==> $Date: 21/02/03 15:02 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/convert_attrib_abbrev.pl $
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies standard

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

# recuperation des elements specifiques de l'environnement
my $path_tmp = $ENV{GANTempDir};
my $path_src_abrev = $ENV{GANFichAbbrev};
my $path_src_attr = $ENV{GANFichSourceConvert};
my $path_src_except = $ENV{GANFichExceptConvert};
my $lib_a_convertir = $ENV{GANLibelleConvert};
my $mode_sep_souligne = $ENV{GANSeparateurMotSouligne};

my $noecho = 0;

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_result = "$path_tmp/_attr2abrev.txt";

my $nb_result = 0;
my $nb_conv = 0;
my $nb_abrev = 0;
my $nb_except = 0;

my $mode_cmd = 0;
if ($lib_a_convertir ne "")
{ $mode_cmd = 1; }

my $mode_bavard = 1;
if ($noecho == 1)
{ $mode_bavard = 0; }

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src_abrev = new IO::File $path_src_abrev, O_RDONLY;
unless (defined $hdl_src_abrev)
{ die "$nom_cmd: Ouverture source incorrecte ($path_src_abrev)\n"; }

my $hdl_src_except = new IO::File $path_src_except, O_RDONLY;

my $hdl_src_attr;
my $hdl_result;

if (! $mode_cmd)
{
  $hdl_src_attr = new IO::File $path_src_attr, O_RDONLY;
  unless (defined $hdl_src_attr)
  { die "$nom_cmd: Ouverture source incorrecte ($path_src_attr)\n"; }
  
  $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
  unless (defined $hdl_result)
  { die "$nom_cmd: Creation fichier des noms abreges incorrecte ($path_result)\n"; }
}

# ____________________________________________________________
# Corps du programme

my @atabl_abrev;
my @atabl_except;
my %htabl_attrb;

if ($mode_bavard)
{ print "\n"; }

if (defined $hdl_src_except)
{ load_except(); }

load_abbrev();

if (! $mode_cmd)
{
  parse_source();
  
  print_sort_attrs();
  
  print_parse_infos();
}

else
{
  # preservation des separateurs de blocs si imposes
  if ($mode_sep_souligne)
    { $lib_a_convertir =~ s/__/\./g;}

  parse_line(purge_libelle_origine($lib_a_convertir));
}

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_except ( )

sub load_except
{
  my $line;
  my $item;
  my $abrev;

  # chargement en memoire des couples 'item/abreviation'
  while ($line = $hdl_src_except->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires
    # (commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # ------------------------- #
      # ATTENTION: separateur '=' #
      # ------------------------- #
      
      ($item, $abrev) = split(/=/, $line, 2);
      
      # item en miniscule, abrev a l'identique
      $item = lc($item);
      
      # verification de l'equilibrage du parenthesage
      $_ = $item;
      my $nbe_deb = tr/(//;
      my $nbe_fin = tr/)//;
      
      if ($nbe_deb != $nbe_fin)
      { die "$nom_cmd: Mauvais parenthesage des exceptions ($item)\n"; }
      
      # alimentation du tableau si parenthesage ok
      else
      {
        push @atabl_except, "$item";
        push @atabl_except, "$abrev";
        push @atabl_except, "$nbe_deb";
        
        $nb_except ++;
      }
    }
  }
  
  if (! $mode_cmd)
  { print "\t\t... $nb_except exceptions chargees\n\n"; }
  
  # preparation parcours tableau
  $nb_except *= 3;
}

# ____________________________________________________________
# SUB: load_abbrev ( )

sub load_abbrev
{
  my $line;
  my $item;
  my $abrev;

  # chargement en memoire des couples 'item/abreviation'
  while ($line = $hdl_src_abrev->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires
    # (commencant par '#')
    $_ = $line;
    if ((! /^\s*$/)  and (! /^\#/))
    {
      # ------------------------- #
      # ATTENTION: separateur '=' #
      # ------------------------- #
      
      ($item, $abrev) = split(/=/, $line, 2);
      
      # item en miniscule, abrev a l'identique mais,
      # pour tous, on supprime les espaces et tabulations
      $item =~ s/\s+//g; $item = lc($item);
      $abrev =~ s/\s+//g;
    
      push @atabl_abrev, "$item";
      push @atabl_abrev, "$abrev";
      
      $nb_abrev ++;
    }
  }
  
  if (! $mode_cmd)
  { print "\t\t... $nb_abrev abreviations chargees\n\n"; }
  
  # preparation parcours tableau
  $nb_abrev *= 2;
}

# ____________________________________________________________
# SUB: parse_source ( )

sub parse_source
{
  my $attr;
  my $lib_orig;
  my $lib_norm;
  my $reste;
  
  # boucle sur les lignes de donnees
  while ($attr = $hdl_src_attr->getline)
  {
    # suppression fin de ligne Windows
    chomp $attr;
    
    # extraction libelle explicite (1er champs)
    ($lib_orig, $reste) = split(/\|/, $attr);

    # preservation des separateurs de blocs si imposes
    if ($mode_sep_souligne)
      { $lib_orig =~ s/__/\./g;}
    
    # epuration du libelle d'origine
    $lib_norm = purge_libelle_origine($lib_orig);
    
    $_ = $lib_norm;
    (/^$/ or /^\#/ or (parse_line($lib_norm)));
  }
}

# ____________________________________________________________
# SUB: parse_line ( nom_norm )

sub parse_line
{
  my ($nom_norm) = @_;
  my $nom_abreg = $nom_norm;
  my $item;
  my $abrev;
  my $nbe_champs;
  my $cpt;
  my $full = 0;
  
  $nb_result ++;
  
  # preparation analyse du nom
  $_ = $nom_abreg; study;
  
  # boucle sur les exceptions pour conversion du nom
  if (defined $hdl_src_except)
  {
    for ($cpt = 0; (! $full) and ($cpt < $nb_except);)
    {
      $item = "$atabl_except[$cpt ++]";
      $abrev = "$atabl_except[$cpt ++]";
      $nbe_champs = "$atabl_except[$cpt ++]";
      
      if ( /^$item$/ )
      {
      	my @champs;
      	my $cpt2;
        
      	# recuperation des champs non substitues
      	for ($cpt2 = 1; (! $full) and ($cpt2 < $nbe_champs + 1); $cpt2 ++)
      	{ push @champs, eval "\$$cpt2"; }
        
        # test si abreviation vide (#)
        $_ = $abrev;
        if (/^#$/)
        { $nom_abreg = "#"; $full = 1; }
        
        # sinon, analyse des constituants de l'abreviation
        else
        {
        	# mise a jour de l'abreviation en partie droite
        	# ATTENTION: Compteur sur table numerote a partir de 0 !!!
        	for ($cpt2 = 1; (! $full) and ($cpt2 < $nbe_champs + 1); $cpt2 ++)
        	{ $abrev =~ s/\$$cpt2/@champs[$cpt2 - 1]/g; $nb_conv ++; }
          
          $nom_abreg = $abrev;
          
          $nb_conv ++;
          
          # preparation rebouclage sur la meme exception
          if (! $full)
          { $cpt -= 3; }
          
          # preparation recherche suivante
          $_ = $nom_abreg; study;
        }
      }
    }
  }
  
  # boucle sur les abreviations normalisees pour conversion du nom
  if (! $full)
  {
    for ($cpt = 0; $cpt < $nb_abrev;)
    {
      $item = "$atabl_abrev[$cpt ++]"; 
      $abrev = "$atabl_abrev[$cpt ++]";
      
      if ( /$item/ )
      {
        $_ = $abrev;
        if ( /^(.+)&e$/ )
          { my $pattern = "\#$1\#&e"; $nom_abreg =~ s/$item/$pattern/g; }
        else
          { $nom_abreg =~ s/$item/\#$abrev\#/g; }
      
        $nb_conv ++;
        
        # preparation recherche suivante
        $_ = $nom_abreg; study;
      }
    }
    
    # supression des termes superflus
    $nom_abreg = purge_termes_superflus($nom_abreg);
    
    # remplacement des separateurs si imposes
    if ($mode_sep_souligne)
      { $nom_abreg =~ s/-/_/g;  $nom_abreg =~ s/\./__/g;}
  }
  
  if (! $mode_cmd)
  {
    # ajout dans la table des noms d'attributs
    $htabl_attrb{$nom_norm} = $nom_abreg;
  }
  else
  {
  	if ($mode_bavard)
	  { print "Libelle a convertir: [$nom_norm] ==> [$nom_abreg]\n\n"; }
  	else
	  { print "$nom_abreg\n"; }
  }
}

# ____________________________________________________________
# SUB: print_sort_attrs ( )

sub print_sort_attrs
{
  my @keys;
  my $key;

  # tri en memoire des noms d'attributs generes
  # pour alimentation du fichier associe
  foreach $key (sort(keys %htabl_attrb))
  { print $hdl_result "$key=$htabl_attrb{$key}\n"; }
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  if ($mode_bavard)
  {
		print "\nElements traites :\t\t\t$nb_result\n";
  	
	  print "Conversions effectuees :\t\t$nb_conv\n";
	}
}

# ____________________________________________________________
# SUB: purge_libelle_origine ( libelle ) --> libelle

# Filtre AVANT TRAITEMENT le libelle d'origine passe en argument,
# et retourne un libelle utilisable pour la generation des noms courts.

# sub purge_libelle_origine
# {
  # my ($libelle) = @_;
  
  # # passage en minuscule
  # $libelle = lc($libelle);
  
  # # remplacement des separateurs genants
  # $libelle =~ s/[-_]/ /g;
  
  # # preparation des separateurs valables pour recuperation ulterieure
  # $libelle =~ s/\:\:/\./g;
  # $libelle =~ s/\:/\./g;
  
  # # remplacement des caracteres non textuels par des espaces
  # $libelle =~ s/[\"\'\/\!\?\[\]\,\;\\]/ /g;
  
  # # traduction des caracteres accentues
  # $libelle =~ tr/éêèàâûüùôöçîï/eeeaauuuoocii/;
  
  # # suppression des trucs bizarres...
  # $libelle =~ s/\.\.\.//g;
  
  # # suppression des espaces en trop
  # $libelle =~ s/\s+//g;
  
  # return $libelle;
# }

# ____________________________________________________________
# SUB: purge_termes_superflus ( libelle ) --> libelle

# Filtre APRES TRAITEMENT le libelle restant passe en argument,
# et retourne un libelle epures des termes superflus.

# sub purge_termes_superflus
# {
  # my ($libelle) = @_;
  
  # # supression des termes superflus
  # $libelle =~ s/\#(&e?)?s?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?$//g;
  # $libelle =~ s/\#&s\#/-/g;
  # $libelle =~ s/\#(&e?)?s?une?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?surune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?surl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?surd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?sur\#/-/g;
  # $libelle =~ s/\#(&e?)?s?pourune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?pourl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?pourd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?pour\#/-/g;
  # $libelle =~ s/\#(&e?)?s?parune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?parl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?pard(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?par\#/-/g;
  # $libelle =~ s/\#(&e?)?s?ouune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?oul(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?oud(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?ou\#/-/g;
  # $libelle =~ s/\#(&e?)?s?l(es?|a)?(\#|$)/-/g;
  # $libelle =~ s/\#(&e?)?s?etune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?etl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?etd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?et\#/-/g;
  # $libelle =~ s/\#(&e?)?s?entreune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?entrel(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?entred(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?entre\#/-/g;
  # $libelle =~ s/\#(&e?)?s?enune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?en\#/-/g;
  # $libelle =~ s/\#(&e?)?s?d(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?dune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?dansune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?dansl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?dansd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?dans\#/-/g;
  # $libelle =~ s/\#(&e?)?s?chezune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?chezl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?chezd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?chez\#/-/g;
  # $libelle =~ s/\#(&e?)?s?aux?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?avecune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?avecl(es?|a)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?avecd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?avec\#/-/g;
  # $libelle =~ s/\#(&e?)?s?aupresdune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?aupresd(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?aune?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?ala\#/-/g;
  # $libelle =~ s/\#(&e?)?s?ad(u|e(s|la?)?)?\#/-/g;
  # $libelle =~ s/\#(&e?)?s?a\#/-/g;
  # $libelle =~ s/\#(&e?)?s?(\d+)([-a-z_]+)/-$2\#$3/g;
  # $libelle =~ s/([-A-Z0-9_]+)\#(&e?)?s?(\d+)\#([-A-Z0-9_]+)/$1-$3-$4/g;
  # $libelle =~ s/\#(&e?)?s?(\d+)$/-$2/g;
  # $libelle =~ s/(&e?)?s?\./\./g;
  # $libelle =~ s/(&e?)?s?$//g;
  # $libelle =~ s/&s$//g;
  # $libelle =~ s/([A-Z])\.\#(0?[A-Z])/$1\.$2/g;
  # $libelle =~ s/([A-Z])\#\.(0?[A-Z])/$1\.$2/g;
  # $libelle =~ s/([a-z])\.\#([a-z])/$1\.$2/g;
  # $libelle =~ s/([a-z])\#\.([a-z])/$1\.$2/g;
  # $libelle =~ s/^\#//g;
  # $libelle =~ s/\#$//g;
  # $libelle =~ s/\#\.\#/\./g;
  # $libelle =~ s/^\.//g;
  # $libelle =~ s/\.$//g;
  # $libelle =~ s/^-//g;
  # $libelle =~ s/-$//g;
  
  # return $libelle;
# }

# ____________________________________________________________

if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_src_except) { undef $hdl_src_except; }
if (defined $hdl_src_attr) { undef $hdl_src_attr; }
if (defined $hdl_src_abrev) { undef $hdl_src_abrev; }

# ____________________________________________________________
