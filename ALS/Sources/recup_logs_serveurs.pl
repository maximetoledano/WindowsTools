# ____________________________________________________________
#
# Script d'extraction des évènements du fichier de logs serveurs
# ____________________________________________________________
# ==> $Workfile: recup_logs_serveurs.pl $
# ==> $Revision: 2 $
# ==> $Date: 31/07/03 9:50 $
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/ALS/recup_logs_serveurs.pl $
# ____________________________________________________________

# ____________________________________________________________
# Declaration des librairies

use Win32::EventLog;

use IO::File;

use strict "vars";
#use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des arguments de la ligne de commande
my $path_srvfile = $ENV{ALSFichServeurs};
my $path_result = $ENV{ALSFichLogsResult};
my $date_heure_debut = $ENV{ALSDateHeureDebut};

$date_heure_debut =~ s/\"//g;

# ____________________________________________________________
# Preparation des fichiers

my $hdl_srv = new IO::File $path_srvfile, O_RDONLY;
unless (defined $hdl_srv)
{ die "$nom_cmd: Ouverture fichier des serveurs incorrect ($path_srvfile)\n"; }

my $hdl_result = new IO::File $path_result, O_WRONLY|O_CREAT;
unless (defined $hdl_result)
{ die "$nom_cmd: Creation fichier des logs incorrect ($path_result)\n"; }

# ____________________________________________________________
# Corps du programme

print $hdl_result "Type;Serveur;Date;Heure;Groupe;Source;Message\n";
  
boucle_recup_logs_serveur();

if (defined $hdl_result) { undef $hdl_result; }
if (defined $hdl_srv) { undef $hdl_srv; }

# ____________________________________________________________
# SUB: boucle_recup_logs_serveur

sub boucle_recup_logs_serveur
{
  my $line;

  # lecture du fichier des utilisations entre classes
  while ($line = $hdl_srv->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    $_ = $line;
    if (! /^\s*$/)
    {
      recup_logs_events($line);
    }
  }
}

# ____________________________________________________________
# SUB: recup_logs_events

sub recup_logs_events
{
  my ($srv_name) = @_;
  my $hdl_logs;
  my $groupe_logs;
  my $base_logs;
  my $end_logs;
  my $htab_log;
  my $ind;
  my $nb_errs;
  
  for my $groupe_logs ("Application", "System")
  {
    $hdl_logs = Win32::EventLog->new($groupe_logs, $srv_name)
      or die "[$nom_cmd]: Récupération des logs incorrecte pour serveur [$srv_name] !";
    
    $hdl_logs->GetNumber($end_logs);
    
    $hdl_logs->GetOldest($base_logs);
    
    $ind = $base_logs;
    $nb_errs = 0;
    
    print "Machine:\t\t$srv_name\n";
    print "Type évènement:\t$groupe_logs\n";
    print "Log plus récent:\t$end_logs\n";
    print "Log plus ancien:\t$base_logs\n";
    
    while ($ind <= $end_logs)
    {
      $hdl_logs->Read(EVENTLOG_FORWARDS_READ|EVENTLOG_SEEK_READ, $ind, $htab_log)
        or die "[$nom_cmd]: Récupération de log incorrecte [$ind] !";
      
      if ($htab_log->{EventType} == EVENTLOG_ERROR_TYPE)
      {
        my $msg_err;
        
        Win32::EventLog::GetMessageText($htab_log);
        
        $msg_err = $htab_log->{Message};
        $msg_err =~ s/[\n\r\f]+/ /g;
        
        my ($date_sec,$date_min,$date_hre,$date_jour,$date_mois,$date_an,$jour_sem,$jour_an) = localtime($htab_log->{TimeGenerated});
        
        $date_jour = sprintf("%02d", $date_jour);
        $date_mois = sprintf("%02d", $date_mois);
        $date_an = sprintf("%04d", $date_an + 1900);
        $date_hre = sprintf("%02d", $date_hre);
        $date_min = sprintf("%02d", $date_min);
        $date_sec = sprintf("%02d", $date_sec);
        
        if ($date_heure_debut) 
        {
          if (est_date_heure_plus_tard("$date_jour/$date_mois/$date_an-$date_hre:$date_min:$date_sec", $date_heure_debut))
          {
            print $hdl_result "$htab_log->{EventType};$htab_log->{Computer};$date_jour/$date_mois/$date_an;$date_hre:$date_min:$date_sec;$groupe_logs;$htab_log->{Source};$msg_err\n";
            $nb_errs++;
          }
        }
        else
        {
          print $hdl_result "$htab_log->{Computer};$date_jour/$date_mois/$date_an;$date_hre:$date_min:$date_sec;$groupe_logs;$htab_log->{Source};$msg_err\n";
          $nb_errs++;
        }
      }
      
      $ind++;
    }
    
    print "Erreurs traitées:\t$nb_errs\n\n";
    
    $hdl_logs->Close;
  }
}

# ____________________________________________________________
# SUB: est_date_heure_plus_tard

sub est_date_heure_plus_tard
{
  my ($date_test, $date_debut) = @_;
  my ($jma_t, $hms_t) = split('-', $date_test);
  my ($jma_d, $hms_d) = split('-', $date_debut);
  my ($j_jma_t, $m_jma_t, $a_jma_t) = split('/', $jma_t);
  my ($h_hms_t, $m_hms_t, $s_hms_t) = split(':', $hms_t);
  my ($j_jma_d, $m_jma_d, $a_jma_d) = split('/', $jma_d);
  my ($h_hms_d, $m_hms_d, $s_hms_d) = split(':', $hms_d);
  my $plus_tard = 0;
  
  if ($a_jma_t > $a_jma_d)
  { $plus_tard = 1; }
  elsif ($a_jma_t == $a_jma_d)
  {
    if ($m_jma_t > $m_jma_d)
    { $plus_tard = 1; }
    elsif ($m_jma_t == $m_jma_d)
    {
      if ($j_jma_t > $j_jma_d)
      { $plus_tard = 1; }
      elsif ($j_jma_t == $j_jma_d)
      {
        if ($h_hms_t > $h_hms_d)
        { $plus_tard = 1; }
        elsif ($h_hms_t == $h_hms_d)
        {
          if ($m_hms_t > $m_hms_d)
          { $plus_tard = 1; }
          elsif ($m_hms_t == $m_hms_d)
          {
            if ($s_hms_t >= $s_hms_d)
            { $plus_tard = 1; }
          }
        }
      }
    }
  }
  
  return $plus_tard;
}

# ____________________________________________________________
