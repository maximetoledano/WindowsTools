# ____________________________________________________________
#
# Script d'archivage du repertoire dont le chemin est passe en argument.
# ____________________________________________________________
# ==> $Workfile: archive_versions_repertoire.pl $
# ==> $Revision: 1 $
# ==> $Date: 12/01/06 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/AVR/archive_versions_repertoire.pl $
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies

use IO::File;

### # pour les arguments nommes de la ligne de commande
### use Getopt::Long;

# pour la recuperation des dates et heures systeme
use POSIX qw(strftime);

# pour manipuler des fichiers archive (zip)
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

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
my $path_repertoire;

# concatenation des arguments de la ligne de commande
for (my $ind_arg = 0; $ind_arg <= $#ARGV; $ind_arg ++)
{
  if ($path_repertoire)
  { $path_repertoire .= " "; }
  
  $path_repertoire .= $ARGV[$ind_arg];
}

# ____________________________________________________________
# Verifications prealables aux traitements

# verification de la validite du fichier a archiver
unless (-r $path_repertoire)
{ die "$nom_cmd: Repertoire a archiver incorrect ($path_repertoire)\n"; }

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
  my $hdl_archive = Archive::Zip->new();

  # recuperation du chemin d'acces a partir du programme courant
  my $rep_fichier = extrait_nom_rep($path_repertoire);
  my $nom_fichier = extrait_nom_fic($path_repertoire);
  
  # recuperation et affectation de la date courante
  $date_sign = strftime "%Y%m%d-%H%M", localtime;
  
  # reconstitution du nom du fichier zip
  my $path_archive = "$rep_fichier\\$date_sign\.$nom_fichier\.zip";
  
  $hdl_archive->addTree($path_repertoire, $nom_fichier);
  
  my $statut = $hdl_archive->writeToFileNamed($path_archive);
  die "$nom_cmd: Creation archive incorrecte ($$path_archive)\n" if $statut != AZ_OK;
}

# ____________________________________________________________
