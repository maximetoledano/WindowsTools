# ____________________________________________________________
#
# Script d'archivage du fichier dont le chemin est passe en
# argument.
#
# La nouvelle version est renommee pour integrer date et heure
# avant d'etre ajoutee au zip dedie.
# ____________________________________________________________
# ==> $Workfile: archive_versions_fichier.pl $
# ==> $Revision: 2 $
# ==> $Date: 16/12/02 14:38 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/AVF/archive_versions_fichier.pl $
# ____________________________________________________________
# 
# Date:    07/12/2000
# Version: 1.3
# 
# Auteur:  Maxime TOLEDANO
# 
# ==> Recodage des fonctions basename et dirname pour Windows
#     (les versions standards generent des noms courts !!!).
# ____________________________________________________________
# 
# Date:    14/11/2000
# Version: 1.2
# 
# Auteur:  Maxime TOLEDANO
# 
# ==> Modification du passage en argument du nom du fichier
#     pour non prise en compte des espaces dans les path.
# ____________________________________________________________
# 
# Date:    10/10/2000
# Version: 1.1
# 
# Auteur:  Maxime TOLEDANO
# 
# ==> Regroupement des archives dans un sous-repertoire
#     "Versions" du repertoire du source a archiver.
# ____________________________________________________________
# 
# Date:    04/10/2000
# Version: 1.0
# 
# Auteur:  Maxime TOLEDANO
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies

use IO::File;

### # pour les arguments nommes de la ligne de commande
### use Getopt::Long;

# pour la recuperation des dates et heures systeme
use POSIX qw(strftime);

# pour manipuler des fichiers archive (tar)
use Archive::Tar;

# pour la copie facilitee des fichiers
use File::Copy;

use strict "vars";
use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des arguments de la ligne de commande
my $path_fichier;

# concatenation des arguments de la ligne de commande
for (my $ind_arg = 0; $ind_arg <= $#ARGV; $ind_arg ++)
{
  if ($path_fichier)
  { $path_fichier .= " "; }
  
  $path_fichier .= $ARGV[$ind_arg];
}

# ____________________________________________________________
# Verifications prealables aux traitements

# verification de la validite du fichier a archiver
unless (-r $path_fichier)
{ die "$nom_cmd: Fichier a archiver incorrect ($path_fichier)\n"; }

# ____________________________________________________________
# Constantes utilisees

# sous-repertoire de stockage des archives
my $nom_ssrep = "Versions";

# prefixe generique du fichier archive
my $prefix_archive = "";

# suffixe generique du fichier archive
my $suffix_archive = ".tar.gz";

# booleen de compression du fichier archive
my $compress_archive = 1;

### # prefixe generique du fichier commentaire optionnel
### my $prefix_comment = "Comment.";

### # suffixe generique du fichier commentaire optionnel
### my $suffix_comment = ".txt";

# ____________________________________________________________
# Corps du programme

# variable de signature pour la date et l'heure
my $date_sign = "";

set_archive();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: extrait_nom_rep ( cmd )

sub extrait_nom_rep
# extrait_nom_rep cmd
{
  my ($cmd) = @_;
  
  $_ = $cmd;
  m/^(.*)\\/;
  
  return $1;
}

# ____________________________________________________________
# SUB: extrait_nom_fic ( cmd )

sub extrait_nom_fic
# extrait_nom_fic cmd
{
  my ($cmd) = @_;
  
  $_ = $cmd;
  m/(.*\\)?(.*)$/;
  
  return $2;
}

# ____________________________________________________________
# SUB: set_archive ( )

sub set_archive
{
  my $hdl_archive = Archive::Tar->new();
  
  # recuperation du chemin d'acces a partir du programme courant
  my $rep_fichier = extrait_nom_rep($path_fichier);
  my $nom_fichier = extrait_nom_fic($path_fichier);
  
  my $rep_archive = "$rep_fichier\\$nom_ssrep";
  
  # creation - si besoin - du sous-repertoire dedie
  if (! -d $rep_archive)
  { mkdir $rep_archive; }
  
  # positionnement dans le repertoire d'archive
  chdir $rep_archive;
  
  # recuperation et affectation de la date courante
  $date_sign = strftime "%Y%m%d-%H%M", localtime;
  
  # preparation des noms d'archive
  my $path_archive = "$prefix_archive$nom_fichier$suffix_archive";
  
  # creation du fichier archive si inexistant
  unless (-w $path_archive)
  {
    my $hdl_tmp = new IO::File $path_archive, O_WRONLY|O_CREAT;
    
    if ($hdl_tmp)
    { undef $hdl_tmp; }
    else
    { die "$nom_cmd: Creation fichier archive incorrecte ($path_archive)\n"; }
  }
  
  # recuperation du contenu actuel de l'archive
  $hdl_archive->read($path_archive, $compress_archive);
  
  # preparation copie fichier a archiver pour prise en compte
  # signature horaire dans le nom
  my $path_copie = "$date_sign\.$nom_fichier";
  copy($path_fichier, $path_copie);
  
  # archivage de la copie creee
  $hdl_archive->add_files($path_copie);
  
  # suppression de la copie apres archivage
  unlink $path_copie;
  
###   # archivage d'un eventuel commentaire d'archivage
###   # (sous la forme d'un fichier separe)
###   if ("$comment_version" ne "")
###   {
###     my $path_fich_comment = "$date_sign\.$prefix_comment$nom_fichier$suffix_comment";
###     
###     $hdl_archive->add_data($path_fich_comment, $comment_version);
###   }
  
  # ecriture du fichier archive
  $hdl_archive->write($path_archive, $compress_archive);
}

# ____________________________________________________________
