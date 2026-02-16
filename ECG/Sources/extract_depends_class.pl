# ____________________________________________________________
#
# Script d'extraction des dependances entre classes
# ____________________________________________________________
# ==> $Workfile: extract_depends_class.pl $
# ==> $Date: 12/12/12 $
# ==> $Author: Mtoledano $
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies

use IO::File;

use Data::Dumper;

use strict "vars";
#use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des arguments de la ligne de commande
my $path_tmp = $ENV{ECGTempDir};
my $path_src = $ENV{ECGFichUses};

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_result = $ENV{ECGFichDepends};

my $nb_classes = 0;
my $nb_packages = 0;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src = new IO::File $path_src, O_RDONLY;
unless (defined $hdl_src)
{ die "$nom_cmd: Ouverture fichier des dependances incorrecte ($path_src)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier du graphe d'appel incorrecte ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

my %htab_ident_classes;   # HashTable: [NomClasse] ==> [NomClasseQualifie]
my %htab_ident_packages;  # HashTable: [NomPackage] ==> [NomPackageQualifie]
my %htab_package_class;   # HashTable: [NomClasse] ==> [NomPackage]
my %hltab_packages;       # HashTable de Liste: [NomPackage] ==> [NomClasse] ...
my %hltab_packages_uses;  # HashTable de Liste: [NomPackage] ==> [NomPackageUtilise] ...
my %hltab_classes_uses;   # HashTable de Liste: [NomClasse] ==> [NomClasseUtilisee=TypeLien] ...
my @tltab_level_packages; # Table de Liste: [Niveau] ==> [NomPackage] ...
my @tltab_level_classes;  # Table de Liste: [Niveau] ==> [NomClasse] ...

my $sep = " -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-\n";

autoflush STDOUT 1;

print "\nRecuperation des dependances ...\n\n";

load_class_uses();

compute_packages_uses();

print_sort_package_uses();

print_sort_class_uses();

purge_self_class_uses();

print "\nReconstruction du graphe d'appel ...\n\n";

extract_no_declare();

extract_depends_packages(1);

extract_depends_classes(1);

print_sort_levels();

print_sort_package_uses();

print_sort_class_uses();

print_parse_infos();

if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_src) { undef $hdl_src; }

# ____________________________________________________________
# SUB: load_class_uses

# Rappel des types de dependances supportes :
#
# Association double ==> "ASCD"
# Association simple ==> "ASCS"
# Attribut ==> "ATRB"
# Declaration ==> "DECL"
# Implementation ==> "IMPL"
# Heritage ==> "HERT"
# Appel de methode ==> "METH"
# Parametre ==> "PRMT"

sub load_class_uses
{
  my $line;

  # lecture du fichier des utilisations entre classes
  while ($line = $hdl_src->getline)
  {
    # ------------------------- #
    # ATTENTION: separateur '|' #
    # ------------------------- #
    
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if (! /^\s*$/)
    {
      # recuperation des trois premiers champs et des parametres complementaires
      my ($type, $name, $qualifiedname, $parameters) = split(/\|/, $line, 4);
      
      # traitements spécifiques des balises rencontrées
      $_ = $type;
      if (/^DECL$/)
      { declare_class($name, $qualifiedname, $parameters); }
      
      elsif (/^(ASCD|ASCS|ATRB|HERT|IMPL|METH|PRMT)$/)
      { declare_use($name, $qualifiedname, $type, $parameters); }
      
      else
      { print_exit_error("Erreur: Type d'utilisation incorrect recupere ($type)\n"); }
    }
  }
}

# ____________________________________________________________
# SUB: declare_class

sub declare_class
{
  my ($name, $qualifiedname, $parameters) = @_;
  
  # recherche d'une classe existante dans la hashtable dediee
  if (! exists($htab_ident_classes{$name}))
  {
    # ajout de l'element concerne
    $htab_ident_classes{$name} = "$qualifiedname";
    
    # declaration du package englobant
    declare_package($name, $qualifiedname, $parameters);
  }
  else
  {
    # traitement d'erreur si les noms qualifies sont differents
    if ("$htab_ident_classes{$name}" ne "$qualifiedname")
    { print_exit_error("Erreur: Noms qualifies incompatibles sur classe ($name):\n\n\t[$qualifiedname]\n\n\t[$htab_ident_classes{$name}]\n\n"); }
  }
  
  $nb_classes++;
}

# ____________________________________________________________
# SUB: declare_package

sub declare_package
{
  my ($name, $qualifiedname, $parameters) = @_;
  my @list_class;
  
  # recuperation des deux derniers champs
  my ($pckg_name, $pckg_qualifiedname) = split(/\|/, $parameters, 2);
  
  # recherche d'un package existant dans la hashtable dediee
  if (! exists($htab_ident_packages{$pckg_name}))
  {
    # ajout de l'element concerne
    $htab_ident_packages{$pckg_name} = "$pckg_qualifiedname";
    
    $nb_packages++;
  }
  
  # traitement d'erreur si les noms qualifies sont differents
  elsif ("$htab_ident_packages{$pckg_name}" ne "$pckg_qualifiedname")
  { print_exit_error("Erreur: Noms qualifies incompatibles sur package ($pckg_name):\n\n\t[$pckg_qualifiedname]\n\n\t[$htab_ident_packages{$pckg_name}]\n\n"); }
    
  # declaration de la liaison package <=> classe
  if (! exists($hltab_packages{$pckg_name}))
  {
    # initialisation de la liste des classes du package
    @list_class = ( "$name" );
  }
  
  else
  {
    # recuperation de la liste des classes declarees pour le package
    @list_class = @{$hltab_packages{$pckg_name}};
    
    # ajout de la liste des classes du package
    push @list_class, "$name";
  }
  
  # actualisation de la liste des classes du package
  $hltab_packages{$pckg_name} = [ @list_class ];
  
  # reciproquement, declaration du package associe a la classe
  $htab_package_class{$name} = "$pckg_name";
}

# ____________________________________________________________
# SUB: declare_use

sub declare_use
{
  my ($name, $qualifiedname, $type, $parameters) = @_;
  my @list_uses;
  
  # recuperation des deux derniers champs
  my ($class_name, $class_qualifiedname) = split(/\|/, $parameters, 2);
  
  # declaration de l'utilisation de la classe
  if (! exists($hltab_classes_uses{$name}))
  {
    # initialisation de la liste des utilisations de la classe
    @list_uses = ( "$class_name=$type" );
  }
  
  else
  {
    my $class_found = 0;
    
    # boucle sur chacune des classes liees
    foreach my $class_uses (@{$hltab_classes_uses{$name}})
    {
      if (! $class_found)
      {
        # recuperation de la classe et des differents types d'utilisations
        my ($class_linked, $all_types) = split(/=/, $class_uses);
        
        # traitement par rapport au nom de la classe recherchee
        if ("$class_linked" eq "$class_name")
        {
          $class_found = 1;
          my $type_found = 0;
          
          # boucle sur les types d'utilisations
          foreach my $type_use (split(/\+/, $all_types))
          {
            # test par rapport au type d'utilisation recherche
            if ("$type_use" eq "$type")
            { $type_found = 1; }
          }
          
          # traitement si le type recherche n'a pas ete trouve
          if (! $type_found)
          {
            # reconstitution de la nouvelle liste des types
            $class_uses .= "+$type";
          }
          
          # reconstitution du coeur de liste
      	  push @list_uses, "$class_uses";
        }
        
        # reconstitution du debut de liste
      	else
      	{ push @list_uses, "$class_uses"; }
      }
      
      # reconstitution de la fin de liste
      else
      { push @list_uses, "$class_uses"; }
    }
    
    # ajout si aucune utilisation trouve pour la classe recherchee
    if (! $class_found)
    { push @list_uses, "$class_name=$type"; }
  }
  
  # mise a jour de la hash table dediee
  $hltab_classes_uses{$name} = [ @list_uses ];
}
  
# ____________________________________________________________
# SUB: compute_packages_uses

sub compute_packages_uses
{
  # boucle sur les utilisations entre classes
  foreach my $class (keys %hltab_classes_uses)
  {
    # recuperation du package courant, pour mise a jour des utilisations
    my $pckg = $htab_package_class{$class};
    
    # boucle sur chacune des classes liees
    foreach my $class_used (@{ $hltab_classes_uses{$class} })
    {
      # recuperation de la classe liee et des differents types d'utilisations
      my ($class_linked, $all_types) = split(/=/, $class_used);
      
      # recuperation du package associe a la classe liee
      my $pckg_used = $htab_package_class{$class_linked};
      
      # declaration de la nouvelle utilisation, si packages distincts
      if (("$pckg_used" ne "") && ("$pckg_used" ne "$pckg"))
      {
        if (! (exists $hltab_packages_uses{$pckg}))
        { $hltab_packages_uses{$pckg} = [ "$pckg_used" ]; }
        
        else
        {
          my $pckg_found = 0;
          
          # parcours des packages lies pour ajout si non present
          foreach my $pckg_linked (@{ $hltab_packages_uses{$pckg} })
          {
            # comparaison des noms de packages
            if ("$pckg_linked" eq "$pckg_used")
            { $pckg_found = 1; }
          }
          
          # ajout si pas trouve
          if (! $pckg_found)
          { push @{ $hltab_packages_uses{$pckg} }, "$pckg_used"; }
        }
      }
    }
  }
}

# ____________________________________________________________
# SUB: purge_self_class_uses

sub purge_self_class_uses
{
 	# boucle sur les utilisations pour suppression des utilisations reflexives
  foreach my $class (keys %hltab_classes_uses)
  {
    my @list_uses;
    
    # boucle sur chacune des classes liees
    foreach my $class_used (@{ $hltab_classes_uses{$class} })
    {
      # recuperation de la classe liee et des differents types d'utilisations
      my ($class_linked, $all_types) = split(/=/, $class_used);
      
  	  # reconduction, a l'identique, de l'utilisation
      if ("$class_linked" ne "$class")
      { push @list_uses, "$class_used"; }
    }
    
    # suppression de la declaration d'utilisation, si vide
    if ($#list_uses == -1)
    { $hltab_classes_uses{$class} = (); }
    
    # sinon, actualisation de la liste des utilisations
    else
    { $hltab_classes_uses{$class} = [ @list_uses ]; }
  }
}

# ____________________________________________________________
# SUB: extract_no_declare

sub extract_no_declare
{
 	my $level;
  my @list_uses;
	
	# traitement des utilisations entre packages
 	$level = 0;
 	
  # si besoin, ajout d'un nouveau niveau au tableau dedie
 	if ($#tltab_level_packages < $level)
 	{ $tltab_level_packages[++$#tltab_level_packages] = ( ); }
 	
 	# boucle sur les utilisations pour suppression des packages non declares
  foreach my $pckg (keys %hltab_packages_uses)
  {
    # boucle sur chacun des packages lies
    foreach my $pckg_used (@{ $hltab_packages_uses{$pckg} })
    {
      # suppression de l'utilisation si package non declare
      if (! (exists $htab_ident_packages{$pckg_used}))
      {
  	  	# ajout du package trouve a la liste du niveau courant
  	  	push @{ $tltab_level_packages[$level] }, "$pckg_used";
      }
    }
  }
	
	# traitement des utilisations entre classes
 	$level = 0;
 	
  # si besoin, ajout d'un nouveau niveau au tableau dedie
 	if ($#tltab_level_classes < $level)
 	{ $tltab_level_classes[++$#tltab_level_classes] = ( ); }
 	
 	# boucle sur les utilisations pour suppression des classes non declarees
  foreach my $class (keys %hltab_classes_uses)
  {
    # boucle sur chacune des classes liees
    foreach my $class_used (@{ $hltab_classes_uses{$class} })
    {
      # recuperation de la classe et des differents types d'utilisations
      my ($class_linked, $all_types) = split(/=/, $class_used);
      
      # suppression de l'utilisation si classe non declaree
      if (! (exists $htab_ident_classes{$class_linked}))
      {
  	  	# ajout de la classe trouvee a la liste du niveau courant
  	  	push @{ $tltab_level_classes[$level] }, "$class_linked";
      }
    }
  }
}

# ____________________________________________________________
# SUB: extract_depends_packages

sub extract_depends_packages
{
  my ($level) = @_;
	my $nbe_level_depends = 0;
	my $pckg;
	
 	# si besoin, ajout d'un nouveau niveau au tableau dedie
 	if ($#tltab_level_packages < $level)
 	{ $tltab_level_packages[++$#tltab_level_packages] = ( ); }
 	
 	# boucle sur les packages du niveau precedent (si niveau > 0), pour purge
	if ($level > 0)
	{
  	foreach $pckg (@{ $tltab_level_packages[$level - 1] })
  	{
	  	# suppression du package dans les utilisations des autres packages
	  	delete_package_in_uses($pckg);
	    
	    # suppression du package de la liste des utilisations
	    delete $hltab_packages_uses{$pckg};
	    
	    # suppression du package de la liste des packages declares
	    delete $htab_ident_packages{$pckg};
    }
  }

	# boucle sur les packages pour recuperation de ceux sans dependances
	foreach $pckg (keys %htab_ident_packages)
	{
	  # si aucune utilisation trouvee, ajout au niveau courant
	  if ((! (exists $hltab_packages_uses{$pckg})) || ("$hltab_packages_uses{$pckg}->[-1]" eq ""))
	  {
	  	# ajout du package trouve a la liste du niveau courant
	  	push @{ $tltab_level_packages[$level] }, "$pckg";
	    
	    $nbe_level_depends ++;
    }
  }
 	
  # poursuite des traitements
 	if ($nbe_level_depends)
	{
	  extract_depends_packages(++ $level);
	}
}

# ____________________________________________________________
# SUB: extract_depends_classes

sub extract_depends_classes
{
  my ($level) = @_;
	my $nbe_level_depends = 0;
	my $class;
	
 	# si besoin, ajout d'un nouveau niveau au tableau dedie
 	if ($#tltab_level_classes < $level)
 	{ $tltab_level_classes[++$#tltab_level_classes] = ( ); }
 	
 	# boucle sur les classes du niveau precedent (si niveau > 0), pour purge
	if ($level > 0)
	{
  	foreach $class (@{ $tltab_level_classes[$level - 1] })
  	{
	  	# suppression de la classe dans les classes a traiter du package
	  	delete_class_in_package($class);
	  	
	  	# suppression de la classe dans les utilisations des autres classes
	  	delete_class_in_uses($class);
	    
	    # suppression de la classe de la liste des utilisations
	    delete $hltab_classes_uses{$class};
	    
	    # suppression de la classe de la liste des classes declarees
	    delete $htab_ident_classes{$class};
    }
  }
 	
	# boucle sur les classes pour recuperation de celles sans dependances
	foreach $class (keys %htab_ident_classes)
	{
	  # si aucune utilisation trouvee, ajout au niveau courant
	  if ((! (exists $hltab_classes_uses{$class})) || ("$hltab_classes_uses{$class}->[-1]" eq ""))
	  {
	  	# ajout de la classe trouvee a la liste du niveau courant
	  	push @{ $tltab_level_classes[$level] }, "$class";
	    
	    $nbe_level_depends ++;
    }
  }
 	
  # poursuite des traitements
 	if ($nbe_level_depends)
	{
	  extract_depends_classes(++ $level);
	}
}

# ____________________________________________________________
# SUB: delete_class_in_package

sub delete_class_in_package
{
  my ($search_class) = @_;
	my $pckg_name = $htab_package_class{$search_class};
	my @list_class;
  
  foreach my $pckg_class (@{$hltab_packages{$pckg_name}})
  {
    # si pas classe recherchee, ajout a la future liste
    if ("$pckg_class" ne "$search_class")
    { push @list_class, "$pckg_class"; }
  }
  
  # suppression de la declaration du package, si vide
  if ($#list_class == -1)
  { delete $hltab_packages{$pckg_name}; }
  
  # sinon, actualisation de la liste des classes du package
  else
  { $hltab_packages{$pckg_name} = [ @list_class ]; }
}

# ____________________________________________________________
# SUB: delete_package_in_uses

sub delete_package_in_uses
{
  my ($search_pckg) = @_;
  
  # boucle sur les packages declares
  foreach my $pckg (keys %htab_ident_packages)
  {
    my @list_uses;
    
    # boucle sur chacun des packages lies
    foreach my $pckg_used (@{ $hltab_packages_uses{$pckg} })
    {
      # traitement par rapport au nom du package recherche
      if ("$pckg_used" ne "$search_pckg")
      { push @list_uses, "$pckg_used"; }
    }
    
    # suppression de la declaration d'utilisation, si vide
    if ($#list_uses == -1)
    { $hltab_packages_uses{$pckg} = (); }
    
    # sinon, actualisation de la liste des utilisations
    else
    { $hltab_packages_uses{$pckg} = [ @list_uses ]; }
  }
}

# ____________________________________________________________
# SUB: delete_class_in_uses

sub delete_class_in_uses
{
  my ($search_class) = @_;
  
  # boucle sur les classes declarees
  foreach my $class (keys %htab_ident_classes)
  {
    my @list_uses;
    
    # boucle sur chacune des classes liees
    foreach my $class_used (@{ $hltab_classes_uses{$class} })
    {
      # recuperation de la classe liee et des differents types d'utilisations
      my ($class_linked, $all_types) = split(/=/, $class_used);
      
      # traitement par rapport au nom de la classe recherchee
      if ("$class_linked" eq "$search_class")
      {
        my $result_types = "";
        
        # boucle sur les types d'utilisations
        foreach my $type_use (split(/\+/, $all_types))
        {
          # conservation du type d'utilisation uniquement si association double
          if ("$type_use" eq "ASCD")
          { $result_types = "ASCD"; }
        }
        
        # actualisation du type si une utilisation subsiste
        if ("$result_types" ne "")
        { push @list_uses, "$class_linked=$result_types"; }
    	}
    	
    	else
      { push @list_uses, "$class_used"; }
    }
    
    # suppression de la declaration d'utilisation, si vide
    if ($#list_uses == -1)
    { $hltab_classes_uses{$class} = (); }
    
    # sinon, actualisation de la liste des utilisations
    else
    { $hltab_classes_uses{$class} = [ @list_uses ]; }
  }
}

# ____________________________________________________________
# SUB: print_sort_class_uses

sub print_sort_class_uses
{
  my $key1;
  my $key2;

  print  $hdl_result "\n$sep\n";
  
  print $hdl_result "Packages :\n";
  
  foreach $key1 (sort (keys %hltab_packages))
  {
    print $hdl_result "\n\t[$key1]";
    
    my @tab = @{ $hltab_packages{$key1} };
    
    my $cpt = 0;
    
    foreach $key2 (@tab)
    {
    	if (! $cpt)
    	{ $cpt = 1; print $hdl_result "\t==> [$key2]"; }
    	
    	else
    	{ print $hdl_result " [$key2]"; }
    }
    
    print $hdl_result "\n";
  }

  print  $hdl_result "\n$sep\n";
  
  print $hdl_result "Utilisations inter-classes :\n";
  
  foreach $key1 (sort (keys %hltab_classes_uses))
  {
    print $hdl_result "\n\t[$key1]";
    
    my @tab = @{ $hltab_classes_uses{$key1} };
    
    my $cpt = 0;
    
    foreach $key2 (@tab)
    {
    	if (! $cpt)
    	{ $cpt = 1; print $hdl_result "\t==> [$key2]"; }
    	
    	else
    	{ print $hdl_result " [$key2]"; }
    }
    
    print $hdl_result "\n";
  }
}

# ____________________________________________________________
# SUB: print_sort_package_uses

sub print_sort_package_uses
{
  my $key1;
  my $key2;
  
  print  $hdl_result "\n$sep\n";
  
  print $hdl_result "Utilisations inter-packages :\n";
  
  foreach $key1 (sort (keys %hltab_packages_uses))
  {
    print $hdl_result "\n\t[$key1]";
    
    my @tab = @{ $hltab_packages_uses{$key1} };
    
    my $cpt = 0;
    
    foreach $key2 (@tab)
    {
    	if (! $cpt)
    	{ $cpt = 1; print $hdl_result "\t==> [$key2]"; }
    	
    	else
    	{ print $hdl_result " [$key2]"; }
    }
    
    print $hdl_result "\n";
  }
}

# ____________________________________________________________
# SUB: print_sort_levels

sub print_sort_levels
{
  my $ind = 0;
  
  print $hdl_result "\n$sep";
  
  while ($ind <= $#tltab_level_packages)
  {
    my $list_package = $tltab_level_packages[$ind];
    
    if ($#{ @{ $list_package } } != -1)
    { print $hdl_result "\nPackages niveau [$ind]:\n\n"; }
    
    my $cpt = 0;
    
    foreach my $package (sort @{$list_package})
    {
    	if (! $cpt)
    	{
    		$cpt = 1;
    		print $hdl_result "\t==> [$package]";
    	}
    	
    	else
    	{
    		print $hdl_result " [$package]";
    	}
    }
    
    if ($#{ @{ $list_package } } != -1)
    { print $hdl_result "\n"; }
    
    $ind ++;
  }
  
  $ind = 0;
  
  print  $hdl_result "\n$sep";
  
  while ($ind <= $#tltab_level_classes)
  {
    my $list_class = $tltab_level_classes[$ind];
    
    if ($#{ @{ $list_class } } != -1)
    { print $hdl_result "\nClasses niveau [$ind]:\n\n"; }
    
    my $cpt = 0;
    
    foreach my $class (sort @{$list_class})
    {
    	if (! $cpt)
    	{
    		$cpt = 1;
    		print $hdl_result "\t==> [$class]";
    	}
    	
    	else
    	{
    		print $hdl_result " [$class]";
    	}
    }
    
    if ($#{ @{ $list_class } } != -1)
    { print $hdl_result "\n"; }
    
    $ind ++;
  }
}

# ____________________________________________________________
# SUB: print_parse_infos

sub print_parse_infos
{
  print $hdl_result "\n$sep";
  
  print "\nNombre de packages :\t$nb_packages\n";
  print $hdl_result "\nNombre de packages :\t$nb_packages\n";
  
  print "Nombre de classes :\t$nb_classes\n";
  print $hdl_result "Nombre de classes :\t$nb_classes\n";
}

# ____________________________________________________________
# SUB: print_exit_error

sub print_exit_error
{
  my ($msg) = @_;
  
  print "\nErreur: $msg\n\n";
  
  if (defined $hdl_result) { undef $hdl_result; }
  if (defined $hdl_src) { undef $hdl_src; }
  
  exit(-1);
}

# ____________________________________________________________
