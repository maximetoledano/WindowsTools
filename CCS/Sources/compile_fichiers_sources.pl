# ____________________________________________________________
#
# Script de compilation de fichiers de sources pour encodage et
# optimisation des flux echanges.
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies standard

use IO::File;
use IO::Dir;
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
my $path_rep_src_files = $ENV{CCSRepSources};
my $path_rep_cpl_files = $ENV{CCSRepFichCompil};
my $path_list_src_files = $ENV{CCSFichListSrcFiles};
my $path_mask_src_files = "";
my $path_mask_src_tags = "";
my $path_result = $ENV{CCSFichResult};
my $path_tmp_src = $ENV{CCSFichTmpSrc};
my $path_tmp_1 = $ENV{CCSFichTmp1};
my $path_tmp_2 = $ENV{CCSFichTmp2};

my $nb_result = 0;

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$path_rep_src_files =~ s/\"//g;
$path_rep_cpl_files =~ s/\"//g;
$path_list_src_files =~ s/\"//g;
$path_mask_src_files =~ s/\"//g;
$path_result =~ s/\"//g;
$path_tmp_src =~ s/\"//g;
$path_tmp_1 =~ s/\"//g;
$path_tmp_2 =~ s/\"//g;

# ____________________________________________________________
# Corps du programme

# tableau des paths de fichiers candidats
my @atabl_files;

# tableau des masques communs a toutes les tags
# pour preparation initiale du fichier source
my @atabl_globtags;

# tableau des masques facultatifs pour restriction
# stricte du fichier source aux seuls resultats obtenus
my @atabl_globtags_result_only;

# hash-table des masques (expressions regulieres)
#   cle = type de masque
#   valeur = tableau des couples 'position + masque' ou triplets 'code + position + masque'
my %htabl_tags;

my $nb_globtags_result_only = 0;
my $nb_globtags = 0;
my $nb_tags = 0;
my $nb_masks = 0;
my $nb_files = 0;

my $sep_result = "\n-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-\n";

autoflush STDOUT 1;

purge_old_compil_files();

load_masks();

load_src_files();

parse_all_files();

# ____________________________________________________________
# SUB: purge_old_compil_files ( )

sub purge_old_compil_files
{
  my $hdl_rep_cpl;
  my $hdl_file_cpl;
  
  # initialisation du handle de parcours du repertoire
  $hdl_rep_cpl = new IO::Dir $path_rep_cpl_files;
  
  if (defined $hdl_rep_cpl)
  {
    # suppression du repertoire complet
    $hdl_rep_cpl -> unlink;
  }
}

# ____________________________________________________________
# SUB: load_masks ( )

sub load_masks
{
  my $hdl_mask_src_tags;
  my $line;
  
  # traitement des masques sur elements a extraire
  $hdl_mask_src_tags = new IO::File $path_mask_src_tags, O_RDONLY;
  unless (defined $hdl_mask_src_tags)
  { die "$nom_cmd: Masques des elements de sources a extraire incorrecte ($path_mask_src_tags)\n"; }

  $/ = "\n";

  # chargement en memoire des masques sur elements a extraire
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
      # Format des lignes: '%=eval_expr' #
      # -------------------------------- #
      if (/^\s*\%=(.+)$/)
      {
        # ajout de l'expression dans le tableau dedie aux initialisations strictes
        push @atabl_globtags_result_only, "$1";
        $nb_globtags_result_only ++;
      }
      
      # -------------------------------- #
      # Format des lignes: '*=eval_expr' #
      # -------------------------------- #
      elsif (/^\s*\*\s*=(.+)$/)
      {
        # ajout de l'expression dans le tableau des tags d'initialisation
        push @atabl_globtags, "$1";
        $nb_globtags ++;
      }
      
      # --------------------------------- #
      # Format des lignes: 'tag|pos=mask' #
      # --------------------------------- #
      else
      {
        $regexp_parse = "^([a-z][a-z0-9_]*)\\|([0-9][0-9]*)=(.+)\$";
        study $regexp_parse;
        
        ($tag = $line) =~ s/$regexp_parse/$1/i;
        
        ($pos_tag = $line) =~ s/$regexp_parse/$2/i;
        
        ($mask = $line) =~ s/$regexp_parse/$3/i;
        
        if (("$tag" ne "") and ("$pos_tag" ne "") and ("$mask" ne ""))
        {
          # traitement des tags deja rencontres
          if (exists $htabl_tags{$tag})
          {
            push @{$htabl_tags{$tag}}, $pos_tag;
            push @{$htabl_tags{$tag}}, $mask;
          }
          
          # traitement des nouveaux tags
          else
          {
            my @atabl_masks;
            push @atabl_masks, $pos_tag;
            push @atabl_masks, $mask;
            $htabl_tags{$tag} = [ @atabl_masks ];
            $nb_tags ++;
          }
        }
        else
        { die "$nom_cmd: Parametrage des tags/masques incorrect ($line)\n"; }
      }
      
      $nb_masks ++;
    }
  }
  
  if (defined $hdl_mask_src_tags) { undef $hdl_mask_src_tags; }
}

# ____________________________________________________________
# SUB: load_src_files ( )

sub load_src_files
{
  my $hdl_list_src_files;
  my $line;

  $hdl_list_src_files = new IO::File $path_list_src_files, O_RDONLY;
  unless (defined $hdl_list_src_files)
  { die "$nom_cmd: Fichier des sources candidat incorrecte ($path_list_src_files)\n"; }

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
      
      # ajout au tableau pour traitement
      push @atabl_files, $line;
       
      $nb_files ++;
    }
  }
  
  if (defined $hdl_list_src_files) { undef $hdl_list_src_files; }
}

# ____________________________________________________________
# SUB: parse_all_files ( )

sub parse_all_files
{
  my $hdl_stdout;
  my $hdl_result;
  my $path_file;
  
  $hdl_stdout = select();
  
  $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
  unless (defined $hdl_result)
  { die "$nom_cmd: Creation fichier des sources trouves incorrecte ($path_result)\n"; }

  select ($hdl_result);
  
  print "\nMasques fichiers: $path_mask_src_files\n";
  print "Masques tags:     $path_mask_src_tags\n";
  
  foreach $path_file (@atabl_files)
  {
    select ($hdl_stdout);
    print " ==> [$path_file]\n";
    select ($hdl_result);
    
    # traitement effectif du fichier
    parse_src_file($hdl_result, $path_file);
  }
  
  print "\nSources traites: $nb_files\n";
  
  select ($hdl_stdout);
  
  print "\n";
  if ($nb_globtags_result_only > 0) { print "\t\t... $nb_globtags_result_only tags d'initialisation stricte\n"; }
  print "\t\t... $nb_globtags tags d'initialisation\n";
  print "\t\t... $nb_tags tags d'analyse\n";
  print "\t\t... $nb_masks masques\n";
  print "\t\t... $nb_files sources traites\n\n";
  
  if (defined $hdl_result) { undef $hdl_result; }
}

# ____________________________________________________________
# SUB: parse_src_file ( hdl_result, path_src_file )

sub parse_src_file
{
  my ($hdl_result, $path_src_file) = @_;
  my $path_result_tmp = $path_tmp_src;
  my $read_mode;
  my $abolute_path_rep_files;
  my $relative_path_src_file;
  my $tag;
  my $pos_tag;
  my $pos;
  my $mask;
  my $nb_elts;
  my $cpt;
  my $result;
  
  # memorisation du canal de sortie par defaut et du mode de lecture
  $read_mode = $/;
  
  # preparation d'une lecture d'une traite des fichiers
  undef $/;
  
  unlink $path_result_tmp;
  
  # recuperation du chemin relatif du fichier traite
  $abolute_path_rep_files = quotemeta $path_rep_src_files;
  ($relative_path_src_file = $path_src_file) =~ s/^$abolute_path_rep_files\/?//;
  
  # preparation du fichier source temporaire
  if (@atabl_globtags)
  {
    # initialisation d'un fichier temporaire supplementaire, si besoin est
    if ($nb_globtags_result_only > 0)
    { $path_result_tmp = $path_tmp_1; unlink $path_result_tmp; }
    
    my $hdl_travail = new IO::File $path_result_tmp, O_WRONLY|O_CREAT;
    unless (defined $hdl_travail)
    { die "$nom_cmd: Creation fichier temporaire incorrecte ($path_result_tmp)\n"; }
    
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
    
    select $hdl_result;
    
    if (defined $hdl_travail) { undef $hdl_travail; }
  }

  # prise en compte des eventuels masques stricts
  if ($nb_globtags_result_only > 0)
  {
    my $hdl_travail = new IO::File $path_tmp_src, O_WRONLY|O_CREAT;
    unless (defined $hdl_travail)
    { die "$nom_cmd: Creation fichier source temporaire incorrecte ($path_tmp_src)\n"; }
    
    select $hdl_travail;
    
    # ouverture du fichier temporaire precedent
    open(SOURCE, "< $path_result_tmp")
        or die "$nom_cmd: Ouverture fichier temporaire incorrecte ($path_result_tmp)\n";
    
    # preparation du fichier d'analyse, a partir du fichier source,
    # et par application des tags globaux
    while (<SOURCE>)
    {
      foreach $tag (@atabl_globtags_result_only)
      { $_ =~ s/^$tag$/print "$&\n"/geims; }
    }
    
    # fermeture du fichier ouvert
    close(SOURCE);
    
    select $hdl_result;
    
    if (defined $hdl_travail) { undef $hdl_travail; }
  }
  
  # balisage de l'analyse du source dans le fichier resultat
  print "\nAnalyse: [$path_src_file]\n";
  
  # boucle sur les tags memorises
  foreach $tag (keys %htabl_tags)
  {
    $nb_elts = @{$htabl_tags{$tag}};
    
    # pour chaque tag trouve, boucle sur les masques possibles
    if (($nb_elts % 2) == 0)
    {
      # initialisation de la copie de travail pour le tag courant
      unlink $path_tmp_1;
      copy($path_tmp_src, $path_tmp_1)
          or die "$nom_cmd: Initialisation de la copie de travail incorrecte ($path_tmp_1)\n";
      
      for ($cpt = 0; $cpt < $nb_elts; $cpt ++)
      {
        my $hdl_travail;
        
        # recuperation du couple position/masque
        $pos_tag = ${$htabl_tags{$tag}}[$cpt];
        $cpt ++;
        $mask = ${$htabl_tags{$tag}}[$cpt];
        
        unlink $path_tmp_2;
        $hdl_travail = new IO::File $path_tmp_2, O_WRONLY|O_CREAT;
        unless (defined $hdl_travail)
        { die "$nom_cmd: Creation de fichier resultat temporaire incorrecte ($path_tmp_2)\n"; }
        
        # ouverture du fichier pour analyse
        open(SOURCE, "< $path_tmp_1")
            or die "$nom_cmd: Ouverture copie de travail incorrecte ($path_tmp_1)\n";
        
        # recherche de l'expression dans le fichier lu
        while (<SOURCE>)
        {
          select $hdl_result;
          
          if(/$mask/ims)
          {
            if ($pos_tag ne "0")
            { $result = "${$pos_tag}"; print "[$result]\n"; }
          }
          
          # recopie du fichier modifie dans le resultat temporaire
          select $hdl_travail;
          select $hdl_result;
        }
        
        # fermeture du fichier ouvert
        close(SOURCE);
        
        # preparation de la copie de travail pour boucle suivante
        undef $hdl_travail;
        unlink $path_tmp_1;
        copy($path_tmp_2, $path_tmp_1)
            or die "$nom_cmd: Actualisation du fichier temporaire incorrecte ($path_tmp_1)\n";
        unlink $path_tmp_2;
      }
    }
    else
    { die "$nom_cmd: Erreur interne sur nombre de triplets code/position/masque ($tag)($nb_elts)\n"; }
  }
}

# ____________________________________________________________
