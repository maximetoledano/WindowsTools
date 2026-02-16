# ____________________________________________________________
#
# Script de reconstitution des mots candidats a partir du
# glossaire des abreviations normalisees
# ____________________________________________________________
# ==> $Workfile: reverse_abrev2word.pl $
# ==> $Revision: 3 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/GAN/reverse_abrev2word.pl $
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
my $path_src = $ENV{GANFichAbbrev};
my $opt_numligne = $ENV{GANGenNumLignes};

my $b_numligne = 0;
if ($opt_numligne eq "--numero")
{ $b_numligne = 1; }

if ($path_tmp eq "")
{ $path_tmp = "C:\Temp"; }

my $path_result = "$path_tmp/_reverse_abrev.txt";
my $path_reject = "$path_tmp/_reject_abrev.txt";

my $nb_result = 0;
my $nb_reject = 0;
my $nb_pattern = 0;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_src = new IO::File $path_src, O_RDONLY;
unless (defined $hdl_src)
{ die "$nom_cmd: Ouverture catalogue des abreviations incorrecte ($path_src)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des mots candidats incorrecte ($path_result)\n"; }

my $hdl_reject = new IO::File $path_reject, O_WRONLY|O_CREAT;
unless (defined $hdl_reject)
{ die "$nom_cmd: Creation fichier des abreviations rejetees incorrecte ($path_reject)\n"; }

# ____________________________________________________________
# Corps du programme

my %hltable_abrev;         # ATTENTION: HashTable de Liste !!!
my $level = 0;
my $numligne = 0;

print "\n";

load_abrev();

print_sort_reverse();

print_parse_infos();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_abrev ( )

sub load_abrev
{
  my $line;
  my $pattern;
  my $abrev;
  my @words;
  
  # les motifs constants pour les champs version et date
  my $msk_version = qw(^\s*\#+\s*version\s*:\s*(.*)\s*$);
  my $msk_date = qw(^\s*\#+\s*date\s*:\s*(.*)\s*$);

  # chargement en memoire des couples 'pattern/abreviation'
  while ($line = $hdl_src->getline)
  {
  	$numligne ++;
  	
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if ((! /^\s*$/) and (! /^\s*\#/))
    {
      # ------------------------- #
      # ATTENTION: separateur '=' #
      # ------------------------- #
      
      ($pattern, $abrev) = split(/=/, $line, 2);
      
      # pattern en miniscule, abrev a l'identique
      $pattern = lc($pattern);
      
      # suppression des caracteres '&e' eventuels
      # en fin de pattern (cas du feminin)
      $abrev =~ s/\&e$//;
      
      # generation des mots candidats a partir du pattern
      @words = parse_pattern("$pattern",$level);

      # rejet du pattern si pas de mots generes
      if (scalar @words)
      {
  	    my %htable_tmp;
        my $one_word = "";
       	my @list_words;
        
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      	# initialisation de la hash temporaire avec les mots
      	# candidats deja trouves
      	
        if (exists($hltable_abrev{$abrev}))
        {
        	my $one_item = "";
        	
          # -------------------------------- #
          # ATTENTION: separateur '<espace>' #
          # -------------------------------- #
          
        	foreach $one_item (@{$hltable_abrev{$abrev}})
        	{
            # ------------------------- #
            # ATTENTION: separateur ':' #
            # ------------------------- #
            
        		my ($word, $positions) = split(/:/, $one_item, 2);
        		
        		${htable_tmp{$word}} = $positions;
        	}
        }
        
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        # traitement des mots trouves a partir du pattern courant
        
        foreach $one_word (sort @words)
        {
        	# ajout si non deja dans hash temporaire (si deja trouve,
        	# la position est forcement apres et donc ignore)
        	if (! exists($htable_tmp{$one_word}))
        	{ ${htable_tmp{$one_word}} = "$numligne"; }
        }
        
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        # mise a jour de la hash globale a l'aide de la hash temporaire
        
        foreach $one_word (sort (keys %htable_tmp))
        { push @list_words, "$one_word:$htable_tmp{$one_word}"; }
        
        $hltable_abrev{$abrev} = [ @list_words ];
        
        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        # liberation des elements de la hash temporaire
  	    ### if (defined %htable_tmp)
  	    ### { undef %htable_tmp; }
      }
      else
      { print hdl_reject "$pattern\n"; }
      
      $nb_pattern ++;
    }
    
    # traitement du numero de version du glossaire
    elsif (/$msk_version/o)
    { print $hdl_result "#version=$1\n"; }
    
    # traitement de la date du glossaire
    elsif (/$msk_date/o)
    { print $hdl_result "#date=$1\n"; }
  }
}

# ____________________________________________________________
# SUB: parse_pattern ( pattern, level ) --> @words

sub parse_pattern
{
  my ($pattern,$level) = @_;
  my @words;
  my @group_words;
  my $group;
  my $group_opt;
  my $rev_item;
  my $newpat;
  
  # le motif constant pour un groupe
  my $msk_group = qw{\(([^()]*)\)([?]?)};
  
  $level++;
  
  $_ = $pattern;

  # extraction du premier groupe '(' ... ')'
  if (/$msk_group/o)
  {
  	  $group = $1;
  	  $group_opt = $2;
  	  
    	@group_words = parse_group($group,$level);
    	
    	# traitement des mots candidats trouves
    	if (scalar @group_words)
    	{
    		# preparation du remplacement du groupe par
    		# les mots candidats trouves
    	  $group = quotemeta "($group)$group_opt";
    	  
    	  # reccursion sur chacun des patterns modifies
    	  foreach $rev_item (@group_words)
    	  {
    	  	$newpat = $pattern;
    	    $newpat =~ s/$group/$rev_item/;
    	  	
    	  	# reccursion sur pattern modifie et
    	  	# ajout du resultat retourne dans @words
    	  	push @words, parse_pattern($newpat,$level);
    	  }
    	  
    	  # traitement du '?' eventuel apres le groupe
    	  if ($group_opt)
    	  {
    	  	$newpat = $pattern;
    	    $newpat =~ s/$group//;
    	  	
    	  	# reccursion sur pattern modifie et
    	  	# ajout du resultat retourne dans @words
    	  	push @words, parse_pattern($newpat,$level);
    	  }
    	}
    	else
    	{ print "\n Aucun mot candidats pour le groupe [$group] !!!\n\n"; }
  }
  else
  {
    # analyse de la chaine restante et
    # ajout du resultat retourne dans @words
    push @words, parse_group($pattern);
  }

  return @words;
}

# ____________________________________________________________
# SUB: parse_group ( pattern, level ) --> @words

sub parse_group
{
  my ($pattern,$level) = @_;
  my @words;
  my @elts = split(/\|/, $pattern);
  my $item;
  
  foreach $item (@elts)
  {
  	push @words, reverse_item($item);
  }
  
  return @words;
}

# ____________________________________________________________
# SUB: reverse_item ( item ) --> @words

sub reverse_item
{
  my ($item) = @_;
  my $item_avec;
  my $item_sans;
  my @words;
  
  # le motif constant pour un item
  my $msk_item = qw(^(.*)(.)\?(.*)$);
  
  # parcours de l'item pour depistage des eventuels '?'
  # et generation des mots candidats avec suppression
  # iteratives des caracteres optionnels (x?)

  $_ = $item;
  if (/$msk_item/o)
  {
  	# preparation reccursion sur le reste du mot, AVEC le
  	# caractere facultatif pour traitement des '?' restant
  	$item_avec = "$1$2$3";
    
  	# preparation reccursion sur le reste du mot, SANS le
  	# caractere facultatif pour traitement des '?' restant
  	$item_sans = "$1$3";

    # lancement des appels reccursifs
  	push @words, reverse_item($item_avec);
		
		push @words, reverse_item($item_sans);
  }
  else
  {
    # ajout de l'element restant et fin de reccursion
    push @words, $item;
  }

  return @words;
}

# ____________________________________________________________
# SUB: print_sort_reverse ( )

sub print_sort_reverse
{
  # tri en memoire des abreviations / mots candidats
  # pour alimentation du fichier associe
  
  my @keys;
  my $key;

  foreach $key (sort (keys %hltable_abrev))
  {
  	my @words = @{$hltable_abrev{$key}};
    my $word;
    my $cpt = 0;
    my $str_words = "";
    
 	  foreach $word (@words)
    {
     	if ($cpt++)
	 	  { $str_words .= ", "; }
	 	  
	 	  # si option numero pas active, on troncque
	 	  if (! $b_numligne)
	 	  { $word =~ s/\:[0-9]+//; }
	 	  $str_words .= "$word";
	 	  
	 	  $nb_result++;
	  }
	 	
	  print $hdl_result "$key\t$str_words\n";
	}
}

# ____________________________________________________________
# SUB: print_parse_infos ( )

sub print_parse_infos
{
  print "Patterns traites :\t\t\t$nb_pattern\n";
  print "... dont rejetes :\t\t\t$nb_reject\n\n";
  print "Mots candidats generes :\t\t$nb_result\n\n";
}

# ____________________________________________________________

if (defined $hdl_reject) { undef $hdl_reject; }
if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_src) { undef $hdl_src; }

# ____________________________________________________________
