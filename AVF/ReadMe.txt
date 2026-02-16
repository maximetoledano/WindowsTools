
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     ~ Documentation des Outils Méthodes pour Octalis. ~
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repères:
~~~~~~~~

Code outil:       AVF
Libellé long:     Archive Versions Fichier
Version:          0.1
Utilisation:      Sous Windows uniquement
Points d'entrée:  Par raccourci Windows paramétré

Description:
~~~~~~~~~~~~

Procède à une sauvegarde ("photo") du fichier passé en argument, stocké dans un
fichier archive (de type "tar" unix zippé).

Le fichier résultat est un fichier dont le nom est suffixé par ".tar.gz", créé
dans un sous répertoire "Versions" du répertoire courant.

Il doit être ouvert à l'aide de WinZip et nécessite un double dézippage (deux
niveaux de zip).

Ce fichier résultat est composé des différentes photos réalisées par l'outil
AVF, dont le nom est préfixé par la date et l'heure de la photo.

Chaque photo peut ainsi être extraite ou directement ouverte par l'application
la plus appropriée (persistance de l'extension d'origine, et donc, de
l'application associée par défaut).

Fonctionnalités disponibles:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   * Archivage des différentes sauvegardes dans un même fichier zip.
   
   * Horodatage de la photo.
   
   * Archivage des différents types de fichiers (raccourcis compris), stockés
   en local comme sur le réseau.
   
   * Support des noms longs (quelque soit le système hôte).
   
   * RESTRICTIONS:
   
     ==> Ne peut traiter qu'un seul fichier à la fois.
     
     ==> Ne peut pas archiver un répertoire.
      
Mode opératoire:
~~~~~~~~~~~~~~~~

   * Sélectionner le fichier à archiver.
   
   * Lancer l'archivage du fichier (click droit sur le fichier, puis "Envoyer
   vers ==> Archive Versions Fichier").
   
Clés de registre:
~~~~~~~~~~~~~~~~~

   Aucune clé utilisée.

Evolutions:
~~~~~~~~~~~

   * 0.1: Archivage du fichier passé en paramètre.
