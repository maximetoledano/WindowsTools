# ____________________________________________________________
#
# Script de generation de codes sources a partir de templates
# parametrables.
# ____________________________________________________________
# ==> $Workfile: gen_codes_sources.pl $
# ==> $Revision: 4 $
# ==> $Date: 16/12/02 14:38 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GCS/gen_codes_sources.pl $
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies standard

use IO::File;
use File::Copy;

use File::Find;

use DirHandle;

use strict "vars";
#use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des elements specifiques de l'environnement
my $path_tmp = $ENV{GCSTempDir};
my $path_list_tpl = $ENV{GCSFichListTpl};
my $path_decl_var = $ENV{GCSFichDeclVarGen};
my $path_result = $ENV{GCSFichCodesGen};

my $nb_result = 0;

# ____________________________________________________________
# Preparation des fichiers

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$path_list_tpl =~ s/\"//g;
$path_decl_var =~ s/\"//g;
$path_result =~ s/\"//g;

my $hdl_result;
$hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier de code resultat incorrecte ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

# hash-table des templates (portions de codes incluant les
# balises de variables)
#   cle = nom de template
#   valeur = code associé
my %htabl_templates;

my $nb_templates = 0;

load_all_templates();

load_decl_var();

print "\n";

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_all_templates ( )

sub load_all_templates
{
  my $line;
  my $nom_tpl;
  my $path_tpl;
  
  my $hdl_list_tpl = new IO::File $path_list_tpl, O_RDONLY;
  unless (defined $hdl_list_tpl)
  { die "$nom_cmd: Fichier des noms de templates incorrecte ($path_list_tpl)\n"; }
  
  $/ = "\n";
  
  # chargement en memoire des masques sur elements a extraire
  while ($line = $hdl_list_tpl->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;

    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # ----------------------------- #
      # Format des lignes: 'nom=path' #
      # ----------------------------- #
      
      ($nom_tpl, $path_tpl) = split(/=/, $line, 2);
      
      # epuration des espaces indesirables
      $nom_tpl =~ s/\s*//g;
      $path_tpl =~ s/^\s*//; $path_tpl =~ s/\s*$//;
      
      if (("$nom_tpl" ne "") and ("$path_tpl" ne ""))
      {
        if (exists $htabl_templates{$nom_tpl})
        { die "$nom_cmd: Doublon rencontre dans fichier de declaration des templates ($nom_tpl)\n"; }
        
        else
        { load_template_code($nom_tpl, $path_tpl); }
      }
      else
      { die "$nom_cmd: Parametrage des nom/path de templates incorrect ($line)\n"; }
    }
  }
  
  if (defined $hdl_list_tpl) { undef $hdl_list_tpl; }
}

# ____________________________________________________________
# SUB: load_template_code ( nom_tpl, path_tpl )

sub load_template_code
{
  my ($nom_tpl, $path_tpl) = @_;
  my $hdl_tpl;
  my $code_tpl;
  
  # ouverture pour lecture du fichier template
  $hdl_tpl = new IO::File $path_tpl, O_RDONLY;
  unless (defined $hdl_tpl)
  { die "$nom_cmd: Ouverture fichier template incorrecte ($path_tpl)\n"; }

  # preparation d'une lecture d'une traite du fichier
  undef $/;
  
  # chargement en memoire des masques sur fichiers sources
  while ($code_tpl = $hdl_tpl->getline)
  {
    # suppression fin de ligne Windows
    chomp $code_tpl;
    
    $htabl_templates{$nom_tpl} = "$code_tpl";
    
    $nb_templates ++;
  }
  
  # restauration du mode de lecture par ligne
  $/ = "\n";
  
  # fermeture du fichier ouvert
  if (defined $hdl_tpl) { undef $hdl_tpl; }
}

# ____________________________________________________________
# SUB: load_decl_var ( )

sub load_decl_var
{
  my $line;
  my $hdl_decl_var;
  my $nom_tpl;
  my $var_tpl;
  
  $hdl_decl_var = new IO::File $path_decl_var, O_RDONLY;
  unless (defined $hdl_decl_var)
  { die "$nom_cmd: Fichier de declaration des variables incorrecte ($path_decl_var)\n"; }
  
  $/ = "\n";

  # chargement des enchainements de traitement
  while ($line = $hdl_decl_var->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # ------------------------------------------------ #
      # Format des lignes: 'nom|var1=vla1|...|varN=valN' #
      # ------------------------------------------------ #
      
      ($nom_tpl, $var_tpl) = split(/\|/, $line, 2);
      
      if ("$nom_tpl" ne "")
      {
        if (exists $htabl_templates{$nom_tpl})
        {
        	gen_code_template($nom_tpl, $var_tpl);
        }
        
        else
        { die "$nom_cmd: Mauvais template dans fichier de declaration des variables ($nom_tpl)\n"; }
      }
    }
  }
  
  if (defined $hdl_decl_var) { undef $hdl_decl_var; }
}

# ____________________________________________________________
# SUB: gen_code_template ( nom_tpl, list_var )

sub gen_code_template
{
  my ($nom_tpl, $list_var) = @_;
  my $code;
  my $elt_list;
  my $nom_var;
  my $val_var;
  my $str_subst;
  
  # copie de travail du code du template
  $code = $htabl_templates{$nom_tpl};
  
  # recuperation et remplacement des couples variable/valeur
  foreach $elt_list (split(/\|/, $list_var))
  {
    ($nom_var, $val_var) = split(/=/, $elt_list, 2);
    
    #$_ = $code; study;
    
    #$str_subst = "\$code =~ s/@<$nom_var>@/$val_var/g";
    
    #eval $str_subst;
    
    $code =~ s/\@\<$nom_var\>\@/$val_var/g;
  }
  
  # ajout du code transforme au fichier resultat
  print $hdl_result "$code\n";
}

# ____________________________________________________________

if (defined $hdl_result) { undef $hdl_result; }

# ____________________________________________________________
