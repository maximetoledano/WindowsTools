# ____________________________________________________________
#
# Librairie des methodes communes pour le glossaire des
# abreviations normalisees.
# ____________________________________________________________
# ==> $Workfile: Common.pm $
# ==> $Revision: 10 $
# ==> $Date: 27/05/25 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/site/lib/GAN/Common.pm $
# ____________________________________________________________
# 
# Forcage de l'encodage en ISO-8859-15
# ____________________________________________________________

# ____________________________________________________________
# Declaration du package courant

package GAN::Common;

use Exporter;

@ISA = ('Exporter');

@EXPORT = qw( &purge_libelle_origine
              &purge_termes_superflus );

# ____________________________________________________________
# Declaration des pragmas

use strict "vars";
use strict "refs";

# ____________________________________________________________
# SUB: purge_libelle_origine ( libelle ) --> libelle

# Filtre AVANT TRAITEMENT le libelle d'origine passe en argument,
# et retourne un libelle utilisable pour la generation des noms courts.

sub purge_libelle_origine
{
  my ($libelle) = @_;
  
  # passage en minuscule
  $libelle = lc($libelle);
  
  # remplacement des separateurs genants
  $libelle =~ s/[-_]/ /g;
  
  # preparation des separateurs valables pour recuperation ulterieure
  $libelle =~ s/\:\:/\./g;
  $libelle =~ s/\:/\./g;
  
  # remplacement des caracteres non textuels par des espaces
  $libelle =~ s/[\"\'\/\!\?\[\]\,\;\\]/ /g;
  
  # traduction des caracteres accentues minuscules
  $libelle =~ tr/àâäéèêëîïôöùûüç/aaaeeeeiioouuuc/;
  
  # traduction des caracteres accentues majuscules
  $libelle =~ tr/ÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ/aaaeeeeiioouuuc/;
  
  # traduction des caracteres doubles minuscules
  $libelle =~ s/æ/ae/g;
  $libelle =~ s/½/oe/g;
  
  # traduction des caracteres doubles majuscules
  $libelle =~ s/Æ/ae/g;
  $libelle =~ s/¼/oe/g;
  
  # suppression des trucs bizarres...
  $libelle =~ s/\²//g;
  $libelle =~ s/\.\.\.//g;
  
  # suppression des espaces en trop
  $libelle =~ s/\s+//g;
  
  return $libelle;
}

# ____________________________________________________________
# SUB: purge_termes_superflus ( libelle ) --> libelle

# Filtre APRES TRAITEMENT le libelle restant passe en argument,
# et retourne un libelle epures des termes superflus.

sub purge_termes_superflus
{
  my ($libelle) = @_;
  
  # supression des termes superflus
  $libelle =~ s/\#(&e?)?s?\#/-/g;
  $libelle =~ s/\#(&e?)?s?$//g;
  $libelle =~ s/\#&s\#/-/g;
  $libelle =~ s/\#(&e?)?s?une?\#/-/g;
  $libelle =~ s/\#(&e?)?s?surune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?surl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?surd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?sur\#/-/g;
  $libelle =~ s/\#(&e?)?s?pourune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?pourl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?pourd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?pour\#/-/g;
  $libelle =~ s/\#(&e?)?s?parune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?parl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?pard(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?par\#/-/g;
  $libelle =~ s/\#(&e?)?s?ouune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?oul(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?oudune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?oud(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?ou\#/-/g;
  $libelle =~ s/\#(&e?)?s?l(es?|a)?(\#|$)/-/g;
  $libelle =~ s/\#(&e?)?s?etune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?etl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?etdune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?etd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?et\#/-/g;
  $libelle =~ s/\#(&e?)?s?entreune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?entrel(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?entred(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?entre\#/-/g;
  $libelle =~ s/\#(&e?)?s?enune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?en\#/-/g;
  $libelle =~ s/\#(&e?)?s?dune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?d(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?dansune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?dansl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?dansd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?dans\#/-/g;
  $libelle =~ s/\#(&e?)?s?chezune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?chezl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?chezd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?chez\#/-/g;
  $libelle =~ s/\#(&e?)?s?aux?\#/-/g;
  $libelle =~ s/\#(&e?)?s?avecune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?avecl(es?|a)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?avecd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?avec\#/-/g;
  $libelle =~ s/\#(&e?)?s?aupresdune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?aupresd(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?aune?\#/-/g;
  $libelle =~ s/\#(&e?)?s?ala\#/-/g;
  $libelle =~ s/\#(&e?)?s?ad(u|e(s|la?)?)?\#/-/g;
  $libelle =~ s/\#(&e?)?s?a\#/-/g;
  $libelle =~ s/\#(&e?)?s?(\d+)([-a-z_]+)/-$2\#$3/g;
  $libelle =~ s/([-A-Z0-9_]+)\#(&e?)?s?(\d+)\#([-A-Z0-9_]+)/$1-$3-$4/g;
  $libelle =~ s/\#(&e?)?s?(\d+)$/-$2/g;
  $libelle =~ s/(&e?)?s?\./\./g;
  $libelle =~ s/(&e?)?s?$//g;
  $libelle =~ s/&s$//g;
  $libelle =~ s/([A-Z])\.\#(0?[A-Z])/$1\.$2/g;
  $libelle =~ s/([A-Z])\#\.(0?[A-Z])/$1\.$2/g;
  $libelle =~ s/([a-z])\.\#([a-z])/$1\.$2/g;
  $libelle =~ s/([a-z])\#\.([a-z])/$1\.$2/g;
  $libelle =~ s/^\#//g;
  $libelle =~ s/\#$//g;
  $libelle =~ s/\#\.\#/\./g;
  $libelle =~ s/^\.//g;
  $libelle =~ s/\.$//g;
  $libelle =~ s/^-//g;
  $libelle =~ s/-$//g;
  
  return $libelle;
}

# ____________________________________________________________

# Derniere instruction du module forcee a la valeur '1 pour
# ne pas lever d'exception

1;

# ____________________________________________________________
