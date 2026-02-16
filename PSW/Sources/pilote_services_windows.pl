# ____________________________________________________________
#
# Script de pilotage des applications et services Windows.
# ____________________________________________________________
# ==> $Workfile: pilote_services_windows.pl $
# ==> $Revision$
# ==> $Date$
# ==> $Author: Mtoledano $
# ==> $Archive: /Scripts Perl/PSW/pilote_services_window.pl $
# ____________________________________________________________


# ____________________________________________________________
# Declaration des librairies standard

use IO::File;
use File::Basename;
use Win32::Process;
use Win32::Service;

use strict "vars";
#use strict "refs";
use integer;

# ____________________________________________________________
# Prise en compte de l'environnement d'appel

# recuperation commande lancee
my $nom_cmd = $0;

# recuperation des elements specifiques de l'environnement
my $path_tmp = $ENV{PSWTempDir};
my $action_type = $ENV{PSWAction};
my $process_group = $ENV{PSWProcessGroup};
my $path_services_file = $ENV{PSWFichCommand};
my $path_process_list = $ENV{PSWFichProcess};
my $path_result = $ENV{PSWFichResult};
my $path_tmp_0 = $ENV{PSWFichTmpSrc};

my $nb_result = 0;

# purge des eventuels '"' contenus dans les path recus
$path_tmp =~ s/\"//g;
$action_type =~ s/\"//g;
$process_group =~ s/\"//g;
$path_services_file =~ s/\"//g;
$path_process_list =~ s/\"//g;
$path_result =~ s/\"//g;
$path_tmp_0 =~ s/\"//g;

# ____________________________________________________________
# Corps du programme

my $nb_cmds = 0;

my $hdl_process_list;

print "Action:    $action_type\n";
print "Groupe:    $process_group\n";
print "Config:    $path_services_file\n";
print "Processus: $path_process_list\n";
print "\n";

load_commands();

autoflush STDOUT 1;

# ____________________________________________________________
# SUB: load_commands ( )

sub load_commands
{
  my $hdl_services_file;
  my $line;
  my $host;
  my $action;
  my $desc;
  my $args;
  my $pid;
  my $nb_process;
  
  # si demarrage, creation du fichier des processus instancies
  if ("$action_type" eq "Start")
  {
    $hdl_process_list = new IO::File $path_process_list, O_WRONLY|O_CREAT;
    unless (defined $hdl_process_list)
    { die "$nom_cmd: Creation fichier des processus incorrect [$path_process_list]\n"; }
  }
  elsif ("$action_type" eq "Stop")
  {
    $hdl_process_list = new IO::File $path_process_list, O_RDONLY;
    unless (defined $hdl_process_list)
    { print "\t... Aucun fichier de processus a traiter [$path_process_list]\n"; }
  }
  else
  { die "$nom_cmd: Type d'action incorrect [$action_type] ('Start' ou 'Stop' accepte)\n"; }

  # ouverture du fichier de configuration adhoc
  $hdl_services_file = new IO::File $path_services_file, O_RDONLY;
  unless (defined $hdl_services_file)
  { die "$nom_cmd: Fichier de déclaration des services incorrect [$path_services_file]\n"; }

  $/ = "\n";

  # chargement des commandes a traiter
  while ($line = $hdl_services_file->getline)
  {
    # suppression fin de ligne Windows
    chomp $line;
    
    # suppression des lignes vides ou de commentaires (lignes commencant par '#')
    $_ = $line;
    if ((! /^\s*$/) and (! /^\#/))
    {
      # purge des eventuels '"' parasites
      $line =~ s/\"//g;
      
      # ---------------------------------------------- #
      # Format des lignes: 'pid|description|arguments' #
      # ---------------------------------------------- #
      ($host, $action, $desc, $args) = split(/\|/, $line, 4);
      
      execute_command($host, $action, $desc, $args);
      
      $nb_cmds ++;
    }
  }
  
  # arret des applications instanciees
  if ("$action_type" eq "Stop")
  {
    while ($line = $hdl_process_list->getline)
    {
      # suppression fin de ligne Windows
      chomp $line;
      
      # suppression des lignes vides ou de commentaires (lignes commencant par '#')
      $_ = $line;
      if ((! /^\s*$/) and (! /^\#/))
      {
        # purge des eventuels '"' parasites
        $line =~ s/\"//g;
        
        # ----------------------------------------------------------- #
        # Format des lignes: 'host_name|action|description|arguments' #
        # ----------------------------------------------------------- #
        ($pid, $desc, $args) = split(/\|/, $line, 3);
        
        # recuperation du nombre de processus existants
        $nb_process = kill 0, $pid;
        if ($nb_process = 1)
        {
          Win32::Process::KillProcess($pid, 1);
        }
        elsif ($nb_process > 1)
        { die "$nom_cmd: Plusieurs processus trouves [$pid][$desc][$args]\n"; }
      }
    }
  }

  if (defined $hdl_services_file) { undef $hdl_services_file; }
  if (defined $hdl_process_list) { undef $hdl_process_list; }
}

# ____________________________________________________________
# SUB: execute_command ( )

sub execute_command
{
  my ($host, $action, $desc, $args) = @_;
  my $process;
  my $pid;
  my $exec_dir;

  # validation de l'action demandee
  if (! (("$action" eq "application") or ("$action" eq "start") or ("$action" eq "stop") or ("$action" eq "restart")))
    { die "$nom_cmd: Action demandee inconnue ($action)\n"; }

  # validation d'une demande locale pour lancement d'application
  if (("$host" ne "") and ("$action" eq "application"))
  { die "$nom_cmd: Lancement d'application distante non supportee [$host][$desc]\n"; }
  
  # analyse de l'action demandee
  if ("$action" eq "application")
  {
    # reconstitution du chemin du repertoire d'execution
    $exec_dir = File::Basename::dirname($desc);
    
    if (! (Win32::Process::Create($process, $desc, $args, 1, CREATE_NEW_CONSOLE, "$exec_dir")))
    { print "Erreur Start Application [$desc][$args]\n"; }
    else
    {
      # temporisation (en millisecondes) pour synchronisation des processus Windows
      $process->Wait(1000);
      
      # trace de la nouvelle application, si besoin
      if (("$action_type" eq "Start") and ($pid = $process->GetProcessID()))
      {
        # mise a jour du fichier des processus instancies
        print $hdl_process_list "$pid|$desc|$args\n";
      }
    }
  }
  elsif ("$action" eq "start")
  {
    if (! Win32::Service::StartService($host, $desc))
    { print "Erreur Start Service [$host][$desc]\n"; }
  }
  elsif ("$action" eq "stop")
  {
    if (! Win32::Service::StopService($host, $desc))
    { print "Erreur Stop Service [$host][$desc]\n"; }
  }
  else
  {
    if (! Win32::Service::StopService($host, $desc))
    { print "Erreur Restart/Stop Service [$host][$desc]\n"; }

    if (! Win32::Service::StartService($host, $desc))
    { print "Erreur Restart/Start Service [$host][$desc]\n"; }
  }
}

# ____________________________________________________________
